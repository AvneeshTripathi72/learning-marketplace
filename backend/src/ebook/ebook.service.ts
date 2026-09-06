import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateEBookDto } from './dto/create-ebook.dto';

@Injectable()
export class EBookService {
  constructor(private supabase: SupabaseService) {}

  async findBySubject(subjectId: string) {
    const { data, error } = await this.supabase.client
      .from('EBook')
      .select('*')
      .eq('subjectId', subjectId)
      .eq('isActive', true);
    
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async create(dto: CreateEBookDto) {
    const { data, error } = await this.supabase.client
      .from('EBook')
      .insert(dto)
      .select()
      .single();
      
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async toggleStatus(id: string, isActive: boolean) {
    const { data: ebook, error: findError } = await this.supabase.client
      .from('EBook')
      .select('*')
      .eq('id', id)
      .single();

    if (findError || !ebook) throw new NotFoundException('eBook not found');

    const { data, error: updateError } = await this.supabase.client
      .from('EBook')
      .update({ isActive })
      .eq('id', id)
      .select()
      .single();

    if (updateError) throw new InternalServerErrorException(updateError.message);
    return data;
  }
}
