import { SupabaseService } from '../supabase/supabase.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';
export declare class YouTubeService {
    private supabase;
    constructor(supabase: SupabaseService);
    findBySubject(subjectId: string): Promise<any[]>;
    create(dto: CreateYouTubeVideoDto, userId: string): Promise<any>;
}
