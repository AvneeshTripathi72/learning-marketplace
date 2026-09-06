import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { PackageTier, SubscriptionStatus } from '../common/enums';

@Injectable()
export class SubscriptionService {
  constructor(private supabase: SupabaseService) {}

  getPackages() {
    return [
      { tier: PackageTier.SILVER, price: 999, videoLimit: 10, name: 'Silver Tier' },
      { tier: PackageTier.BRONZE, price: 1999, videoLimit: 25, name: 'Bronze Tier' },
      { tier: PackageTier.GOLD, price: 3999, videoLimit: 50, name: 'Gold Tier' },
      { tier: PackageTier.DIAMOND, price: 7999, videoLimit: -1, name: 'Diamond Unlimited' },
    ];
  }

  async getPublicationSubscription(publicationId: string) {
    const { data: sub, error } = await this.supabase.client
      .from('Subscription')
      .select('*, payment:Payment(*)')
      .eq('publicationId', publicationId)
      .eq('status', SubscriptionStatus.ACTIVE)
      .order('endDate', { ascending: false })
      .limit(1)
      .single();

    if (error && error.code !== 'PGRST116') {
      // Ignore not found errors for this particular check, throw others
      throw new InternalServerErrorException(error.message);
    }
    return sub || { status: SubscriptionStatus.INACTIVE, package: null };
  }

  async createSubscription(dto: CreateSubscriptionDto) {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + dto.durationMonths);

    const { data, error } = await this.supabase.client
      .from('Subscription')
      .insert({
        publicationId: dto.publicationId,
        package: dto.package,
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
        status: SubscriptionStatus.ACTIVE,
        paymentId: dto.paymentId,
      })
      .select()
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }
}
