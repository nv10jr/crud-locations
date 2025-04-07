import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNumber, IsOptional, IsUUID, Min } from 'class-validator';

export class UpdateLocationDto {
  @ApiProperty({ description: 'Building identifier (e.g., A, B)', required: false })
  @IsOptional()
  @IsString()
  building?: string;

  @ApiProperty({ description: 'Name of the location', required: false })
  @IsOptional()
  @IsString()
  locationName?: string;

  @ApiProperty({ description: 'Location number (e.g., A-01, B-05-11)', required: false })
  @IsOptional()
  @IsString()
  locationNumber?: string;

  @ApiProperty({ description: 'Area in square meters', required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  area?: number;

  @ApiProperty({ description: 'Parent location ID', required: false })
  @IsOptional()
  @IsUUID()
  parentId?: string;
} 