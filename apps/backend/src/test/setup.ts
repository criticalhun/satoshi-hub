import { ConfigModule } from '@nestjs/config';

// Load test environment variables
ConfigModule.forRoot({
  envFilePath: '.env.test',
  isGlobal: true,
});

// Increase timeout for integration tests
jest.setTimeout(30000);
