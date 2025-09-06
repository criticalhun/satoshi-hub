import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(() => {
    service = new PrismaService();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // Ha van valamilyen metódus
  // it('should return data', async () => {
  //   expect(await service.findSomething()).toBeTruthy();
  // });
});
