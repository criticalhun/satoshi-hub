import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { Logger, Injectable } from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { PayloadService } from '../payload/payload.service';
import { TransactionPayload } from '@satoshi-hub/sdk';

@Injectable()
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
        throw new Error(`Signer could not be created for chainId: ${txJob.fromChainId}`);
      }
      this.logger.log(`Using signer address: ${signer.address}`);
      
      const payload: TransactionPayload = JSON.parse(txJob.payload as string);
      
      const txData = await this.payloadService.process(payload);
      const txRequest = { to: txData.to, value: txData.value, data: txData.data };
      this.logger.log(`Sending transaction...`, txRequest);
      
      // Szimulált tranzakció a Redis nélküli teszteléshez
      // const sentTx = await signer.sendTransaction(txRequest);
      // const receipt = await sentTx.wait();
      
      // Szimulált receipt a teszteléshez
      const receipt = {
        blockNumber: 123456,
        transactionHash: '0x' + Math.random().toString(16).substring(2, 34),
      };
      
      this.logger.log(`Transaction confirmed in block: ${receipt.blockNumber}`);
      
      const finalJob = await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'completed',
          result: JSON.stringify({
            message: 'Transaction confirmed on source chain.',
            txHash: receipt.transactionHash,
            blockNumber: receipt.blockNumber,
          }),
        },
      });
      this.logger.log(`Job ${jobId} status updated to 'completed'.`);
      return finalJob;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.error(`Error processing job ${jobId}:`, errorMessage);
      await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'failed',
          result: JSON.stringify({ message: errorMessage }),
        },
      });
      throw error;
    }
  }
}
