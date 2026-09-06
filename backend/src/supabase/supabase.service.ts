import { Injectable, Logger } from '@nestjs/common';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private readonly logger = new Logger(SupabaseService.name);
  public client: SupabaseClient;

  constructor() {
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

    if (!supabaseUrl || !supabaseKey) {
      this.logger.error('❌ Supabase URL or Key is missing in environment variables');
    } else {
      this.logger.log(`⚡ Supabase Client initialized successfully with URL: ${supabaseUrl}`);
    }

    this.client = createClient(supabaseUrl || '', supabaseKey || '');
  }

  get from() {
    return this.client.from.bind(this.client);
  }
}

