import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { TreeRepository } from 'typeorm';
import { Location } from './entities/location.entity';
import { CreateLocationDto } from './dto/create-location.dto';
import { UpdateLocationDto } from './dto/update-location.dto';

@Injectable()
export class LocationsService {
  constructor(
    @InjectRepository(Location)
    private locationRepository: TreeRepository<Location>,
  ) {}

  async create(createLocationDto: CreateLocationDto): Promise<Location> {
    const location = this.locationRepository.create(createLocationDto);

    if (createLocationDto.parentId) {
      const parent = await this.locationRepository.findOne({
        where: { id: createLocationDto.parentId },
      });

      if (!parent) {
        throw new NotFoundException('Parent location not found');
      }

      location.parent = parent;
    }

    return this.locationRepository.save(location);
  }

  async findAll(): Promise<Location[]> {
    return this.locationRepository.findTrees();
  }

  async findOne(id: string): Promise<Location> {
    const location = await this.locationRepository.findOne({
      where: { id },
      relations: ['children', 'parent'],
    });

    if (!location) {
      throw new NotFoundException('Location not found');
    }

    return location;
  }

  async update(id: string, updateLocationDto: UpdateLocationDto): Promise<Location> {
    const location = await this.findOne(id);

    if (updateLocationDto.parentId) {
      if (updateLocationDto.parentId === id) {
        throw new BadRequestException('Location cannot be its own parent');
      }

      const parent = await this.locationRepository.findOne({
        where: { id: updateLocationDto.parentId },
      });

      if (!parent) {
        throw new NotFoundException('Parent location not found');
      }

      location.parent = parent;
    }

    Object.assign(location, updateLocationDto);
    return this.locationRepository.save(location);
  }

  async remove(id: string): Promise<void> {
    const location = await this.findOne(id);
    await this.locationRepository.remove(location);
  }

  async getTree(id: string): Promise<Location> {
    const tree = await this.locationRepository.findDescendantsTree(
      await this.findOne(id),
    );

    if (!tree) {
      throw new NotFoundException('Location tree not found');
    }

    return tree;
  }
} 