import { Controller, Post, Body } from '@nestjs/common';
import { PaperCompilerService } from './paper-compiler.service';
import { GenerateQuestionPaperDto, GenerateTestPaperDto } from './dto/generate-paper.dto';

@Controller('paper-compiler')
export class PaperCompilerController {
  constructor(private service: PaperCompilerService) {}

  @Post('question-paper')
  generateQuestionPaper(@Body() dto: GenerateQuestionPaperDto) {
    return this.service.generateQuestionPaper(dto);
  }

  @Post('test-paper')
  generateTestPaper(@Body() dto: GenerateTestPaperDto) {
    return this.service.generateTestPaper(dto);
  }
}
