import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY, PermissionMetadata } from '../decorators/permissions.decorator';
import { AuthorizationService } from '../authorization.service';

@Injectable()
export class AccessControlGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private authzService: AuthorizationService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.getAllAndOverride<PermissionMetadata>(PERMISSIONS_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // If no specific permissions are required, allow access
    if (!requiredPermissions) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user; // Set by AuthGuard
    
    // Step 1: Ensure user is authenticated
    if (!user || !user.id) {
      throw new ForbiddenException('User is not authenticated');
    }

    const route = request.route?.path || request.url;
    const ip = request.ip;
    const device = request.headers['user-agent'];

    // Step 2 & 3: Check Active Bypass
    const bypass = await this.authzService.getActiveBypass(
      user.id,
      requiredPermissions.module,
      route,
      requiredPermissions.feature
    );

    // Step 4: If Bypass Exists -> Grant Access Immediately
    if (bypass) {
      // Step 4.1: Log Bypass Usage
      await this.authzService.logBypassUsage(
        user.id,
        requiredPermissions.module,
        route,
        requiredPermissions.action,
        bypass.id,
        ip,
        device
      );
      
      // Step 4.2: Enforce granular CRUD permissions if provided in bypass
      switch (requiredPermissions.action) {
        case 'CREATE':
          if (!this.authzService.canCreate(bypass, true)) throw new ForbiddenException('Bypass does not allow CREATE');
          break;
        case 'READ':
          if (!this.authzService.canRead(bypass, true)) throw new ForbiddenException('Bypass does not allow READ');
          break;
        case 'UPDATE':
          if (!this.authzService.canUpdate(bypass, true)) throw new ForbiddenException('Bypass does not allow UPDATE');
          break;
        case 'DELETE':
          if (!this.authzService.canDelete(bypass, true)) throw new ForbiddenException('Bypass does not allow DELETE');
          break;
      }
      
      return true;
    }

    // Step 5: Else Check Roles (Normal Authorization Flow)
    const hasRole = this.authzService.canAccess(user.role, requiredPermissions.roles);
    if (!hasRole) {
      throw new ForbiddenException(`Access denied. Insufficient roles to access module: ${requiredPermissions.module}`);
    }

    // Note: Step 6 (Check Resource Ownership) is typically handled within the Service or Controller 
    // because it requires querying the specific database row to compare ownership.

    return true; // Step 7: Grant Access
  }
}
