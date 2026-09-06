import { SupabaseService } from '../supabase/supabase.service';
export declare class ContentHierarchyService {
    private supabase;
    constructor(supabase: SupabaseService);
    getSeries(publicationId: string): Promise<any[]>;
    getClasses(seriesId: string): Promise<any[]>;
    getSubjects(classId: string): Promise<any[]>;
}
