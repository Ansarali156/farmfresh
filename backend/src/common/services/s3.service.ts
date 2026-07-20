import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { S3Client, PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';

export interface S3UploadResult {
  secure_url: string;
  public_id: string;
}

@Injectable()
export class S3Service {
  private readonly logger = new Logger(S3Service.name);
  private readonly s3Client: S3Client;
  private readonly bucketName: string;

  constructor(private readonly configService: ConfigService) {
    this.bucketName = this.configService.get<string>('AWS_S3_BUCKET_NAME') || '';
    const region = this.configService.get<string>('AWS_S3_REGION') || 'auto';
    const endpoint = this.configService.get<string>('AWS_S3_ENDPOINT');
    const accessKeyId = this.configService.get<string>('AWS_ACCESS_KEY_ID');
    const secretAccessKey = this.configService.get<string>('AWS_SECRET_ACCESS_KEY');

    if (accessKeyId && secretAccessKey) {
      this.s3Client = new S3Client({
        region,
        endpoint,
        credentials: {
          accessKeyId,
          secretAccessKey,
        },
        forcePathStyle: false, // Tigris usually works with virtual hosted style if endpoint allows, but let's try false or let SDK decide. Actually, for S3 compatible, many use path style or virtual host. We'll leave default.
      });
    }
  }

  isConfigured(): boolean {
    return !!this.s3Client && !!this.bucketName;
  }

  async uploadImage(
    fileBuffer: Buffer,
    folder: string,
    mimeType: string = 'image/jpeg',
  ): Promise<S3UploadResult> {
    if (!this.isConfigured()) {
      throw new BadRequestException('S3 storage is not configured');
    }

    try {
      const fileName = crypto.randomUUID();
      const objectKey = `${folder}/${fileName}`;

      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: objectKey,
        Body: fileBuffer,
        ContentType: mimeType,
      });

      await this.s3Client.send(command);

      // Generate the public URL assuming the bucket is public
      const endpointUrl = this.configService.get<string>('AWS_S3_ENDPOINT')?.replace(/\/$/, '') || 'https://s3.amazonaws.com';
      
      // Some endpoints support path style, some support virtual hosted. 
      // If endpoint is https://fly.storage.tigris.dev, the public URL is usually https://fly.storage.tigris.dev/bucket/key
      const secure_url = `${endpointUrl}/${this.bucketName}/${objectKey}`;

      return {
        secure_url,
        public_id: objectKey,
      };
    } catch (error) {
      this.logger.error('S3 Upload Error:', error);
      throw new BadRequestException(`Failed to upload image to S3: ${(error as Error).message}`);
    }
  }

  async deleteImage(publicId: string): Promise<any> {
    if (!this.isConfigured()) {
      return;
    }

    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: publicId,
      });

      await this.s3Client.send(command);
      return { result: 'ok' };
    } catch (error) {
      this.logger.error('S3 Delete Error:', error);
      throw new BadRequestException(`Failed to delete image from S3: ${(error as Error).message}`);
    }
  }
}
