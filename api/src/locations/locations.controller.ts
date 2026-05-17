import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateLocationDto } from './dto/create-location.dto';
import { LocationsService } from './locations.service';

@Controller()
@UseGuards(JwtAuthGuard)
export class LocationsController {
  constructor(private readonly locationsService: LocationsService) {}

  @Post('locations')
  create(@Body() dto: CreateLocationDto) {
    return this.locationsService.create(dto);
  }

  @Get('devices/:id/latest-location')
  getLatest(@Param('id') id: string) {
    return this.locationsService.getLatestForDevice(id);
  }
}
