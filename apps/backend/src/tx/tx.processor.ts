import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { PayloadService } from '../payload/payload.service';
import { TxPayload } from '@satoshi-hub/sdk';

@Processor('tx-queue')
export class TxProcessor extends WorkerHost {
  private readonly logger = new Logger(TxProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly blockchainService: BlockchainService,
    private readonly payloadService: PayloadService,
  ) {
    super();
  }

  async process(job: Job<{ jobId: string }>): Promise<any> {
    const { jobId } = job.data;
    this.logger.log(`Processing job ${jobId}`);

    const txJob = await this.prisma.txJob.findUnique({ where: { id: jobId } });
    if (!txJob) {
      throw new Error(`TxJob with id ${jobId} not found.`);
    }

    await this.prisma.txJob.update({
      where: { id: jobId },
      data: { status: 'processing' },
    });
    this.logger.log(`Job ${jobId} status updated to 'processing'.`);

    try {
      const signer = this.blockchainService.getSigner(txJob.fromChainId);
      if (!signer) {
        throw new Error(`Signer not found for chainId: ${txJob.fromChainId}`);
      }
      this.logger.log(`Using signer address: ${signer.address}`);

      const payload: TxPayload = JSON.parse(txJob.payload); // <-- Visszaalakítás objektummá
      const txData = await this.payloadService.process(payload);
      
      const txRequest = { to: txData.to, value: txData.value, data: txData.data };

      const sentTx = await signer.sendTransaction(txRequest);
      if (!sentTx) {
        throw new Error('Failed to send transaction.');
      }
      this.logger.log(`Transaction sent. Hash: ${sentTx.hash}. Waiting for confirmation...`);

      const receipt = await sentTx.wait();
      if (!receipt) {
        throw new Error(`Transaction failed to confirm. Hash: ${sentTx.hash}`);
      }
      this.logger.log(`Transaction confirmed in block: ${receipt.blockNumber}`);

      const finalJob = await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'completed',
          result: JSON.stringify({
            message: 'Transaction confirmed on source chain.',
            txHash: receipt.hash,
            blockNumber: receipt.blockNumber,
          }),
        },
      });

      this.logger.log(`Job ${jobId} status updated to 'completed'.`);
      return finalJob;
    } catch (error) {
      this.logger.error(`Error processing job ${jobId}:`, error);
      await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'failed',
          result: JSON.stringify({ message: error instanceof Error ? error.message : String(error) }),
        },
      });
      throw error;
    }
  }
}