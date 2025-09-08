import { Test, TestingModule } from '@nestjs/testing';
import { TxController } from './tx.controller';
import { TxService } from './tx.service';
import { CreateTxJobDto } from './dto/create-tx-job.dto';

describe('TxController', () => {
  let controller: TxController;
  let txService: TxService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TxController],
      providers: [
        {
          provide: TxService,
          useValue: {
            create: jest.fn().mockImplementation((dto) => {
              return {
                id: 'test-id',
                fromChainId: dto.fromChainId,
                toChainId: dto.toChainId,
                payload: JSON.stringify(dto.payload),
                status: 'pending',
                createdAt: new Date(),
                updatedAt: new Date(),
              };
            }),
            findOne: jest.fn().mockImplementation((id) => {
              return {
                id,
                fromChainId: 1,
                toChainId: 2,
                payload: JSON.stringify({
                  type: 'transfer',
                  to: '0x123',
                  amount: '0.1',
                }),
                status: 'pending',
                createdAt: new Date(),
                updatedAt: new Date(),
              };
            }),
            findAll: jest.fn().mockImplementation(() => {
              return {
                data: [],
                meta: {
                  total: 0,
                  page: 1,
                  limit: 10,
                  lastPage: 1,
                },
              };
            }),
          },
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
    const createTxDto: CreateTxJobDto = {
      fromChainId: 1,
      toChainId: 2,
      payload: {
        type: 'transfer',
        to: '0x123',
        amount: '0.1',
      },
    };

    const result = await controller.create(createTxDto);
    expect(txService.create).toHaveBeenCalledWith(createTxDto);
    expect(result).toHaveProperty('id');
    expect(result.fromChainId).toBe(createTxDto.fromChainId);
    expect(result.toChainId).toBe(createTxDto.toChainId);
  });

  it('should find a transaction job by id', async () => {
    const id = 'test-id';
    const result = await controller.findOne(id);
    expect(txService.findOne).toHaveBeenCalledWith(id);
    expect(result).toHaveProperty('id', id);
  });

  it('should find all transaction jobs', async () => {
    const result = await controller.findAll();
    expect(txService.findAll).toHaveBeenCalled();
    expect(result).toHaveProperty('data');
    expect(result).toHaveProperty('meta');
  });
});
