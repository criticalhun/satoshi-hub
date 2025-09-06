import { Test, TestingModule } from '@nestjs/testing';
import { TxController } from './tx.controller';
import { TxService } from './tx.service';

describe('TxController', () => {
  let controller: TxController;
  let txService: TxService;

  const mockTxService = {
    createTxJob: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TxController],
      providers: [
        {
          provide: TxService,
          useValue: mockTxService,
        },
      ],
    }).compile();

    controller = module.get<TxController>(TxController);
    txService = module.get<TxService>(TxService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should create a transaction job', async () => {
    const createTxDto = {
      fromChainId: 1,
      toChainId: 137,
      payload: { amount: '1.0', to: '0x123...' },
    };

    const expectedResult = {
      id: 'job-id-123',
      ...createTxDto,
      status: 'pending',
    };

    mockTxService.createTxJob.mockResolvedValue(expectedResult);

    const result = await controller.create(createTxDto);

    expect(result).toEqual(expectedResult);
    expect(mockTxService.createTxJob).toHaveBeenCalledWith(createTxDto);
  });
});
