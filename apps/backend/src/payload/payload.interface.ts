import { TransactionPayload } from '@satoshi-hub/sdk';

export interface ProcessedTxData {
  to: string;
  value: string;
  data: string;
}

export interface IPayloadProcessor {
  process(payload: TransactionPayload): Promise<ProcessedTxData>;
}
