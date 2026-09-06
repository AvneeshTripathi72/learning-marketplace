import { PrismaService } from '../prisma/prisma.service';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
export declare class PaymentService {
    private prisma;
    private readonly webhookSecret;
    constructor(prisma: PrismaService);
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
