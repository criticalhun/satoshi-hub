import { Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTxDto } from './dto/create-tx.dto';

@Injectable()
export class TxService {
  constructor(
    private readonly prisma: PrismaService,
    @InjectQueue('tx-queue') private readonly txQueue: Queue,
  ) {}

  async createTxJob(createTxDto: CreateTxDto) {
    // 1. Create a job record in the database
    const txJob = await this.prisma.txJob.create({
      data: {
        fromChainId: createTxDto.fromChainId,
        toChainId: createTxDto.toChainId,
        payload: createTxDto.payload,
        status: 'pending',
      },
    });

    // 2. Add the job to the queue for processing
    await this.txQueue.add('process-tx', {
      jobId: txJob.id,
    });

    return txJob;
  }
}
