import { SubscriptionService } from './subscription.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
export declare class SubscriptionController {
    private service;
    constructor(service: SubscriptionService);
    getPackages(): ({
        tier: "SILVER";
        price: number;
        videoLimit: number;
        name: string;
    } | {
        tier: "BRONZE";
        price: number;
        videoLimit: number;
        name: string;
    } | {
        tier: "GOLD";
        price: number;
        videoLimit: number;
        name: string;
    } | {
        tier: "DIAMOND";
        price: number;
        videoLimit: number;
        name: string;
    })[];
    getPublicationSubscription(publicationId: string): Promise<({
        payment: {
            id: string;
            createdAt: Date;
            status: import(".prisma/client").$Enums.PaymentStatus;
            transactionId: string;
            amount: import("@prisma/client/runtime/library").Decimal;
            gatewayRef: string;
        };
    } & {
        publicationId: string;
        id: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        package: import(".prisma/client").$Enums.PackageTier;
        paymentId: string;
        startDate: Date;
        endDate: Date;
    }) | {
        status: "INACTIVE";
        package: any;
    }>;
    createSubscription(dto: CreateSubscriptionDto): Promise<{
        publicationId: string;
        id: string;
        status: import(".prisma/client").$Enums.SubscriptionStatus;
        package: import(".prisma/client").$Enums.PackageTier;
        paymentId: string;
        startDate: Date;
        endDate: Date;
    }>;
}
