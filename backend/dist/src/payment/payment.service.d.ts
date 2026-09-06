import { SupabaseService } from '../supabase/supabase.service';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
export declare class PaymentService {
    private supabase;
    private readonly webhookSecret;
    constructor(supabase: SupabaseService);
    verifyDoubleCheck(dto: VerifyPaymentDto): Promise<{
        transactionId: string;
        publicationId: string;
        isVerified: boolean;
        paymentStatus: any;
        subscriptionStatus: any;
    }>;
    handleWebhook(body: any, signature: string): Promise<{
        status: string;
    }>;
}
