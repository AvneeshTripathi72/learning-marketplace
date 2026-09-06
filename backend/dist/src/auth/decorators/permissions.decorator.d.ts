import { UserRole } from '../../common/enums';
export declare const PERMISSIONS_KEY = "permissions";
export interface PermissionMetadata {
    module: string;
    feature?: string;
    action: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE' | 'ALL';
    roles?: UserRole[];
}
export declare const RequirePermissions: (metadata: PermissionMetadata) => import("@nestjs/common").CustomDecorator<string>;
