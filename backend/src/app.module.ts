import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import configuration from './config/configuration';
import { configValidationSchema } from './config/validation.schema';
import { AuthModule } from './auth/auth.module';
import { DatabaseModule } from './database/database.module';
import { DeliveryModule } from './delivery/delivery.module';
import { FarmerModule } from './farmer/farmer.module';
import { AdminModule } from './admin/admin.module';
import { OrdersModule } from './orders/orders.module';
import { UploadModule } from './upload/upload.module';
import { AddressesModule } from './addresses/addresses.module';
import { ProductsModule } from './products/products.module';
import { CartModule } from './cart/cart.module';
import { CategoriesModule } from './categories/categories.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: configValidationSchema,
    }),
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => [
        {
          ttl: config.get<number>('rateLimit.ttl') || 60,
          limit: config.get<number>('rateLimit.limit') || 100,
        },
      ],
    }),
    DatabaseModule,
    AuthModule,
    DeliveryModule,
    FarmerModule,
    AdminModule,
    OrdersModule,
    UploadModule,
    AddressesModule,
    ProductsModule,
    CartModule,
    CategoriesModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}