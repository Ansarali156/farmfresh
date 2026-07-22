import { IsNotEmpty, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LoginDto {
  @ApiPropertyOptional({ example: 'customer@farmfresh.com', description: 'User email' })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({ example: 'customer@farmfresh.com', description: 'User username or phone' })
  @IsOptional()
  @IsString()
  username?: string;

  @ApiPropertyOptional({ example: 'CUSTOMER', description: 'Selected portal role' })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiProperty({ example: 'password123', description: 'Account password' })
  @IsNotEmpty()
  @IsString()
  @MinLength(6)
  password: string;
}
