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
    // Solana Devnet chainId -1
    const result = service.getSigner(-1);
    expect(result).toBeNull();
  });

  it('should throw error when SIGNER_PRIVATE_KEY is not set', () => {
    mockConfigService.get.mockReturnValue(undefined);
    
    // Use a supported EVM chainId - Sepolia Testnet
    expect(() => service.getSigner(11155111)).toThrow('SIGNER_PRIVATE_KEY is not set in the environment variables');
  });

  it('should create signer for valid EVM chain with private key', () => {
    mockConfigService.get.mockReturnValue('0x0000000000000000000000000000000000000000000000000000000000000001');
    
    const result = service.getSigner(11155111);
    expect(result).toBeTruthy();
    // Remove the null check issue
    if (result) {
      expect(result.address).toBeDefined();
    }
  });
});
