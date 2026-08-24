import { IsEnum } from 'class-validator';
import { VideoStatus } from '@prisma/client';

export class ModerateVideoDto {
  @IsEnum(VideoStatus)
  status: VideoStatus;
}
