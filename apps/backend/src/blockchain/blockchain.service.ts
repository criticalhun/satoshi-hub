import { Injectable } from '@nestjs/common';
import { Wallet } from 'ethers';
import { providers } from 'ethers';
import { CHAINS, Chain } from './chains.config';

@Injectable()
export class BlockchainService {
  // Új metódus: támogatott láncok ellenőrzése
  private isSupportedChain(chainId: number): boolean {
    return CHAINS.some((chain) => chain.chainId === chainId);
  }

  // Új metódus: EVM-kompatibilis láncok ellenőrzése
  private isEvmChain(chainId: number): boolean {
    const chain = CHAINS.find((c) => c.chainId === chainId);
    return chain?.type === 'evm';
  }

  // Provider lekérése egy adott lánchoz
  getProvider(chainId: number): providers.JsonRpcProvider | null {
    if (!this.isSupportedChain(chainId)) {
      throw new Error(`Unsupported chainId: ${chainId}`);
    }

    const chain = CHAINS.find((c) => c.chainId === chainId);
    
    if (!chain || chain.type !== 'evm') {
      return null;
    }

    return new providers.JsonRpcProvider(chain.rpcUrl);
  }

  // Signer lekérése egy adott lánchoz
  getSigner(chainId: number): Wallet | null {
    // 1. Ellenőrizzük, hogy a lánc támogatott-e
    if (!this.isSupportedChain(chainId)) {
      throw new Error(`Unsupported chainId: ${chainId}`);
    }
    
    // 2. Ellenőrizzük, hogy EVM lánc-e
    if (!this.isEvmChain(chainId)) {
      return null;
    }
    
    // 3. Ellenőrizzük, hogy a private key be van-e állítva
    const privateKey = process.env.SIGNER_PRIVATE_KEY;
    if (!privateKey) {
      throw new Error('SIGNER_PRIVATE_KEY is not set in the environment variables');
    }
    
    // 4. Provider létrehozása
    const provider = this.getProvider(chainId);
    if (!provider) {
      return null;
    }
    
    // 5. Wallet létrehozása a private key és provider segítségével
    return new Wallet(privateKey, provider);
  }

  // Provider és Signer együttes lekérése
  async getProviderAndSigner(chainId: number): Promise<{provider: providers.JsonRpcProvider | null, signer: Wallet | null}> {
    const provider = this.getProvider(chainId);
    const signer = this.getSigner(chainId);
    
    return { provider, signer };
  }

  // Chainlink VRF koordinátor címének lekérése
  getVrfCoordinatorAddress(chainId: number): string {
    const chain = CHAINS.find((c) => c.chainId === chainId);
    if (!chain) {
      throw new Error(`Unsupported chainId: ${chainId}`);
    }
    return chain.contracts?.vrfCoordinator || '';
  }
}
