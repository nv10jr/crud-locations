import { Entity, Column, Tree, TreeChildren, TreeParent, PrimaryGeneratedColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity()
@Tree('closure-table')
export class Location {
  @PrimaryGeneratedColumn('uuid')
  @ApiProperty({ description: 'Unique identifier for the location' })
  id: string;

  @Column()
  @ApiProperty({ description: 'Building identifier (e.g., A, B)' })
  building: string;

  @Column()
  @ApiProperty({ description: 'Name of the location' })
  locationName: string;

  @Column({ unique: true })
  @ApiProperty({ description: 'Location number (e.g., A-01, B-05-11)' })
  locationNumber: string;

  @Column('decimal', { precision: 10, scale: 3 })
  @ApiProperty({ description: 'Area in square meters' })
  area: number;

  @TreeChildren()
  children: Location[];

  @TreeParent()
  parent: Location;
} 