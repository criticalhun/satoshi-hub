import { Module } from '@nestjs/common';
import { PayloadService } from './payload.service';
import { NativeTokenTransferProcessor } from './processors/native-token-transfer.processor';

@Module({
  providers: [PayloadService, NativeTokenTransferProcessor],
  exports: [PayloadService],
})
export class PayloadModule {}
