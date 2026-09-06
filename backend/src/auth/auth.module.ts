import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { AuthorizationService } from './authorization.service';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  controllers: [AuthController],
  providers: [AuthService, AuthorizationService],
  exports: [AuthService, AuthorizationService],
})
export class AuthModule {}
