import { Injectable, Logger } from '@nestjs/common';
import { IPayloadProcessor, ProcessedTxData } from '../payload.interface';
import { NativeTokenTransferPayload, PayloadType, TransactionPayload } from '@satoshi-hub/sdk';
import { ethers } from 'ethers';

@Injectable()
export class NativeTokenTransferProcessor implements IPayloadProcessor {
  private readonly logger = new Logger(NativeTokenTransferProcessor.name);

  async process(
    payload: TransactionPayload,
    fromChainId: number,
    toChainId: number,
  ): Promise<ProcessedTxData> {
    // Egyszerűbb ellenőrzés, nem használunk enum összehasonlítást
    const transferPayload = payload as NativeTokenTransferPayload;

    // Ellenőrizzük a szükséges mezőket
    if (!transferPayload.to || !transferPayload.amount) {
      throw new Error('Missing required fields in payload: to or amount');
    }

    this.logger.log(`Processing native token transfer: ${transferPayload.amount} to ${transferPayload.to}`);

    // Készítsük el a tranzakció adatait
    return {
      to: transferPayload.to,
      value: ethers.utils.parseEther(transferPayload.amount),
      data: undefined,
    };
  }
}
