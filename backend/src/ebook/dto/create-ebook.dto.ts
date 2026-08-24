import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class CreateEBookDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  subjectId: string;

  @IsUrl()
  coverUrl: string;

  @IsUrl()
  fileUrl: string;
}
