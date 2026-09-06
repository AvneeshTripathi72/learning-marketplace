import { SupabaseClient } from '@supabase/supabase-js';
export declare class SupabaseService {
    private readonly logger;
    client: SupabaseClient;
    constructor();
    get from(): any;
}
