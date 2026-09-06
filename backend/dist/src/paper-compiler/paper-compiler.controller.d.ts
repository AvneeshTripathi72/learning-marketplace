import { PaperCompilerService } from './paper-compiler.service';
import { GenerateQuestionPaperDto, GenerateTestPaperDto } from './dto/generate-paper.dto';
export declare class PaperCompilerController {
    private service;
    constructor(service: PaperCompilerService);
    generateQuestionPaper(dto: GenerateQuestionPaperDto): Promise<{
        id: string;
        title: string;
        pdfUrl: string;
        totalMarks: number;
        generatedDate: Date;
    }>;
    generateTestPaper(dto: GenerateTestPaperDto): Promise<{
        id: string;
        title: string;
        testPdfUrl: string;
        answerKeyPdfUrl: string;
        generatedDate: Date;
    }>;
}
