import { IsEmail, IsNotEmpty, IsString, MinLength, Matches, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterFarmerDto {
  @ApiProperty({ example: 'John Farmer', description: 'Full personal name' })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({ example: 'farmer@farmfresh.com', description: 'Email address' })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({ example: '+911234567891', description: 'Contact phone number' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+?(?:91)?[6-9]\d{9}$/, { message: 'Phone must be a valid 10-digit mobile number' })
  phone: string;

  @ApiProperty({ example: 'password123', description: 'Account password (minimum 8 characters)' })
  @IsNotEmpty()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'Green Valley Farms', description: 'Name of the farm entity', required: false })
  @IsOptional()
  @IsString()
  farmName?: string;

  @ApiProperty({ example: '123 Santorini Road, Greece', description: 'Physical address of the farm', required: false })
  @IsOptional()
  @IsString()
  farmAddress?: string;

  @ApiProperty({ example: 'TAXID-8829-GR', description: 'Government registered Tax ID or license number', required: false })
  @IsOptional()
  @IsString()
  governmentId?: string;

  @ApiProperty({ example: 'State Bank - routing 021000021 - acct 12345678', description: 'Bank transfer details for payouts', required: false })
  @IsOptional()
  @IsString()
  bankAccountDetails?: string;

  @ApiProperty({ example: 'https://images.unsplash.com/profile-photo', description: 'Profile picture URL', required: false })
  @IsOptional()
  @IsString()
  profilePhoto?: string;
}
