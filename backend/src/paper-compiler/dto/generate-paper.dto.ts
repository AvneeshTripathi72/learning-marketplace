import { IsArray, IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class GenerateQuestionPaperDto {
  @IsString()
  @IsNotEmpty()
  publicationId: string;

  @IsString()
  @IsNotEmpty()
  subjectId: string;

  @IsNumber()
  totalMarks: number;

  @IsOptional()
  @IsArray()
  chapterIds?: string[];
}

export class GenerateTestPaperDto {
  @IsString()
  @IsNotEmpty()
  publicationId: string;

  @IsString()
  @IsNotEmpty()
  patternName: string;

  @IsBoolean()
  includeAnswerKey: boolean;
}
