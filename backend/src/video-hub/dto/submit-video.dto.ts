import { IsOptional, IsString } from 'class-validator';

export class SubmitVideoDto {
  @IsString()
  url: string;

  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  platform?: any;

  @IsOptional()
  @IsString()
  channelName?: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsString()
  categoryId?: string;
}
