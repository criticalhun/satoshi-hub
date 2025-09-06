export interface Chain {
  id: number;
  name: string;
  isEvm: boolean;
  isTestnet: boolean;
  rpcUrl?: string;
}

export enum PayloadType {
  NATIVE_TOKEN_TRANSFER = 'NATIVE_TOKEN_TRANSFER',
}

export interface BasePayload {
  type: PayloadType;
}

export interface NativeTokenTransferPayload extends BasePayload {
  type: PayloadType.NATIVE_TOKEN_TRANSFER;
  to: string;
  amount: string; // The amount in 'ether' unit, e.g., "0.1"
}

export type TxPayload = NativeTokenTransferPayload;
