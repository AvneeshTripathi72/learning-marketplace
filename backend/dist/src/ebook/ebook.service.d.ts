import { SupabaseService } from '../supabase/supabase.service';
import { CreateEBookDto } from './dto/create-ebook.dto';
export declare class EBookService {
    private supabase;
    constructor(supabase: SupabaseService);
    findBySubject(subjectId: string): Promise<any[]>;
    create(dto: CreateEBookDto): Promise<any>;
    toggleStatus(id: string, isActive: boolean): Promise<any>;
}
