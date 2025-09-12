import { Injectable, Logger } from '@nestjs/common';
import { TransactionPayload } from '@satoshi-hub/sdk';
import { NativeTokenTransferProcessor } from './processors/native-token-transfer.processor';
import {
  IPayloadProcessor,
  ProcessedTxData,
} from './payload.interface';

@Injectable()
export class PayloadService {
  private readonly logger = new Logger(PayloadService.name);
  private processors: Map<string, IPayloadProcessor> = new Map();

  constructor(
    private readonly nativeTokenTransferProcessor: NativeTokenTransferProcessor,
  ) {
    // Csak a string literál használata a regisztrációhoz
    this.registerProcessor('transfer', this.nativeTokenTransferProcessor);
  }

  private registerProcessor(type: string, processor: IPayloadProcessor) {
    this.processors.set(type, processor);
    this.logger.log(`Registered processor for payload type: ${type}`);
  }

  async processPayload(
    payload: TransactionPayload,
    fromChainId: number,
    toChainId: number,
  ): Promise<ProcessedTxData> {
    const processor = this.processors.get(payload.type);
    if (!processor) {
      this.logger.error(`No processor found for payload type: ${payload.type}`);
      throw new Error(`Unsupported payload type: ${payload.type}`);
    }

    return processor.process(payload, fromChainId, toChainId);
  }
}
