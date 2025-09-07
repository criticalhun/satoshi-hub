import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { PrismaModule } from '../prisma/prisma.module';
import { TxTestModule } from './tx-test.module';
import { BlockchainModule } from '../blockchain/blockchain.module';
import { PayloadModule } from '../payload/payload.module';

export class IntegrationTestSetup {
  public app!: INestApplication;
  public prisma!: PrismaService;
  private module!: TestingModule;

  async setup(): Promise<void> {
    this.module = await Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          envFilePath: '.env.test',
          isGlobal: true,
        }),
        PrismaModule,
        TxTestModule, // Use test module instead of TxModule
        BlockchainModule, 
        PayloadModule,
      ],
    }).compile();

    this.app = this.module.createNestApplication();
    
    // ValidationPipe beállítása
    this.app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      })
    );
    
    this.prisma = this.app.get<PrismaService>(PrismaService);

    await this.app.init();
    await this.cleanDatabase();
  }

  async teardown(): Promise<void> {
    if (this.prisma) {
      await this.cleanDatabase();
    }
    if (this.app) {
      await this.app.close();
    }
  }

  private async cleanDatabase(): Promise<void> {
    if (!this.prisma) {
      return;
    }
    await this.prisma.txJob.deleteMany();
  }

  async createTestData() {
    const txJob = await this.prisma.txJob.create({
      data: {
        fromChainId: 11155111,
        toChainId: 80002,
        payload: JSON.stringify({
          type: 'NATIVE_TOKEN_TRANSFER',
          to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
          amount: '0.1',
        }),
        status: 'pending',
      },
    });

    return { txJob };
  }
}
