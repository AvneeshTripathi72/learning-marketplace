import { Controller, Get, Post, Body, Query, Patch, Param, UseGuards } from '@nestjs/common';
import { EBookService } from './ebook.service';
import { CreateEBookDto } from './dto/create-ebook.dto';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { AccessControlGuard } from '../auth/guards/access-control.guard';
import { UserRole } from '../common/enums';

@Controller('ebooks')
export class EBookController {
  constructor(private service: EBookService) {}

  @Get()
  findBySubject(@Query('subjectId') subjectId: string) {
    return this.service.findBySubject(subjectId);
  }

  @Post()
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'ebook', action: 'CREATE', roles: [UserRole.ADMIN] })
  create(@Body() dto: CreateEBookDto) {
    return this.service.create(dto);
  }

  @Patch(':id/status')
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'ebook', feature: 'toggle-status', action: 'UPDATE', roles: [UserRole.ADMIN] })
  toggleStatus(@Param('id') id: string, @Body('isActive') isActive: boolean) {
    return this.service.toggleStatus(id, isActive);
  }
}
