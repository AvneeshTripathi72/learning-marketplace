import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class VideoHubService {
  constructor(private supabase: SupabaseService) {}

  async submitVideo(dto: any, userId: string) {
    const categoryName = dto.category || 'Educational';

    let { data: category } = await this.supabase.client
      .from('Category')
      .select('*')
      .ilike('name', categoryName)
      .single();

    if (!category) {
      const { data: newCategory, error } = await this.supabase.client
        .from('Category')
        .insert({ name: categoryName, isEnabled: true })
        .select()
        .single();
      if (error) throw new InternalServerErrorException(error.message);
      category = newCategory;
    }

    let { data: user } = await this.supabase.client
      .from('User')
      .select('*')
      .or(`id.eq.${userId},email.eq.hariom.info07@gmail.com`)
      .limit(1)
      .single();

    if (!user) {
      const { data: firstUser } = await this.supabase.client
        .from('User')
        .select('*')
        .limit(1)
        .single();
      user = firstUser;
    }
    
    if (!user) {
      const { data: newUser, error } = await this.supabase.client
        .from('User')
        .insert({
          name: 'Public Student User',
          email: 'public.student@ebook.app',
          password: 'Password123!',
          role: 'PUBLIC',
        })
        .select()
        .single();
      if (error) throw new InternalServerErrorException(error.message);
      user = newUser;
    }

    let platform = 'YOUTUBE';
    const urlLower = (dto.url || '').toLowerCase();
    if (urlLower.includes('instagram')) platform = 'INSTAGRAM';
    if (urlLower.includes('facebook')) platform = 'FACEBOOK';

    const { data: video, error } = await this.supabase.client
      .from('Video')
      .insert({
        url: dto.url,
        platform: platform,
        channelName: dto.channelName || 'User Channel',
        categoryId: category.id,
        submittedById: user.id,
        status: 'PENDING',
      })
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return video;
  }

  async getMyUploads(userId: string) {
    // Supabase JS doesn't easily support deeply nested OR filters across relations like Prisma does in one query
    // So we fetch user with the email to get ID first
    const { data: adminUser } = await this.supabase.client
      .from('User')
      .select('id')
      .eq('email', 'hariom.info07@gmail.com')
      .single();

    let orQuery = `submittedById.eq.${userId}`;
    if (adminUser) {
        orQuery += `,submittedById.eq.${adminUser.id}`;
    }

    const { data, error } = await this.supabase.client
      .from('Video')
      .select('*, category:Category(*)')
      .or(orQuery)
      .order('submittedAt', { ascending: false });

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async getPendingQueue() {
    const { data, error } = await this.supabase.client
      .from('Video')
      .select('*, submittedBy:User(*), category:Category(*)')
      .eq('status', 'PENDING')
      .order('submittedAt', { ascending: false });

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async moderateVideo(id: string, status: any) {
    const { data: video, error: findError } = await this.supabase.client
      .from('Video')
      .select('*')
      .eq('id', id)
      .single();

    if (findError || !video) throw new NotFoundException('Video not found');

    const { data, error: updateError } = await this.supabase.client
      .from('Video')
      .update({ status })
      .eq('id', id)
      .select()
      .single();

    if (updateError) throw new InternalServerErrorException(updateError.message);
    return data;
  }
}
