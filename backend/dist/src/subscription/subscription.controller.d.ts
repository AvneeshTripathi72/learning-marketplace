import { SubscriptionService } from './subscription.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
export declare class SubscriptionController {
    private service;
    constructor(service: SubscriptionService);
    getPackages(): {
        tier: import("../common/enums").PackageTier;
        price: number;
        videoLimit: number;
        name: string;
    }[];
    getPublicationSubscription(publicationId: string): Promise<any>;
    createSubscription(dto: CreateSubscriptionDto): Promise<any>;
}
