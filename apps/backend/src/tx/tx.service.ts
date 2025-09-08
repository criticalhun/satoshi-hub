import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTxJobDto } from './dto/create-tx-job.dto';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

@Injectable()
export class TxService {
  private readonly logger = new Logger(TxService.name);

  constructor(
    private readonly prisma: PrismaService,
    @InjectQueue('tx-queue') private readonly txQueue: Queue,
  ) {}

  async create(createTxJobDto: CreateTxJobDto) {
    // Mentsük a feladatot az adatbázisba
    const txJob = await this.prisma.txJob.create({
      data: {
        fromChainId: createTxJobDto.fromChainId,
        toChainId: createTxJobDto.toChainId,
        payload: JSON.stringify(createTxJobDto.payload),
      },
    });

    this.logger.log(`Created txJob with ID: ${txJob.id}`);

    // Adjuk hozzá a tranzakciós job-ot a feldolgozási sorhoz
    const job = await this.txQueue.add('process-tx', { jobId: txJob.id });
    this.logger.log(`Added job to queue with ID: ${job.id}`);

    // Adjuk vissza a létrehozott job-ot
    return txJob;
  }

  async findOne(id: string) {
    return this.prisma.txJob.findUnique({ where: { id } });
  }

  async findAll(params: {
    page: number;
    limit: number;
    fromChainId?: number;
    toChainId?: number;
    status?: string;
  }) {
    const { page, limit, fromChainId, toChainId, status } = params;
    const skip = (page - 1) * limit;

    // Építsük fel a where feltételt a megadott szűrők alapján
    const where: any = {};
    if (fromChainId !== undefined) where.fromChainId = fromChainId;
    if (toChainId !== undefined) where.toChainId = toChainId;
    if (status) where.status = status;

    // Lekérdezzük a tranzakciókat és a teljes számot
    const [txJobs, total] = await Promise.all([
      this.prisma.txJob.findMany({
        where,
        skip,
        take: limit,
        orderBy: {
          createdAt: 'desc',
        },
      }),
      this.prisma.txJob.count({ where }),
    ]);

    // Adjuk vissza a tranzakciókat és a lapozási információkat
    return {
      data: txJobs,
      meta: {
        total,
        page,
        limit,
        lastPage: Math.ceil(total / limit) || 1,
      },
    };
  }
}
