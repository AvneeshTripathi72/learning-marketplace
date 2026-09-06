import { Controller, Get, Post, Body, Patch, Param, Req } from '@nestjs/common';
import { VideoHubService } from './video-hub.service';
import { SubmitVideoDto } from './dto/submit-video.dto';

@Controller('video-hub')
export class VideoHubController {
  constructor(private service: VideoHubService) {}

  @Post('submit')
  submitVideo(@Body() dto: SubmitVideoDto, @Req() req: any) {
    const userId = req.user?.sub || 'user_demo';
    return this.service.submitVideo(dto, userId);
  }

  @Get('my-uploads')
  getMyUploads(@Req() req: any) {
    const userId = req.user?.sub || 'user_demo';
    return this.service.getMyUploads(userId);
  }

  @Get('admin/queue')
  getPendingQueue() {
    return this.service.getPendingQueue();
  }

  @Patch('admin/moderate/:id')
  moderateVideo(@Param('id') id: string, @Body() dto: any) {
    return this.service.moderateVideo(id, dto.status);
  }
}
