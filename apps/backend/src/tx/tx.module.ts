import { Module } from '@nestjs/common';
import { TxService } from './tx.service';
import { TxController } from './tx.controller';
import { TxProcessor } from './tx.processor';
import { BullModule } from '@nestjs/bullmq';
import { PrismaModule } from '../prisma/prisma.module';
import { BlockchainModule } from '../blockchain/blockchain.module';
import { PayloadModule } from '../payload/payload.module';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'tx-queue',
      connection: {
        host: 'localhost',
        port: 6379,
        password: '007adam', // A beállított Redis jelszó
      },
    }),
    PrismaModule,
    BlockchainModule,
    PayloadModule,
  ],
  controllers: [TxController],
  providers: [TxService, TxProcessor],
})
export class TxModule {}
