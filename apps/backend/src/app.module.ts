import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { TxModule } from './tx/tx.module';
import { BlockchainModule } from './blockchain/blockchain.module';
import { PayloadModule } from './payload/payload.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
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
