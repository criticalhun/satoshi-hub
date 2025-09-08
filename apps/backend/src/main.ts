import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CORS beállítások
  app.enableCors({
    origin: true, // Minden origin engedélyezése fejlesztési módban
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
    allowedHeaders: 'Content-Type,Accept,Authorization',
  });
  
  app.useGlobalPipes(new ValidationPipe());
  await app.listen(3001);
}
bootstrap();
