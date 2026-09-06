import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ReportsService {
  constructor(private supabase: SupabaseService) {}

  async getLeaderboard() {
    const { data, error } = await this.supabase.client
      .from('Video')
      .select('*, category:Category(*)')
      .eq('status', 'APPROVED')
      .order('submittedAt', { ascending: false })
      .limit(10);
      
    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  async getRevenueSummary() {
    const { data, error } = await this.supabase.client
      .from('Payment')
      .select('amount')
      .eq('status', 'SUCCESSFUL');
      
    if (error) throw new InternalServerErrorException(error.message);
    
    // Sum amounts in JS since direct aggregate in postgrest requires RPC
    const totalRevenue = data.reduce((sum, payment) => sum + (Number(payment.amount) || 0), 0);
    return { totalRevenue };
  }
}
