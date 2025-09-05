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
      // Get the provider for the source chain
      const provider = this.blockchainService.getProvider(txJob.fromChainId);

      // --- Transaction Preparation ---
      const toAddress = '0x000000000000000000000000000000000000dEaD'; // Burn address
      const amount = ethers.parseEther('0.0001'); // Send 0.0001 ETH

      const preparedTx = {
        to: toAddress,
        value: amount.toString(),
      };

      this.logger.log(`Prepared transaction for job ${jobId}:`, preparedTx);

      const finalJob = await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'completed',
          result: {
            message: 'Transaction prepared successfully.',
            preparedTx,
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