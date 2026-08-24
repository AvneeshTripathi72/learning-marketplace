import { IsEnum, IsNotEmpty, IsOptional, IsString, IsUrl } from 'class-validator';
import { VideoPlatform } from '@prisma/client';

export class CreateYouTubeVideoDto {
  @IsUrl()
  url: string;

  @IsEnum(VideoPlatform)
  platform: VideoPlatform;

  @IsString()
  @IsNotEmpty()
  channelName: string;

  @IsString()
  @IsNotEmpty()
  categoryId: string;

  @IsOptional()
  @IsString()
  subjectId?: string;
}
