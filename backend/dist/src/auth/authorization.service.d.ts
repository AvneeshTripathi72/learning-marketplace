import { SupabaseService } from '../supabase/supabase.service';
import { UserRole } from '../common/enums';
export declare class AuthorizationService {
    private readonly supabase;
    private readonly logger;
    constructor(supabase: SupabaseService);
    getActiveBypass(userId: string, module: string, route: string, feature?: string): Promise<{
        id: any;
        module: any;
        route: any;
        feature: any;
        expires_at: any;
        permissions: {
            can_create: any;
            can_read: any;
            can_update: any;
            can_delete: any;
        }[];
    }>;
    logBypassUsage(userId: string, module: string, route: string, action: string, bypassId: string, ip?: string, device?: string): Promise<void>;
    canAccess(userRole: UserRole, requiredRoles?: UserRole[]): boolean;
    canCreate(bypass: any, hasRole: boolean): boolean;
    canRead(bypass: any, hasRole: boolean): boolean;
    canUpdate(bypass: any, hasRole: boolean): boolean;
    canDelete(bypass: any, hasRole: boolean): boolean;
}
