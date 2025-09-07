import { IntegrationTestSetup } from '../integration-setup';
import { TxService } from '../../tx/tx.service';

describe('TxService Integration', () => {
  let setup: IntegrationTestSetup;
  let txService: TxService;

  beforeAll(async () => {
    setup = new IntegrationTestSetup();
    await setup.setup();
    txService = setup.app.get<TxService>(TxService);
  });

  afterAll(async () => {
    await setup.teardown();
  });

  describe('createTxJob', () => {
    it('should create transaction job in database', async () => {
      const createTxDto = {
        fromChainId: 11155111,
        toChainId: 80002,
        payload: {
          type: 'NATIVE_TOKEN_TRANSFER',
          to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
          amount: '0.1',
        },
      };

      // Act
      const result = await txService.createTxJob(createTxDto as any);

      // Assert - Database
      expect(result.id).toBeDefined();
      expect(result.status).toBe('pending');

      // Verify in database
      const dbJob = await setup.prisma.txJob.findUnique({
        where: { id: result.id },
      });

      expect(dbJob).toBeTruthy();
      expect(dbJob).not.toBeNull();
      
      if (dbJob) {
        expect(dbJob.status).toBe('pending');
        expect(dbJob.fromChainId).toBe(11155111);
        expect(dbJob.toChainId).toBe(80002);
      }
    });
  });
});
