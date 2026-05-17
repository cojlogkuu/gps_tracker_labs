import { IsNumber } from 'class-validator';

export class UpdateBaseCoordsDto {
  @IsNumber()
  baseLatitude: number;

  @IsNumber()
  baseLongitude: number;
}
