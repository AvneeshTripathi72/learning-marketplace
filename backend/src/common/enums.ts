export enum UserRole {
  PUBLICATION = 'PUBLICATION',
  PUBLIC = 'PUBLIC',
  ADMIN = 'ADMIN'
}

export enum VideoPlatform {
  YOUTUBE = 'YOUTUBE',
  INSTAGRAM = 'INSTAGRAM',
  FACEBOOK = 'FACEBOOK'
}

export enum VideoStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  INACTIVE = 'INACTIVE',
  DELETED = 'DELETED'
}

export enum PackageTier {
  SILVER = 'SILVER',
  BRONZE = 'BRONZE',
  GOLD = 'GOLD',
  DIAMOND = 'DIAMOND'
}

export enum SubscriptionStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  EXPIRED = 'EXPIRED',
  PENDING_UPGRADE = 'PENDING_UPGRADE'
}

export enum PaymentStatus {
  PENDING = 'PENDING',
  SUCCESSFUL = 'SUCCESSFUL',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  CANCELLED = 'CANCELLED'
}
