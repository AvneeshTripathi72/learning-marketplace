import { PackageTier } from '../../common/enums';
export declare class CreateSubscriptionDto {
    publicationId: string;
    package: PackageTier;
    paymentId: string;
    durationMonths: number;
}
