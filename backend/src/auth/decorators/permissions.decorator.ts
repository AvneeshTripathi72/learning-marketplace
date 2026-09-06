import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../../common/enums';

export const PERMISSIONS_KEY = 'permissions';

export interface PermissionMetadata {
  module: string;
  feature?: string;
  action: 'CREATE' | 'READ' | 'UPDATE' | 'DELETE' | 'ALL';
  roles?: UserRole[]; // Fallback roles if bypass doesn't exist
}

export const RequirePermissions = (metadata: PermissionMetadata) => SetMetadata(PERMISSIONS_KEY, metadata);
