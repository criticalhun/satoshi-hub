import { IntegrationTestSetup } from '../integration-setup';
import request from 'supertest';

describe('TX API Integration', () => {
  let setup: IntegrationTestSetup;

  beforeAll(async () => {
    setup = new IntegrationTestSetup();
    await setup.setup();
  });

  afterAll(async () => {
    await setup.teardown();
  });

  describe('POST /tx', () => {
    it('should create transaction through complete flow', async () => {
      const payload = {
        fromChainId: 11155111,
        toChainId: 80002,
        payload: {
          type: 'NATIVE_TOKEN_TRANSFER',
          to: '0x742d35Cc85DDfE0BC28B6f5b4b49E46DB1E33d2A',
          amount: '0.1',
        },
      };

      // Act
      const response = await request(setup.app.getHttpServer())
        .post('/tx')
        .send(payload)
        .expect(201);

      // Assert API response
      expect(response.body.id).toBeDefined();
      expect(response.body.status).toBe('pending');

      // Assert Database state
      const dbJob = await setup.prisma.txJob.findUnique({
        where: { id: response.body.id },
      });

      expect(dbJob).toBeTruthy();
      expect(dbJob).not.toBeNull();
      
      if (dbJob) {
        expect(dbJob.status).toBe('pending');
      }
    });

    it('should validate payload and return 400 for invalid data', async () => {
      const invalidPayload = {
        fromChainId: 'not-a-number', // String instead of number
        toChainId: 80002,
        payload: null, // Invalid payload
      };

      const response = await request(setup.app.getHttpServer())
        .post('/tx')
        .send(invalidPayload)
        .expect(400);

      expect(response.body.message).toBeDefined();
    });
  });
});
