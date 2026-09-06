import { SupabaseService } from '../supabase/supabase.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';
export declare class PublicationService {
    private supabase;
    constructor(supabase: SupabaseService);
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    create(dto: CreatePublicationDto): Promise<any>;
    update(id: string, dto: UpdatePublicationDto): Promise<any>;
    toggleStatus(id: string, isActive: boolean): Promise<any>;
}
