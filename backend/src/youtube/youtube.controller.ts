import { Controller, Get, Post, Body, Query, UseGuards, Req } from '@nestjs/common';
import { YouTubeService } from './youtube.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';


import { UserRole } from '../common/enums';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { AccessControlGuard } from '../auth/guards/access-control.guard';

@Controller('youtube')
export class YouTubeController {
  constructor(private service: YouTubeService) {}

  @Get()
  findBySubject(@Query('subjectId') subjectId: string) {
    return this.service.findBySubject(subjectId);
  }

  @Post()
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'youtube', action: 'ALL', roles: [UserRole.PUBLICATION, UserRole.ADMIN] })
  create(@Body() dto: CreateYouTubeVideoDto, @Req() req: any) {
    const userId = req.user?.sub || 'system';
    return this.service.create(dto, userId);
  }
}
