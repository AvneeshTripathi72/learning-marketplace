import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';

@Injectable()
export class YouTubeService {
  constructor(private supabase: SupabaseService) {}

  async findBySubject(subjectId: string) {
    const { data, error } = await this.supabase.client
      .from('Video')
      .select('*, category:Category(*)')
      .eq('subjectId', subjectId)
      .eq('status', 'APPROVED')
      .order('submittedAt', { ascending: false });
    
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async create(dto: CreateYouTubeVideoDto, userId: string) {
    const { data, error } = await this.supabase.client
      .from('Video')
      .insert({
        ...dto,
        submittedById: userId,
        status: 'APPROVED',
      })
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }
}
