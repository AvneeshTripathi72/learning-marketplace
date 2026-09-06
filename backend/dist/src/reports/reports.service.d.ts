import { SupabaseService } from '../supabase/supabase.service';
export declare class ReportsService {
    private supabase;
    constructor(supabase: SupabaseService);
    getLeaderboard(): Promise<any[]>;
    getRevenueSummary(): Promise<{
        totalRevenue: number;
    }>;
}
