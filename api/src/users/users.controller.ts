import { Body, Controller, Put, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UpdateBaseCoordsDto } from './dto/update-base-coords.dto';
import { UsersService } from './users.service';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Put('base-coordinates')
  updateBaseCoords(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateBaseCoordsDto,
  ) {
    return this.usersService.updateBaseCoords(user.id, dto);
  }
}
