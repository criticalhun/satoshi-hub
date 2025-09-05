import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { TxService } from './tx.service';
import { TxController } from './tx.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { TxProcessor } from './tx.processor';
import { BlockchainModule } from '../blockchain/blockchain.module';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'tx-queue',
    }),
    PrismaModule,
    BlockchainModule,
  ],
  controllers: [TxController],
  providers: [TxService, TxProcessor],
})
export class TxModule {}