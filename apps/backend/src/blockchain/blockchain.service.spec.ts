import { Test, TestingModule } from '@nestjs/testing';
import { BlockchainService } from './blockchain.service';
import { ConfigService } from '@nestjs/config';
import { ethers } from 'ethers';

// Mock ConfigService
class MockConfigService {
  get(key: string) {
    if (key === 'SIGNER_PRIVATE_KEY') {
      return '0x0000000000000000000000000000000000000000000000000000000000000001';
    }
    return null;
  }
}

// Mock SUPPORTED_CHAINS
jest.mock('./chains.config', () => ({
  SUPPORTED_CHAINS: [
    { chainId: 1, name: 'Ethereum', rpcUrl: 'http://localhost:8545' }
  ],
}));

describe('BlockchainService', () => {
  let service: BlockchainService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BlockchainService,
        { provide: ConfigService, useClass: MockConfigService },
      ],
    }).compile();

    service = module.get<BlockchainService>(BlockchainService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should throw on unsupported chain', () => {
    expect(() => service['getChainConfig'](42)).toThrow('Unsupported chainId: 42');
  });

  it('should return a signer for supported chain', () => {
    const signer = service.getSigner(1);
    expect(signer).not.toBeNull();
    expect((signer as ethers.Wallet).address).toBeDefined();
  });

  it('should throw if SIGNER_PRIVATE_KEY is missing', () => {
    // Mock ConfigService without key
    const module = new BlockchainService({ get: () => null } as any);
    expect(() => module.getSigner(1)).toThrow('SIGNER_PRIVATE_KEY is not set in the environment variables');
  });
});