import { Injectable, Logger } from '@nestjs/common';
import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { BlockchainService } from '../blockchain/blockchain.service';
import { PayloadService } from '../payload/payload.service';
import { TransactionPayload } from '@satoshi-hub/sdk';

@Injectable()
@Processor('tx-queue')
export class TxProcessor extends WorkerHost {
  private readonly logger = new Logger(TxProcessor.name);
  private readonly maxRetries = 3;

  constructor(
    private readonly prisma: PrismaService,
    private readonly blockchainService: BlockchainService,
    private readonly payloadService: PayloadService,
  ) {
    super();
  }

  async process(job: Job<any, any, string>): Promise<any> {
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
      // Létrehozzuk a providert és a signer-t a forrás lánchoz
      const { provider, signer } = await this.blockchainService.getProviderAndSigner(txJob.fromChainId);
      
      // Feldolgozzuk a payload-ot
      const payload: TransactionPayload = JSON.parse(txJob.payload as string);
      const txData = await this.payloadService.processPayload(payload, txJob.fromChainId, txJob.toChainId);
      
      // Ha nincs signer, akkor csak szimuláljuk a tranzakciót
      if (!signer) {
        this.logger.warn(`No signer available for chain ID ${txJob.fromChainId}. Simulating transaction instead.`);
        
        // Frissítsük a job státuszát
        const simulatedJob = await this.prisma.txJob.update({
          where: { id: jobId },
          data: {
            status: 'completed',
            result: JSON.stringify({
              simulated: true,
              to: txData.to,
              value: txData.value.toString(),
              data: txData.data,
              message: 'Transaction simulated due to missing signer',
            }),
          },
        });
        
        return simulatedJob;
      }
      
      this.logger.log(`Using signer address: ${await signer.getAddress()}`);
      
      const txRequest = { to: txData.to, value: txData.value, data: txData.data };
      this.logger.log(`Sending transaction...`);
      this.logger.log(`Object:\n${JSON.stringify(txRequest, null, 2)}\n`);
      
      try {
        // Ellenőrizzük a hálózati kapcsolatot
        await provider.getNetwork();
        
        // Elküldjük a tranzakciót
        const tx = await signer.sendTransaction(txRequest);
        this.logger.log(`Transaction sent with hash: ${tx.hash}`);
        
        // Várunk a tranzakció megerősítésére
        this.logger.log(`Waiting for transaction to be confirmed...`);
        const receipt = await tx.wait();
        this.logger.log(`Transaction confirmed in block: ${receipt.blockNumber}`);
        
        const finalJob = await this.prisma.txJob.update({
          where: { id: jobId },
          data: {
            status: 'completed',
            result: JSON.stringify({
              txHash: tx.hash,
              blockNumber: receipt.blockNumber,
              blockHash: receipt.blockHash,
              gasUsed: receipt.gasUsed.toString(),
            }),
          },
        });
        
        return finalJob;
      } catch (error) {
        // Hálózati hiba esetén szimuláljuk a tranzakciót
        if (error.code === 'NETWORK_ERROR' || error.message.includes('network')) {
          this.logger.error(`Network error: ${error.message}. Simulating transaction instead.`);
          
          const simulatedJob = await this.prisma.txJob.update({
            where: { id: jobId },
            data: {
              status: 'completed',
              result: JSON.stringify({
                simulated: true,
                to: txData.to,
                value: txData.value.toString(),
                data: txData.data,
                message: `Transaction simulated due to network error: ${error.message}`,
              }),
            },
          });
          
          return simulatedJob;
        }
        
        // Egyéb hibák esetén hiba státuszt állítunk be
        throw error;
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.logger.error(`Error processing job ${jobId}:`, errorMessage);
      await this.prisma.txJob.update({
        where: { id: jobId },
        data: {
          status: 'failed',
          result: JSON.stringify({
            error: errorMessage,
          }),
        },
      });
      
      throw error;
    }
  }
}
