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
      // 1. Get the signer for the source chain
      const signer = this.blockchainService.getSigner(txJob.fromChainId);
      this.logger.log(`Using signer address: ${signer.address}`);

      // 2. Define transaction details
      const toAddress = '0x000000000000000000000000000000000000dEaD'; // Burn address
      const amount = ethers.parseEther('0.0001');

      const txRequest = {
        to: toAddress,
        value: amount,
      };

      this.logger.log(
        `Sending transaction from ${signer.address} on chainId ${txJob.fromChainId}`,
        txRequest,
      );

      // 3. Sign and send the transaction
      const sentTx = await signer.sendTransaction(txRequest);

      this.logger.log(
        `Transaction sent. Hash: ${sentTx.hash}. Waiting for confirmation...`,
      );

      // 4. Update the job with the transaction hash
      const finalJob = await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'submitted', // New status: sent, but not yet confirmed
          result: {
            message: 'Transaction submitted to the network.',
            txHash: sentTx.hash,
            from: sentTx.from,
            to: sentTx.to,
            value: sentTx.value.toString(),
          },
        },
      });

      this.logger.log(`Job ${jobId} status updated to 'submitted'.`);
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