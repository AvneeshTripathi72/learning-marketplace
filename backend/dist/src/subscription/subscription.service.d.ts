import { SupabaseService } from '../supabase/supabase.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { PackageTier } from '../common/enums';
export declare class SubscriptionService {
    private supabase;
    constructor(supabase: SupabaseService);
    getPackages(): {
        tier: PackageTier;
        price: number;
        videoLimit: number;
        name: string;
    }[];
    getPublicationSubscription(publicationId: string): Promise<any>;
    createSubscription(dto: CreateSubscriptionDto): Promise<any>;
}
