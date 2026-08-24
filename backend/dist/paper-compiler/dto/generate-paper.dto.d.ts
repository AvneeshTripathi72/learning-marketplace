export declare class GenerateQuestionPaperDto {
    publicationId: string;
    subjectId: string;
    totalMarks: number;
    chapterIds?: string[];
}
export declare class GenerateTestPaperDto {
    publicationId: string;
    patternName: string;
    includeAnswerKey: boolean;
}
