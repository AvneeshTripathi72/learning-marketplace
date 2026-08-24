import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { PublicationService } from './publication.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '@prisma/client';

@Controller('publications')
export class PublicationController {
  constructor(private publicationService: PublicationService) {}

  @Get()
  findAll() {
    return this.publicationService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.publicationService.findOne(id);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  create(@Body() dto: CreatePublicationDto) {
    return this.publicationService.create(dto);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  update(@Param('id') id: string, @Body() dto: UpdatePublicationDto) {
    return this.publicationService.update(id, dto);
  }

  @Patch(':id/status')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  toggleStatus(@Param('id') id: string, @Body('isActive') isActive: boolean) {
    return this.publicationService.toggleStatus(id, isActive);
  }
}
