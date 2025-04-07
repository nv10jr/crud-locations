import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNumber, IsOptional, IsUUID, Min } from 'class-validator';

export class CreateLocationDto {
  @ApiProperty({ description: 'Building identifier (e.g., A, B)' })
  @IsString()
  building: string;

  @ApiProperty({ description: 'Name of the location' })
  @IsString()
  locationName: string;

  @ApiProperty({ description: 'Location number (e.g., A-01, B-05-11)' })
  @IsString()
  locationNumber: string;

  @ApiProperty({ description: 'Area in square meters' })
  @IsNumber()
  @Min(0)
  area: number;

  @ApiProperty({ description: 'Parent location ID', required: false })
  @IsOptional()
  @IsUUID()
  parentId?: string;
} 