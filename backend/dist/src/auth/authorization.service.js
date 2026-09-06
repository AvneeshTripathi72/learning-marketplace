"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var AuthorizationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthorizationService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let AuthorizationService = AuthorizationService_1 = class AuthorizationService {
    constructor(supabase) {
        this.supabase = supabase;
        this.logger = new common_1.Logger(AuthorizationService_1.name);
    }
    async getActiveBypass(userId, module, route, feature) {
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
            if (!bypasses || bypasses.length === 0)
                return null;
            const now = new Date();
            for (const bypass of bypasses) {
                if (bypass.expires_at && new Date(bypass.expires_at) < now) {
                    continue;
                }
                if (bypass.module === 'all')
                    return bypass;
                if (bypass.module === module) {
                    if (!bypass.route && !bypass.feature)
                        return bypass;
                    if (bypass.route === route)
                        return bypass;
                    if (feature && bypass.feature === feature)
                        return bypass;
                }
            }
            return null;
        }
        catch (e) {
            this.logger.error('Exception in getActiveBypass', e);
            return null;
        }
    }
    async logBypassUsage(userId, module, route, action, bypassId, ip, device) {
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
        }
        catch (e) {
            this.logger.error('Failed to log bypass usage', e);
        }
    }
    canAccess(userRole, requiredRoles) {
        if (!requiredRoles || requiredRoles.length === 0)
            return true;
        return requiredRoles.includes(userRole);
    }
    canCreate(bypass, hasRole) {
        if (bypass) {
            if (bypass.permissions && bypass.permissions.length > 0)
                return bypass.permissions[0].can_create;
            return true;
        }
        return hasRole;
    }
    canRead(bypass, hasRole) {
        if (bypass) {
            if (bypass.permissions && bypass.permissions.length > 0)
                return bypass.permissions[0].can_read;
            return true;
        }
        return hasRole;
    }
    canUpdate(bypass, hasRole) {
        if (bypass) {
            if (bypass.permissions && bypass.permissions.length > 0)
                return bypass.permissions[0].can_update;
            return true;
        }
        return hasRole;
    }
    canDelete(bypass, hasRole) {
        if (bypass) {
            if (bypass.permissions && bypass.permissions.length > 0)
                return bypass.permissions[0].can_delete;
            return true;
        }
        return hasRole;
    }
};
exports.AuthorizationService = AuthorizationService;
exports.AuthorizationService = AuthorizationService = AuthorizationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], AuthorizationService);
//# sourceMappingURL=authorization.service.js.map