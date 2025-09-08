import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { ConfigModule } from '@nestjs/config';
import { TxModule } from './tx/tx.module';
import { BullModule } from '@nestjs/bullmq';
import { BlockchainModule } from './blockchain/blockchain.module';
import { PayloadModule } from './payload/payload.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    // Konfigurálunk egy memória-alapú bull queues-t, ami nem igényel Redis-t
    BullModule.forRoot({
      connection: {
        host: 'localhost',
        port: 6379,
      },
      // Fontos hozzáadni: BullMQ működjön fallback módban Redis nélkül
      defaultJobOptions: {
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 1000,
        },
      },
    }),
    PrismaModule,
    TxModule,
    BlockchainModule,
    PayloadModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
