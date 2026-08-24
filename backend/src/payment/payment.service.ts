import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import * as crypto from 'crypto';

@Injectable()
export class PaymentService {
  private readonly webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || 'rzp_secret_key_2026';

  constructor(private prisma: PrismaService) {}

  async verifyDoubleCheck(dto: VerifyPaymentDto) {
    const payment = await this.prisma.payment.findUnique({
      where: { transactionId: dto.transactionId },
      include: { subscriptions: true },
    });

    if (!payment) {
      throw new NotFoundException('Payment record not found');
    }

    const activeSub = payment.subscriptions.find(
      (s) => s.publicationId === dto.publicationId && s.status === 'ACTIVE',
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
      await this.prisma.payment.updateMany({
        where: { gatewayRef: paymentId },
        data: { status: 'SUCCESSFUL' },
      });
    }

    return { status: 'ok' };
  }
}
