import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { TxService } from './tx.service';
import { TxController } from './tx.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [
    // Register the queue
    BullModule.registerQueue({
      name: 'tx-queue',
    }),
    PrismaModule,
  ],
  controllers: [TxController],
  providers: [TxService],
})
export class TxModule {}
