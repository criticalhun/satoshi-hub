import { Test, TestingModule } from '@nestjs/testing';
import { TxService } from './tx.service';
import { PrismaService } from '../prisma/prisma.service';

class MockPrismaService {}
const mockQueue = { add: jest.fn() };

describe('TxService', () => {
  let service: TxService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TxService,
        { provide: PrismaService, useClass: MockPrismaService },
        { provide: 'BullQueue_tx-queue', useValue: mockQueue },
      ],
    }).compile();

    service = module.get<TxService>(TxService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // Ide írj konkrét tesztet, ha van metódus!
});