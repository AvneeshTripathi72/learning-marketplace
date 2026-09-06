import { Controller, Get, Post, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { PublicationService } from './publication.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { AccessControlGuard } from '../auth/guards/access-control.guard';
import { UserRole } from '../common/enums';

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
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'publication', action: 'CREATE', roles: [UserRole.ADMIN] })
  create(@Body() dto: CreatePublicationDto) {
    return this.publicationService.create(dto);
  }

  @Patch(':id')
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'publication', action: 'UPDATE', roles: [UserRole.ADMIN] })
  update(@Param('id') id: string, @Body() dto: UpdatePublicationDto) {
    return this.publicationService.update(id, dto);
  }

  @Patch(':id/status')
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'publication', feature: 'toggle-status', action: 'UPDATE', roles: [UserRole.ADMIN] })
  toggleStatus(@Param('id') id: string, @Body('isActive') isActive: boolean) {
    return this.publicationService.toggleStatus(id, isActive);
  }
}
