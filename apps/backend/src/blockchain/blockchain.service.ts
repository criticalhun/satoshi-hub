import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { getChainById } from '@satoshi-hub/sdk';
import { ethers } from 'ethers';

@Injectable()
export class BlockchainService {
  private readonly logger = new Logger(BlockchainService.name);
  private readonly privateKey: string;

  constructor(private readonly configService: ConfigService) {
    const pk = this.configService.get<string>('SIGNER_PRIVATE_KEY');
    if (!pk) {
      throw new Error(
        'SIGNER_PRIVATE_KEY is not set in the environment variables.',
      );
    }
    this.privateKey = pk;
  }

  getProvider(chainId: number): ethers.JsonRpcProvider {
    const chain = getChainById(chainId);
    if (!chain || !chain.rpcUrl) {
      this.logger.error(`No RPC URL configured for chainId: ${chainId}`);
      throw new Error(`Unsupported chainId: ${chainId}`);
    }
    return new ethers.JsonRpcProvider(chain.rpcUrl);
  }

  getSigner(chainId: number): ethers.Wallet {
    const provider = this.getProvider(chainId);
    const signer = new ethers.Wallet(this.privateKey, provider);
    this.logger.log(
      `Created signer for address ${signer.address} on chainId ${chainId}`,
    );
    return signer;
  }
}