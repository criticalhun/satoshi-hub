import { ethers } from 'ethers';
import { TxPayload } from '@satoshi-hub/sdk';

export interface ProcessedTxData {
  to: string;
  value: ethers.BigNumberish;
  data: string;
}

export interface IPayloadProcessor {
  process(payload: TxPayload): Promise<ProcessedTxData>;
}
