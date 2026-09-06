import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ContentHierarchyService {
  constructor(private supabase: SupabaseService) {}

  async getSeries(publicationId: string) {
    const { data, error } = await this.supabase.client
      .from('Series')
      .select('*')
      .eq('publicationId', publicationId);
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async getClasses(seriesId: string) {
    const { data, error } = await this.supabase.client
      .from('Class')
      .select('*')
      .eq('seriesId', seriesId);
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async getSubjects(classId: string) {
    const { data, error } = await this.supabase.client
      .from('Subject')
      .select('*')
      .eq('classId', classId);
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }
}
