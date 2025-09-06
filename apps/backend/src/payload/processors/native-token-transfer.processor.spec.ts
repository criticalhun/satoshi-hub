import { NativeTokenTransferProcessor } from './native-token-transfer.processor';

describe('NativeTokenTransferProcessor', () => {
  let processor: NativeTokenTransferProcessor;

  beforeEach(() => {
    processor = new NativeTokenTransferProcessor();
  });

  it('should be defined', () => {
    expect(processor).toBeDefined();
  });

  // Példa: ha van process metódus
  it('should process transfer payload', async () => {
    const payload = { amount: 1, to: '0x123...' };
    // expect(await processor.process(payload)).toBeTruthy();
  });
});
