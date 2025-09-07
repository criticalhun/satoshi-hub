import { Test, TestingModule } from '@nestjs/testing';
import { NativeTokenTransferProcessor } from './native-token-transfer.processor';
import { PayloadType, NativeTokenTransferPayload } from '@satoshi-hub/sdk';
import { ethers } from 'ethers';

describe('NativeTokenTransferProcessor', () => {
  let processor: NativeTokenTransferProcessor;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [NativeTokenTransferProcessor],
    }).compile();

    processor = module.get<NativeTokenTransferProcessor>(NativeTokenTransferProcessor);
  });

  it('should be defined', () => {
    expect(processor).toBeDefined();
  });

  it('should process native token transfer payload', async () => {
    const payload: NativeTokenTransferPayload = {
      type: PayloadType.NATIVE_TOKEN_TRANSFER,
      to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
      amount: '1.5',
    };

    const result = await processor.process(payload);

    expect(result.to).toBe('0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A');
    expect(result.data).toBe('0x');
    expect(ethers.utils.formatEther(result.value)).toBe('1.5');
  });

  it('should handle small amounts correctly', async () => {
    const payload: NativeTokenTransferPayload = {
      type: PayloadType.NATIVE_TOKEN_TRANSFER,
      to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
      amount: '0.001',
    };

    const result = await processor.process(payload);
    expect(ethers.utils.formatEther(result.value)).toBe('0.001');
  });

  it('should throw error for invalid payload type', async () => {
    const payload = {
      type: 'WRONG_TYPE' as any,
      to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
      amount: '1.0',
    };

    await expect(processor.process(payload as any)).rejects.toThrow('Invalid payload type: WRONG_TYPE');
  });

  it('should handle zero amount', async () => {
    const payload: NativeTokenTransferPayload = {
      type: PayloadType.NATIVE_TOKEN_TRANSFER,
      to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
      amount: '0',
    };

    const result = await processor.process(payload);
    expect(ethers.utils.formatEther(result.value)).toBe('0.0');
  });
});
