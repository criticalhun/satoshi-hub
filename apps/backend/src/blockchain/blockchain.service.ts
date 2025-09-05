import { Injectable, Logger } from '@nestjs/common';
import { getChainById } from '@satoshi-hub/sdk';
import { ethers } from 'ethers';

@Injectable()
export class BlockchainService {
  private readonly logger = new Logger(BlockchainService.name);

  getProvider(chainId: number): ethers.JsonRpcProvider {
    const chain = getChainById(chainId);
    if (!chain || !chain.rpcUrl) {
      this.logger.error(`No RPC URL configured for chainId: ${chainId}`);
      throw new Error(`Unsupported chainId: ${chainId}`);
    }

    return new ethers.JsonRpcProvider(chain.rpcUrl);
  }
}