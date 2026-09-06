import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateDonationDto } from './dto/create-donation.dto';

@Injectable()
export class DonationService {
  constructor(private supabase: SupabaseService) {}

  async findByChannel(channelName: string) {
    const { data, error } = await this.supabase.client
      .from('Donation')
      .select('*')
      .eq('channelName', channelName)
      .single();

    if (error || !data) throw new NotFoundException('Creator donation details not found');
    return data;
  }

  async create(dto: CreateDonationDto) {
    const { data, error } = await this.supabase.client
      .from('Donation')
      .insert(dto)
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }
}
