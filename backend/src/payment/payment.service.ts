import { Injectable, BadRequestException, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import * as crypto from 'crypto';

@Injectable()
export class PaymentService {
  private readonly webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || 'rzp_secret_key_2026';

  constructor(private supabase: SupabaseService) {}

  async verifyDoubleCheck(dto: VerifyPaymentDto) {
    const { data: payment, error } = await this.supabase.client
      .from('Payment')
      .select('*, subscriptions:Subscription(*)')
      .eq('transactionId', dto.transactionId)
      .single();

    if (error || !payment) {
      throw new NotFoundException('Payment record not found');
    }

    const subscriptions = payment.subscriptions || [];
    const activeSub = subscriptions.find(
      (s: any) => s.publicationId === dto.publicationId && s.status === 'ACTIVE',
    );

    const isDoubleVerified = payment.status === 'SUCCESSFUL' && activeSub !== undefined;

    return {
      transactionId: dto.transactionId,
      publicationId: dto.publicationId,
      isVerified: isDoubleVerified,
      paymentStatus: payment.status,
      subscriptionStatus: activeSub ? activeSub.status : 'INACTIVE',
    };
  }

  async handleWebhook(body: any, signature: string) {
    const expectedSignature = crypto
      .createHmac('sha256', this.webhookSecret)
      .update(JSON.stringify(body))
      .digest('hex');

    if (expectedSignature !== signature) {
      throw new BadRequestException('Invalid webhook signature');
    }

    if (body.event === 'payment.captured') {
      const paymentId = body.payload.payment.entity.id;
      const { error } = await this.supabase.client
        .from('Payment')
        .update({ status: 'SUCCESSFUL' })
        .eq('gatewayRef', paymentId);
        
      if (error) throw new InternalServerErrorException(error.message);
    }

    return { status: 'ok' };
  }
}
