import { Injectable, Logger } from '@nestjs/common';
import { IPayloadProcessor, ProcessedTxData } from '../payload.interface';
import { NativeTokenTransferPayload, PayloadType, TxPayload } from '@satoshi-hub/sdk';
import { ethers } from 'ethers';

@Injectable()
export class NativeTokenTransferProcessor implements IPayloadProcessor {
  private readonly logger = new Logger(NativeTokenTransferProcessor.name);

  async process(payload: TxPayload): Promise<ProcessedTxData> {
    if (payload.type !== PayloadType.NATIVE_TOKEN_TRANSFER) {
      throw new Error('Invalid payload type for NativeTokenTransferProcessor');
    }

    const p = payload as NativeTokenTransferPayload;
    this.logger.log(`Processing native token transfer to ${p.to} for amount ${p.amount}`);

    const amountInWei = ethers.parseUnits(p.amount, 'ether');

    return {
      to: p.to,
      value: amountInWei,
      data: '0x',
    };
  }
}
