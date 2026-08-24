import { Module } from '@nestjs/common';
import { VideoHubService } from './video-hub.service';
import { VideoHubController } from './video-hub.controller';

@Module({
  controllers: [VideoHubController],
  providers: [VideoHubService],
  exports: [VideoHubService],
})
export class VideoHubModule {}
