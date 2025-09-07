import { Module } from '@nestjs/common';
import { TxController } from '../tx/tx.controller';
import { TxService } from '../tx/tx.service';

// Test version of TxModule without BullMQ workers
@Module({
  controllers: [TxController],
  providers: [
    TxService,
    // Mock queue provider
    {
      provide: 'BullQueue_tx-queue',
      useValue: {
        add: jest.fn().mockResolvedValue({ id: 'mock-job-id' }),
        getJobs: jest.fn().mockResolvedValue([]),
        drain: jest.fn().mockResolvedValue(undefined),
      },
    },
  ],
  exports: [TxService],
})
export class TxTestModule {}
