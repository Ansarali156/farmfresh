import { Module } from '@nestjs/common';
import { FarmerController } from './farmer.controller';
import { WithdrawalsController } from './withdrawals.controller';
import { FarmerService } from './farmer.service';

@Module({
  controllers: [FarmerController, WithdrawalsController],
  providers: [FarmerService],
})
export class FarmerModule {}
