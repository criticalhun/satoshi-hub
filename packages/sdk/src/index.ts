// Add exports for PayloadType, TxPayload, and NativeTokenTransferPayload

export enum PayloadType {
  NATIVE_TOKEN_TRANSFER = 'NATIVE_TOKEN_TRANSFER',
  // más típusok...
}

export interface TxPayload {
  type: PayloadType;
  // közös mezők...
}

export interface NativeTokenTransferPayload extends TxPayload {
  type: PayloadType.NATIVE_TOKEN_TRANSFER;
  amount: string;
  to: string;
  // egyéb specifikus mezők...
}