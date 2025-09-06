import { Injectable, Logger } from '@nestjs/common';
import { ethers } from 'ethers';
import { ConfigService } from '@nestjs/config';
import { SUPPORTED_CHAINS, ChainConfig } from './chains.config';

@Injectable()
export class BlockchainService {
  private readonly logger = new Logger(BlockchainService.name);

  constructor(private readonly configService: ConfigService) {}

  private getChainConfig(chainId: number): ChainConfig {
    const chain = SUPPORTED_CHAINS.find((chain) => chain.chainId === chainId);
    if (!chain) {
      throw new Error(`Unsupported chainId: ${chainId}`);
    }
    return chain;
  }

  getSigner(chainId: number): ethers.Wallet | null {
    const chainConfig = this.getChainConfig(chainId);
    if (chainConfig.chainId === -1) {
      this.logger.error(`Non-EVM chain detected: ${chainConfig.name}. Signer not applicable.`);
      return null;
    }

    const rpcUrl = chainConfig.rpcUrl;
    this.logger.log(`Connecting to RPC URL: ${rpcUrl} for chainId: ${chainId}`);
    
    // Javított provider az ethers v5 szintaxissal
    const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
    
    const privateKey = this.configService.get<string>('SIGNER_PRIVATE_KEY');
    if (!privateKey) {
      throw new Error('SIGNER_PRIVATE_KEY is not set in the environment variables');
    }
    const signer = new ethers.Wallet(privateKey, provider);

    this.logger.log(`Created signer for address ${signer.address} on chainId ${chainId}`);
    return signer;
  }