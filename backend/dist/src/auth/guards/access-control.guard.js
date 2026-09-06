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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AccessControlGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const permissions_decorator_1 = require("../decorators/permissions.decorator");
const authorization_service_1 = require("../authorization.service");
let AccessControlGuard = class AccessControlGuard {
    constructor(reflector, authzService) {
        this.reflector = reflector;
        this.authzService = authzService;
    }
    async canActivate(context) {
        const requiredPermissions = this.reflector.getAllAndOverride(permissions_decorator_1.PERMISSIONS_KEY, [
            context.getHandler(),
            context.getClass(),
        ]);
        if (!requiredPermissions) {
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        if (!user || !user.id) {
            throw new common_1.ForbiddenException('User is not authenticated');
        }
        const route = request.route?.path || request.url;
        const ip = request.ip;
        const device = request.headers['user-agent'];
        const bypass = await this.authzService.getActiveBypass(user.id, requiredPermissions.module, route, requiredPermissions.feature);
        if (bypass) {
            await this.authzService.logBypassUsage(user.id, requiredPermissions.module, route, requiredPermissions.action, bypass.id, ip, device);
            switch (requiredPermissions.action) {
                case 'CREATE':
                    if (!this.authzService.canCreate(bypass, true))
                        throw new common_1.ForbiddenException('Bypass does not allow CREATE');
                    break;
                case 'READ':
                    if (!this.authzService.canRead(bypass, true))
                        throw new common_1.ForbiddenException('Bypass does not allow READ');
                    break;
                case 'UPDATE':
                    if (!this.authzService.canUpdate(bypass, true))
                        throw new common_1.ForbiddenException('Bypass does not allow UPDATE');
                    break;
                case 'DELETE':
                    if (!this.authzService.canDelete(bypass, true))
                        throw new common_1.ForbiddenException('Bypass does not allow DELETE');
                    break;
            }
            return true;
        }
        const hasRole = this.authzService.canAccess(user.role, requiredPermissions.roles);
        if (!hasRole) {
            throw new common_1.ForbiddenException(`Access denied. Insufficient roles to access module: ${requiredPermissions.module}`);
        }
        return true;
    }
};
exports.AccessControlGuard = AccessControlGuard;
exports.AccessControlGuard = AccessControlGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [core_1.Reflector,
        authorization_service_1.AuthorizationService])
], AccessControlGuard);
//# sourceMappingURL=access-control.guard.js.map