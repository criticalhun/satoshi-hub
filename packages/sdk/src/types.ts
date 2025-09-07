// Payload types
export enum PayloadType {
  NATIVE_TOKEN_TRANSFER = 'NATIVE_TOKEN_TRANSFER',
  ERC20_TRANSFER = 'ERC20_TRANSFER',
  NFT_TRANSFER = 'NFT_TRANSFER',
}

export interface NativeTokenTransferPayload {
  type: PayloadType.NATIVE_TOKEN_TRANSFER;
  to: string;
  amount: string;
}

export interface ERC20TransferPayload {
  type: PayloadType.ERC20_TRANSFER;
  to: string;
  amount: string;
  tokenAddress: string;
}

export interface NFTTransferPayload {
  type: PayloadType.NFT_TRANSFER;
  to: string;
  tokenAddress: string;
  tokenId: string;
}

export type TransactionPayload = 
  | NativeTokenTransferPayload 
  | ERC20TransferPayload 
  | NFTTransferPayload;

// Transaction types
export interface TransactionRequest {
  fromChainId: number;
  toChainId: number;
  payload: TransactionPayload;
}

export interface TransactionJob {
  id: string;
  fromChainId: number;
  toChainId: number;
  payload: TransactionPayload;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  result?: {
    txHash?: string;
    error?: string;
  };
  createdAt: Date;
  updatedAt: Date;
}

// Chain types
export interface ChainInfo {
  chainId: number;
  name: string;
  shortName: string;
  networkId: number;
  nativeCurrency: {
    name: string;
    symbol: string;
    decimals: number;
  };
  rpc: string[];
  faucets: string[];
  explorers: Array<{
    name: string;
    url: string;
    standard: string;
  }>;
  infoURL: string;
  isEVM: boolean;
  testnet: boolean;
}
