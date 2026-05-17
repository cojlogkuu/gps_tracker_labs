import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import * as bcrypt from 'bcrypt';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto): Promise<{ access_token: string }> {
    const exists = await this.users.findOneBy({ email: dto.email });
    if (exists) throw new ConflictException('Email already in use');

    const password = await bcrypt.hash(dto.password, 12);
    const user = await this.users.save(
      this.users.create({ ...dto, password }),
    );
    return { access_token: this._sign(user) };
  }

  async login(dto: LoginDto): Promise<{ access_token: string; user: object }> {
    const user = await this.users.findOneBy({ email: dto.email });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const valid = await bcrypt.compare(dto.password, user.password);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    return { access_token: this._sign(user), user: this._toPublic(user) };
  }

  private _sign(user: User): string {
    return this.jwt.sign({ sub: user.id, email: user.email });
  }

  private _toPublic(user: User) {
    const { id, fullName, email, baseLatitude, baseLongitude } = user;
    return { id, fullName, email, baseLatitude, baseLongitude };
  }
}
