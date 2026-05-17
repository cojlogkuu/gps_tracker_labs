import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LocationHistory } from '../entities/location-history.entity';
import { LocationsController } from './locations.controller';
import { LocationsService } from './locations.service';

@Module({
  imports: [TypeOrmModule.forFeature([LocationHistory])],
  controllers: [LocationsController],
  providers: [LocationsService],
})
export class LocationsModule {}
