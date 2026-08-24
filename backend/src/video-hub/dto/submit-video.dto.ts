import { IsEnum, IsNotEmpty, IsString, IsUrl } from 'class-validator';
import { VideoPlatform } from '@prisma/client';

export class SubmitVideoDto {
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
}
