import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { PrismaService } from '../database/prisma.service';

describe('HealthController', () => {
  let controller: HealthController;
  let prismaService: PrismaService;

  const mockPrismaService = {
    $queryRaw: jest.fn().mockResolvedValue([{ 1: 1 }]),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return system health status as OK when database is functional', async () => {
    mockPrismaService.$queryRaw.mockResolvedValueOnce([{ 1: 1 }]);

    const result = await controller.check();

    expect(result.status).toBe('OK');
    expect(result.services.application).toBe('UP');
    expect(result.services.database).toBe('HEALTHY');
    expect(prismaService.$queryRaw).toHaveBeenCalled();
  });

  it('should return database as UNHEALTHY and degraded state when database throws an error', async () => {
    mockPrismaService.$queryRaw.mockRejectedValueOnce(new Error('Connection failure'));

    const result = await controller.check();

    expect(result.status).toBe('DEGRADED');
    expect(result.services.application).toBe('UP');
    expect(result.services.database).toBe('UNHEALTHY');
  });
});
