import { PackageTier } from '@prisma/client';
export declare class CreateSubscriptionDto {
    publicationId: string;
    package: PackageTier;
    paymentId: string;
    durationMonths: number;
}
