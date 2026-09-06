import { Injectable, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UserRole } from '../common/enums';

@Injectable()
export class AuthorizationService {
  private readonly logger = new Logger(AuthorizationService.name);

  constructor(private readonly supabase: SupabaseService) {}

  /**
   * Step 1: Check if the user has an active bypass for the given module/route/feature
   */
  async getActiveBypass(userId: string, module: string, route: string, feature?: string) {
    try {
      const { data: bypasses, error } = await this.supabase.client
        .from('access_bypass')
        .select(`
          id, module, route, feature, expires_at,
          permissions:access_bypass_permissions ( can_create, can_read, can_update, can_delete )
        `)
        .eq('user_id', userId)
        .eq('is_enabled', true);

      if (error) {
        this.logger.error('Error fetching bypass from Supabase', error);
        return null;
      }

      if (!bypasses || bypasses.length === 0) return null;

      const now = new Date();
      
      for (const bypass of bypasses) {
        // Check expiration
        if (bypass.expires_at && new Date(bypass.expires_at) < now) {
          continue; // Expired
        }

        // Match bypass rule logic
        // 1. Full System Access (module = 'all')
        if (bypass.module === 'all') return bypass;
        
        // 2. Module Specific Access
        if (bypass.module === module) {
          if (!bypass.route && !bypass.feature) return bypass; // Bypass entire module
          if (bypass.route === route) return bypass; // Match specific route
          if (feature && bypass.feature === feature) return bypass; // Match specific feature
        }
      }

      return null;
    } catch (e) {
      this.logger.error('Exception in getActiveBypass', e);
      return null;
    }
  }

  /**
   * Write to Audit Logs when bypass is used
   */
  async logBypassUsage(userId: string, module: string, route: string, action: string, bypassId: string, ip?: string, device?: string) {
    try {
      await this.supabase.client.from('access_audit_logs').insert({
        user_id: userId,
        module,
        route,
        action,
        bypass_id: bypassId,
        ip_address: ip || 'unknown',
        device_info: device || 'unknown',
      });
    } catch (e) {
      this.logger.error('Failed to log bypass usage', e);
    }
  }

  /**
   * Helper to evaluate permissions
   */
  canAccess(userRole: UserRole, requiredRoles?: UserRole[]): boolean {
    if (!requiredRoles || requiredRoles.length === 0) return true;
    return requiredRoles.includes(userRole);
  }

  canCreate(bypass: any, hasRole: boolean): boolean {
    if (bypass) {
      if (bypass.permissions && bypass.permissions.length > 0) return bypass.permissions[0].can_create;
      return true; // Assume true if no explicit permission record exists
    }
    return hasRole;
  }

  canRead(bypass: any, hasRole: boolean): boolean {
    if (bypass) {
      if (bypass.permissions && bypass.permissions.length > 0) return bypass.permissions[0].can_read;
      return true;
    }
    return hasRole;
  }

  canUpdate(bypass: any, hasRole: boolean): boolean {
    if (bypass) {
      if (bypass.permissions && bypass.permissions.length > 0) return bypass.permissions[0].can_update;
      return true;
    }
    return hasRole;
  }

  canDelete(bypass: any, hasRole: boolean): boolean {
    if (bypass) {
      if (bypass.permissions && bypass.permissions.length > 0) return bypass.permissions[0].can_delete;
      return true;
    }
    return hasRole;
  }
}
