import { Test, TestingModule } from '@nestjs/testing';
import { PayloadService } from './payload.service';
import { NativeTokenTransferProcessor } from './processors/native-token-transfer.processor';
import { PayloadType } from '@satoshi-hub/sdk';

describe('PayloadService', () => {
  let service: PayloadService;
  let nativeTokenProcessor: NativeTokenTransferProcessor;

  const mockNativeTokenProcessor = {
    process: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PayloadService,
        {
          provide: NativeTokenTransferProcessor,
          useValue: mockNativeTokenProcessor,
        },
      ],
    }).compile();

    service = module.get<PayloadService>(PayloadService);
    nativeTokenProcessor = module.get<NativeTokenTransferProcessor>(NativeTokenTransferProcessor);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should process native token transfer payload', async () => {
    const payload = {
      type: PayloadType.NATIVE_TOKEN_TRANSFER,
      to: '0x123',
      amount: '1.0',
    };
    const expectedResult = {
      to: '0x123',
      value: '1000000000000000000',
      data: '0x',
    };

    mockNativeTokenProcessor.process.mockResolvedValue(expectedResult);

    const result = await service.process(payload);

    expect(result).toEqual(expectedResult);
    expect(mockNativeTokenProcessor.process).toHaveBeenCalledWith(payload);
  });

  it('should throw error for unsupported payload type', async () => {
    const payload = {
      type: 'UNSUPPORTED_TYPE' as any,
      to: '0x123',
    };

    // JAVÍTÁS: error casting Error típusra
    try {
      await service.process(payload);
      fail('Expected error to be thrown');
    } catch (error) {
      expect((error as Error).message).toBe('Unsupported payload type: UNSUPPORTED_TYPE');
    }
  });
});
