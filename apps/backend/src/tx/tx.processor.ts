import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { Logger } from '@nestjs/common';

// A helper function to simulate async work
const delay = (ms: number) => new Promise((res) => setTimeout(res, ms));

@Processor('tx-queue')
export class TxProcessor extends WorkerHost {
  private readonly logger = new Logger(TxProcessor.name);

  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async process(job: Job<{ jobId: string }>): Promise<any> {
    this.logger.log(`Processing job ${job.id} with data:`, job.data);

    const { jobId } = job.data;

    // 1. Update status to 'processing'
    await this.prisma.txJob.update({
      where: { id: jobId },
      data: { status: 'processing' },
    });
    this.logger.log(`Job ${jobId} status updated to 'processing'.`);

    // 2. Simulate blockchain work
    await delay(5000); // Wait for 5 seconds

    // 3. Update status to 'completed'
    const finalJob = await this.prisma.txJob.update({
      where: { id: jobId },
      data: {
        status: 'completed',
        result: { message: 'Transaction processed successfully' },
      },
    });
    this.logger.log(`Job ${jobId} status updated to 'completed'.`);

    return finalJob;
  }
}
