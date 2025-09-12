import { ethers } from 'ethers';
import { TransactionPayload } from '@satoshi-hub/sdk';

// This is the data our processors will return
export interface ProcessedTxData {
  // A célcím
  to: string;
  // Az érték (ETH/natív token)
  value: ethers.BigNumber;
  // Adat (ha van)
  data?: string;
}

// Interface for payload processors
export interface IPayloadProcessor {
  process(
    payload: TransactionPayload,
    fromChainId: number,
    toChainId: number
  ): Promise<ProcessedTxData>;
}
