import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';
import { BlockchainService } from '../blockchain/blockchain.service';
import { ethers } from 'ethers';

@Processor('tx-queue')
export class TxProcessor extends WorkerHost {
  private readonly logger = new Logger(TxProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly blockchainService: BlockchainService,
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
      this.logger.log(`Using signer address: ${signer.address}`);

      const toAddress = '0x000000000000000000000000000000000000dEaD';
      const amount = ethers.parseEther('0.0001');

      const txRequest = { to: toAddress, value: amount };

      this.logger.log(`Sending transaction...`, txRequest);
      const sentTx = await signer.sendTransaction(txRequest);
      this.logger.log(
        `Transaction sent. Hash: ${sentTx.hash}. Waiting for confirmation...`,
      );

      const receipt = await sentTx.wait();

      // --- JAVÍTÁS: Ellenőrizzük, hogy a 'receipt' nem null ---
      if (!receipt) {
        throw new Error(
          `Transaction failed to confirm and get a receipt. Hash: ${sentTx.hash}`,
        );
      }

      this.logger.log(
        `Transaction confirmed in block number: ${receipt.blockNumber}`,
      );

      const finalJob = await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'completed',
          result: {
            message: 'Transaction confirmed on source chain.',
            txHash: receipt.hash,
            blockNumber: receipt.blockNumber,
            gasUsed: receipt.gasUsed.toString(),
          },
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
          result: { message: error.message },
        },
      });
      throw error;
    }
  }
}