import { IsNumber, IsUUID } from 'class-validator';

export class CreateLocationDto {
  @IsUUID()
  deviceId: string;

  @IsNumber()
  latitude: number;

  @IsNumber()
  longitude: number;
}
