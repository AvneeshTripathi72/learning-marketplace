import { SupabaseService } from '../supabase/supabase.service';
import { CreateDonationDto } from './dto/create-donation.dto';
export declare class DonationService {
    private supabase;
    constructor(supabase: SupabaseService);
    findByChannel(channelName: string): Promise<any>;
    create(dto: CreateDonationDto): Promise<any>;
}
