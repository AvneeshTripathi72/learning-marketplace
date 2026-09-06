import { CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthorizationService } from '../authorization.service';
export declare class AccessControlGuard implements CanActivate {
    private reflector;
    private authzService;
    constructor(reflector: Reflector, authzService: AuthorizationService);
    canActivate(context: ExecutionContext): Promise<boolean>;
}
