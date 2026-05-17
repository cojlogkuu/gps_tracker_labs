import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LocationHistory } from '../entities/location-history.entity';
import { CreateLocationDto } from './dto/create-location.dto';

@Injectable()
export class LocationsService {
  constructor(
    @InjectRepository(LocationHistory)
    private readonly locations: Repository<LocationHistory>,
  ) {}

  async create(dto: CreateLocationDto): Promise<LocationHistory> {
    const location = this.locations.create(dto);
    return this.locations.save(location);
  }

  async getLatestForDevice(deviceId: string): Promise<LocationHistory> {
    const latest = await this.locations.findOne({
      where: { deviceId },
      order: { createdAt: 'DESC' },
    });
    if (!latest) throw new NotFoundException('No location found for this device');
    return latest;
  }
}
