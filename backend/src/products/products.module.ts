import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { FarmerProductsController } from './farmer-products.controller';
import { S3Service } from '../common/services/s3.service';

@Module({
  controllers: [ProductsController, FarmerProductsController],
  providers: [ProductsService, S3Service],
  exports: [ProductsService],
})
export class ProductsModule {}
