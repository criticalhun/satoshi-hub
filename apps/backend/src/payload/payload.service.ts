import { Injectable, Logger } from '@nestjs/common';
import { PayloadType, TxPayload } from '@satoshi-hub/sdk';
import { NativeTokenTransferProcessor } from './processors/native-token-transfer.processor';
import {
  IPayloadProcessor,
  ProcessedTxData,
} from './payload.interface';

@Injectable()
export class PayloadService {
  private readonly logger = new Logger(PayloadService.name);
  private processors: Map<PayloadType, IPayloadProcessor> = new Map();

  constructor(
    private readonly nativeTokenTransferProcessor: NativeTokenTransferProcessor,
  ) {
    this.processors.set(
      PayloadType.NATIVE_TOKEN_TRANSFER,
      this.nativeTokenTransferProcessor,
    );
  }

  process(payload: TxPayload): Promise<ProcessedTxData> {
    const processor = this.processors.get(payload.type);

    if (!processor) {
      this.logger.error(`No processor found for payload type: ${payload.type}`);
      throw new Error(`Unsupported payload type: ${payload.type}`);
    }

    this.logger.log(`Delegating to processor for type: ${payload.type}`);
    return processor.process(payload);
  }
}
