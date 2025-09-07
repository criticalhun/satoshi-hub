// apps/backend/src/payload/processors/native-token-transfer.processor.ts
import { Injectable, Logger } from '@nestjs/common';
import { IPayloadProcessor, ProcessedTxData } from '../payload.interface';
import { NativeTokenTransferPayload, PayloadType, TransactionPayload } from '@satoshi-hub/sdk';
import { ethers } from 'ethers';

@Injectable()
export class NativeTokenTransferProcessor implements IPayloadProcessor {
  private readonly logger = new Logger(NativeTokenTransferProcessor.name);

  async process(payload: TransactionPayload): Promise<ProcessedTxData> {
    if (payload.type !== PayloadType.NATIVE_TOKEN_TRANSFER) {
      throw new Error(`Invalid payload type: ${payload.type}`);
    }

    const p = payload as NativeTokenTransferPayload;
    this.logger.log(`Processing native token transfer to ${p.to} amount ${p.amount}`);

    // JAVÍTÁS: ethers v5 szintaxis
    const amountInWei = ethers.utils.parseUnits(p.amount, 'ether');

    return {
      to: p.to,
      value: amountInWei,
      data: '0x',
    };
  }
}