import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTxDto } from './dto/create-tx.dto';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

@Injectable()
export class TxService {
  private readonly logger = new Logger(TxService.name);

  constructor(
    private readonly prisma: PrismaService,
    @InjectQueue('tx-queue') private readonly txQueue: Queue,
  ) {}

  async createTxJob(createTxDto: CreateTxDto) {
    const txJob = await this.prisma.txJob.create({
      data: {
        fromChainId: createTxDto.fromChainId,
        toChainId: createTxDto.toChainId,
        payload: JSON.stringify(createTxDto.payload), // <-- Átalakítás stringgé
        status: 'pending',
      },
    });

    this.logger.log(`Created txJob with ID: ${txJob.id}`);
    const job = await this.txQueue.add('process', { jobId: txJob.id });
    this.logger.log(`Added job to queue with ID: ${job.id}`);

    return { id: txJob.id, jobId: job.id, status: txJob.status };
  }

  async findAll() {
    return this.prisma.txJob.findMany();
  }

  async findOne(id: string) {
    return this.prisma.txJob.findUnique({ where: { id } });
  }
}
