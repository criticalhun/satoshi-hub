import { Test, TestingModule } from '@nestjs/testing';
import { BlockchainService } from './blockchain.service';

describe('BlockchainService', () => {
  let service: BlockchainService;
  
  // A teszt előtt állítsuk be a környezeti változót
  const originalEnv = process.env;

  beforeEach(async () => {
    // Mockoljuk a környezeti változókat
    process.env = { ...originalEnv, SIGNER_PRIVATE_KEY: '0x1234567890123456789012345678901234567890123456789012345678901234' };

    const module: TestingModule = await Test.createTestingModule({
      providers: [BlockchainService],
    }).compile();

    service = module.get<BlockchainService>(BlockchainService);
  });

  afterEach(() => {
    // Állítsuk vissza az eredeti környezeti változókat
    process.env = originalEnv;
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
    // Állítsuk be null-ra a SIGNER_PRIVATE_KEY-t
    process.env.SIGNER_PRIVATE_KEY = '';
    
    // Use a supported EVM chainId - Sepolia Testnet
    expect(() => service.getSigner(11155111)).toThrow('SIGNER_PRIVATE_KEY is not set in the environment variables');
  });

  it('should create signer for valid EVM chain with private key', () => {
    // Állítsuk vissza a SIGNER_PRIVATE_KEY-t
    process.env.SIGNER_PRIVATE_KEY = '0x1234567890123456789012345678901234567890123456789012345678901234';
    
    const result = service.getSigner(11155111);
    expect(result).toBeTruthy();
    // Remove the null check issue
    if (result) {
      expect(result.address).toBeDefined();
    }
  });
});
