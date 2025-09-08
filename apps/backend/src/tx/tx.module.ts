import { Module } from '@nestjs/common';
import { TxService } from './tx.service';
import { TxController } from './tx.controller';
import { BullModule } from '@nestjs/bullmq';
import { TxProcessor } from './tx.processor';
import { BlockchainModule } from '../blockchain/blockchain.module';
import { PayloadModule } from '../payload/payload.module';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'tx-queue',
      // Inline processing igazítása
      defaultJobOptions: {
        removeOnComplete: true,
        removeOnFail: false,
      },
    }),
    BlockchainModule,
    PayloadModule,
  ],
  controllers: [TxController],
  providers: [
    TxService,
    TxProcessor,
  ],
})
export class TxModule {}
