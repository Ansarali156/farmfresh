import { Controller, Get, Post, Body, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { FarmerService } from './farmer.service';
import { SuccessResponseDto } from '../common/dto/api-response.dto';

@ApiTags('Withdrawals')
@Controller('withdrawals')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class WithdrawalsController {
  constructor(private readonly farmerService: FarmerService) {}

  @Get()
  @ApiOperation({ summary: 'Get payout withdrawals history for authenticated user' })
  async getWithdrawals(@Req() req: any, @Query('page') page?: string, @Query('limit') limit?: string) {
    const pageNum = parseInt(page || '1', 10);
    const limitNum = parseInt(limit || '20', 10);
    const data = await this.farmerService.getWithdrawals(req.user.id, pageNum, limitNum);
    return new SuccessResponseDto('Withdrawals history retrieved', data);
  }

  @Post()
  @ApiOperation({ summary: 'Request payout withdrawal' })
  async requestWithdrawal(@Req() req: any, @Body() body: { amount: number; bankAccountId?: string }) {
    const data = await this.farmerService.requestWithdrawal(req.user.id, Number(body.amount));
    return new SuccessResponseDto('Withdrawal request submitted successfully', data);
  }
}
