import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { TxService } from './tx.service';
import { TxController } from './tx.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { TxProcessor } from './tx.processor';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'tx-queue',
    }),
    PrismaModule,
  ],
  controllers: [TxController],
  // Add the processor to the providers
  providers: [TxService, TxProcessor],
})
export class TxModule {}