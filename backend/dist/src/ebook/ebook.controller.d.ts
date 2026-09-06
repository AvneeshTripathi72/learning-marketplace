import { EBookService } from './ebook.service';
import { CreateEBookDto } from './dto/create-ebook.dto';
export declare class EBookController {
    private service;
    constructor(service: EBookService);
    findBySubject(subjectId: string): Promise<any[]>;
    create(dto: CreateEBookDto): Promise<any>;
    toggleStatus(id: string, isActive: boolean): Promise<any>;
}
