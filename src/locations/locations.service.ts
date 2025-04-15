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

      // Check if the new parent is a descendant of the current location
      const descendants = await this.findDescendants(id);
      if (descendants.some(descendant => descendant.id === updateLocationDto.parentId)) {
        throw new BadRequestException('Cannot create circular reference in location hierarchy');
      }

      // Check if the new parent is an ancestor of the current location
      const ancestors = await this.findAncestors(id);
      if (ancestors.some(ancestor => ancestor.id === updateLocationDto.parentId)) {
        // If the new parent is an ancestor, we need to update the hierarchy
        // We'll directly set the new parent since TypeORM will handle the relationship update
        location.parent = parent;
        return this.locationRepository.save(location);
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

  async findDescendants(id: string): Promise<Location[]> {
    const location = await this.findOne(id);
    const allDescendants: Location[] = [];
    
    async function getDescendants(currentLocation: Location) {
      const children = await this.locationRepository.find({
        where: { parent: { id: currentLocation.id } },
        relations: ['children'],
      });
      
      for (const child of children) {
        allDescendants.push(child);
        await getDescendants(child);
      }
    }
    
    await getDescendants(location);
    return allDescendants;
  }

  async findAncestors(id: string): Promise<Location[]> {
    const location = await this.findOne(id);
    const allAncestors: Location[] = [];
    
    async function getAncestors(currentLocation: Location) {
      if (currentLocation.parent) {
        const parent = await this.locationRepository.findOne({
          where: { id: currentLocation.parent.id },
          relations: ['parent'],
        });
        
        if (parent) {
          allAncestors.push(parent);
          await getAncestors(parent);
        }
      }
    }
    
    await getAncestors(location);
    return allAncestors;
  }
} 