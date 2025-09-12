import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { config } from 'dotenv';

// Betöltjük a környezeti változókat az alkalmazás indítása előtt
config();

// Naplózzuk a környezeti változók betöltését
console.log('Environment loaded. PRIVATE_KEY is ' + (process.env.PRIVATE_KEY ? 'set' : 'not set'));

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CORS beállítása
  app.enableCors({
    origin: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });
  
  // Validáció beállítása
  app.useGlobalPipes(new ValidationPipe({ transform: true }));
  
  await app.listen(3001);
}
bootstrap();
