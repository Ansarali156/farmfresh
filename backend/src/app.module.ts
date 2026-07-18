import { Module } from '@nestjs/common';
<<<<<<< HEAD
import { AppController } from './app.controller';
import { AppService } from './app.service';
=======
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import configuration from './config/configuration';
import { configValidationSchema } from './config/validation.schema';
import { DatabaseModule } from './database/database.module';
>>>>>>> 4ad92b17b67899f5b06673a020e559d1bb207f20
import { AuthModule } from './auth/auth.module';
import { DatabaseModule } from './database/database.module';
import { DeliveryModule } from './delivery/delivery.module';
import { FarmerModule } from './farmer/farmer.module';
import { AdminModule } from './admin/admin.module';
import { OrdersModule } from './orders/orders.module';
import { UploadModule } from './upload/upload.module';
import { UserRepository } from './user/user.repository';
import { CloudinaryService } from './common/services/cloudinary.service';

@Module({
  imports: [
<<<<<<< HEAD
=======
    // Static file serving for uploads
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', '..', 'public'),
      serveRoot: '/public',
    }),
    // Global environment variables profile config loading
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validationSchema: configValidationSchema,
    }),
    
    // API Rate-limiting configuration
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
>>>>>>> 4ad92b17b67899f5b06673a020e559d1bb207f20
    AuthModule,
    DatabaseModule,
    DeliveryModule,
    FarmerModule,
    AdminModule,
    OrdersModule,
    UploadModule,
  ],
  controllers: [AppController],
  providers: [AppService, UserRepository, CloudinaryService],
})
export class AppModule {}