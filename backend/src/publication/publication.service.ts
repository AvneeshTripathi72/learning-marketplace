import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';

@Injectable()
export class PublicationService {
  constructor(private supabase: SupabaseService) {}

  async findAll() {
    const { data, error } = await this.supabase.client
      .from('Publication')
      .select('*')
      .order('createdAt', { ascending: false });
      
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async findOne(id: string) {
    const { data, error } = await this.supabase.client
      .from('Publication')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) throw new NotFoundException('Publication not found');
    return data;
  }

  async create(dto: CreatePublicationDto) {
    const { data, error } = await this.supabase.client
      .from('Publication')
      .insert(dto)
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async update(id: string, dto: UpdatePublicationDto) {
    await this.findOne(id);
    const { data, error } = await this.supabase.client
      .from('Publication')
      .update(dto)
      .eq('id', id)
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async toggleStatus(id: string, isActive: boolean) {
    await this.findOne(id);
    const { data, error } = await this.supabase.client
      .from('Publication')
      .update({ isActive })
      .eq('id', id)
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }
}
