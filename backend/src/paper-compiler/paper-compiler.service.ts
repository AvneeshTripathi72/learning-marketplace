import { Injectable } from '@nestjs/common';
import { GenerateQuestionPaperDto, GenerateTestPaperDto } from './dto/generate-paper.dto';

@Injectable()
export class PaperCompilerService {
  async generateQuestionPaper(dto: GenerateQuestionPaperDto) {
    const timestamp = Date.now();
    return {
      id: `qp_${timestamp}`,
      title: `Generated Question Paper (${dto.totalMarks} Marks)`,
      pdfUrl: `https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf`,
      totalMarks: dto.totalMarks,
      generatedDate: new Date(),
    };
  }

  async generateTestPaper(dto: GenerateTestPaperDto) {
    const timestamp = Date.now();
    return {
      id: `tp_${timestamp}`,
      title: `Model Test Paper - ${dto.patternName}`,
      testPdfUrl: `https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf`,
      answerKeyPdfUrl: dto.includeAnswerKey
        ? `https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf`
        : null,
      generatedDate: new Date(),
    };
  }
}
