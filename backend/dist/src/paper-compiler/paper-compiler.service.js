"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaperCompilerService = void 0;
const common_1 = require("@nestjs/common");
let PaperCompilerService = class PaperCompilerService {
    async generateQuestionPaper(dto) {
        const timestamp = Date.now();
        return {
            id: `qp_${timestamp}`,
            title: `Generated Question Paper (${dto.totalMarks} Marks)`,
            pdfUrl: `https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf`,
            totalMarks: dto.totalMarks,
            generatedDate: new Date(),
        };
    }
    async generateTestPaper(dto) {
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
};
exports.PaperCompilerService = PaperCompilerService;
exports.PaperCompilerService = PaperCompilerService = __decorate([
    (0, common_1.Injectable)()
], PaperCompilerService);
//# sourceMappingURL=paper-compiler.service.js.map