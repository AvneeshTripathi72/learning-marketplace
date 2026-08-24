import { PaymentService } from './payment.service';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
export declare class PaymentController {
    private service;
    constructor(service: PaymentService);
    verifyDoubleCheck(dto: VerifyPaymentDto): Promise<{
        transactionId: string;
        publicationId: string;
        isVerified: boolean;
        paymentStatus: import(".prisma/client").$Enums.PaymentStatus;
        subscriptionStatus: import(".prisma/client").$Enums.SubscriptionStatus;
    }>;
    handleWebhook(body: any, signature: string): Promise<{
        status: string;
    }>;
}
