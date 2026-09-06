import { Controller, Get, Post, Body, Query, UseGuards, Req } from '@nestjs/common';
import { YouTubeService } from './youtube.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '../common/enums';

@Controller('youtube')
export class YouTubeController {
  constructor(private service: YouTubeService) {}

  @Get()
  findBySubject(@Query('subjectId') subjectId: string) {
    return this.service.findBySubject(subjectId);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.PUBLICATION, UserRole.ADMIN)
  create(@Body() dto: CreateYouTubeVideoDto, @Req() req: any) {
    const userId = req.user?.sub || 'system';
    return this.service.create(dto, userId);
  }
}
