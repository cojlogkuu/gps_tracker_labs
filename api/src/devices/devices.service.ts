import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Device } from '../entities/device.entity';
import { CreateDeviceDto } from './dto/create-device.dto';

@Injectable()
export class DevicesService {
  constructor(
    @InjectRepository(Device) private readonly devices: Repository<Device>,
  ) {}

  async create(userId: string, dto: CreateDeviceDto): Promise<Device> {
    const device = this.devices.create({ ...dto, userId });
    return this.devices.save(device);
  }

  async findByUser(userId: string): Promise<Device[]> {
    return this.devices.find({ where: { userId } });
  }
}
