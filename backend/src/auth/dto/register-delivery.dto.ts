import { IsEmail, IsNotEmpty, IsString, MinLength, Matches, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDeliveryDto {
  @ApiProperty({ example: 'Amit', description: 'First name' })
  @IsNotEmpty()
  @IsString()
  firstName: string;

  @ApiProperty({ example: 'Rider', description: 'Last name', required: false })
  @IsOptional()
  @IsString()
  lastName?: string;

  @ApiProperty({ example: 'delivery@farmfresh.com', description: 'Email address' })
  @IsNotEmpty()
  @IsEmail()
  email: string;

  @ApiProperty({ example: '+911234567892', description: 'Contact phone number' })
  @IsNotEmpty()
  @IsString()
  @Matches(/^\+?(?:91)?[6-9]\d{9}$/, { message: 'Phone must be a valid 10-digit mobile number' })
  phone: string;

  @ApiProperty({ example: 'password123', description: 'Account password (minimum 8 characters)' })
  @IsNotEmpty()
  @MinLength(8)
  password: string;

  @ApiProperty({ example: 'DL-US-9988231', description: 'Rider Driving License ID', required: false })
  @IsOptional()
  @IsString()
  drivingLicenseNumber?: string;

  @ApiProperty({ example: 'Two-Wheeler', description: 'Type of transport vehicle', required: false })
  @IsOptional()
  @IsString()
  vehicleType?: string;

  @ApiProperty({ example: 'NY-882-AB', description: 'License plate number of vehicle', required: false })
  @IsOptional()
  @IsString()
  vehicleNumber?: string;

  @ApiProperty({ description: 'Confirm password field', required: false })
  @IsOptional()
  @IsString()
  confirmPassword?: string;
}


