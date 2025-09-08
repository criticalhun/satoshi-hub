import { ethers } from 'ethers';
import { TransactionPayload } from '@satoshi-hub/sdk';

// This is the data our processors will return
export interface ProcessedTxData {
  to: string;
  value: ethers.BigNumberish; // JAVÍTÁS: String-ről BigNumberish-re
  data: string;
}

// All payload processors must implement this interface
export interface IPayloadProcessor {
  process(payload: TransactionPayload): Promise<ProcessedTxData>;
}
