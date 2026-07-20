import { Controller, Post, UseGuards, Body, UseInterceptors, UploadedFile, ParseFilePipe, MaxFileSizeValidator, FileTypeValidator, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { RolesGuard } from '../common/guards/roles.guard';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';
import { S3Service } from '../common/services/s3.service';
import { AuthService } from '../auth/auth.service';

@Controller('upload')
@ApiTags('File Upload')
@UseGuards(RolesGuard)
export class UploadController {
  constructor(
    private readonly s3Service: S3Service,
    private readonly authService: AuthService,
  ) {}

  @Post('profile-picture')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Upload or replace profile picture' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('image'))
  async uploadProfilePicture(
    @CurrentUser() user: CurrentUserPayload,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 2048000 }),
          new FileTypeValidator({ fileType: /.(jpg|jpeg|png|webp)$/i }),
        ],
      }),
    )
    file: Express.Multer.File,
  ) {
    if (!this.s3Service.isConfigured()) {
      return { success: false, message: 'S3 storage is not configured. Profile picture upload is currently unavailable.' };
    }

    const uploadResult = await this.s3Service.uploadImage(file.buffer, 'farmfresh-profile-pictures', file.mimetype);

    const userProfile = await this.authService.getProfile(user.id);
    const oldAvatar = userProfile.avatar;

    await this.authService.updateProfile(user.id, undefined, undefined, undefined, undefined, uploadResult.secure_url);

    if (oldAvatar && oldAvatar.includes('farmfresh-profile-pictures/')) {
      const oldPublicId = 'farmfresh-profile-pictures/' + oldAvatar.split('/farmfresh-profile-pictures/')[1];
      if (oldPublicId) {
        await this.s3Service.deleteImage(oldPublicId);
      }
    }

    return {
      success: true,
      message: 'Profile picture uploaded successfully',
      data: {
        imageUrl: uploadResult.secure_url,
        publicId: uploadResult.public_id,
      },
    };
  }

  @Post('profile-picture/remove')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Remove profile picture' })
  @HttpCode(HttpStatus.OK)
  async removeProfilePicture(
    @CurrentUser() user: CurrentUserPayload,
  ) {
    if (!this.s3Service.isConfigured()) {
      return { success: false, message: 'S3 storage is not configured. Profile picture removal is currently unavailable.' };
    }

    const userProfile = await this.authService.getProfile(user.id);
    const currentAvatar = userProfile.avatar;

    if (!currentAvatar || !currentAvatar.includes('farmfresh-profile-pictures/')) {
      return { success: false, message: 'No profile picture found to remove' };
    }

    const oldPublicId = 'farmfresh-profile-pictures/' + currentAvatar.split('/farmfresh-profile-pictures/')[1];
    if (oldPublicId) {
      await this.s3Service.deleteImage(oldPublicId);
    }

    await this.authService.updateProfile(user.id, undefined, undefined, undefined, undefined, '');

    return {
      success: true,
      message: 'Profile picture removed successfully',
      data: { removed: true, avatar: null },
    };
  }
}
