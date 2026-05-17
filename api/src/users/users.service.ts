import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { UpdateBaseCoordsDto } from './dto/update-base-coords.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
  ) {}

  async updateBaseCoords(userId: string, dto: UpdateBaseCoordsDto): Promise<User> {
    const user = await this.users.findOneBy({ id: userId });
    if (!user) throw new NotFoundException('User not found');

    user.baseLatitude = dto.baseLatitude;
    user.baseLongitude = dto.baseLongitude;
    return this.users.save(user);
  }

  async findById(id: string): Promise<User | null> {
    return this.users.findOneBy({ id });
  }
}
