import { Test, TestingModule } from '@nestjs/testing';
import { PayloadService } from './payload.service';
import { NativeTokenTransferProcessor } from './processors/native-token-transfer.processor';

class MockProcessor {
  // Ha van metódus, ide mockold!
  process(payload: any) {
    return payload;
  }
}

describe('PayloadService', () => {
  let service: PayloadService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PayloadService,
        { provide: NativeTokenTransferProcessor, useClass: MockProcessor },
      ],
    }).compile();

    service = module.get<PayloadService>(PayloadService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // Ide írj konkrét tesztet, ha van metódus!
});