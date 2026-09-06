import { IsEnum } from 'class-validator';
import { VideoStatus } from '../../common/enums';

export class ModerateVideoDto {
  @IsEnum(VideoStatus)
  status: VideoStatus;
}
