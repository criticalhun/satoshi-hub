import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { BlockchainService } from './blockchain.service';

describe('BlockchainService', () => {
  let service: BlockchainService;
  let configService: ConfigService;

  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BlockchainService,
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<BlockchainService>(BlockchainService);
    configService = module.get<ConfigService>(ConfigService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should throw error for unsupported chainId', () => {
    expect(() => service.getSigner(999999)).toThrow('Unsupported chainId: 999999');
  });

  it('should return null for non-EVM chain', () => {
    // Assuming chainId -1 is a non-EVM chain in SUPPORTED_CHAINS
    const result = service.getSigner(-1);
    expect(result).toBeNull();
  });

  it('should throw error when SIGNER_PRIVATE_KEY is not set', () => {
    mockConfigService.get.mockReturnValue(undefined);
    
    // Use a supported EVM chainId (assuming 1 is supported)
    expect(() => service.getSigner(1)).toThrow('SIGNER_PRIVATE_KEY is not set in the environment variables');
  });
});
