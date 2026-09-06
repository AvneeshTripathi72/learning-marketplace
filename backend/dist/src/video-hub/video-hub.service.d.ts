import { SupabaseService } from '../supabase/supabase.service';
export declare class VideoHubService {
    private supabase;
    constructor(supabase: SupabaseService);
    submitVideo(dto: any, userId: string): Promise<any>;
    getMyUploads(userId: string): Promise<any[]>;
    getPendingQueue(): Promise<any[]>;
    moderateVideo(id: string, status: any): Promise<any>;
}
