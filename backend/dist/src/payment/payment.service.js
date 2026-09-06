"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
const crypto = require("crypto");
let PaymentService = class PaymentService {
    constructor(supabase) {
        this.supabase = supabase;
        this.webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET || 'rzp_secret_key_2026';
    }
    async verifyDoubleCheck(dto) {
        const { data: payment, error } = await this.supabase.client
            .from('Payment')
            .select('*, subscriptions:Subscription(*)')
            .eq('transactionId', dto.transactionId)
            .single();
        if (error || !payment) {
            throw new common_1.NotFoundException('Payment record not found');
        }
        const subscriptions = payment.subscriptions || [];
        const activeSub = subscriptions.find((s) => s.publicationId === dto.publicationId && s.status === 'ACTIVE');
        const isDoubleVerified = payment.status === 'SUCCESSFUL' && activeSub !== undefined;
        return {
            transactionId: dto.transactionId,
            publicationId: dto.publicationId,
            isVerified: isDoubleVerified,
            paymentStatus: payment.status,
            subscriptionStatus: activeSub ? activeSub.status : 'INACTIVE',
        };
    }
    async handleWebhook(body, signature) {
        const expectedSignature = crypto
            .createHmac('sha256', this.webhookSecret)
            .update(JSON.stringify(body))
            .digest('hex');
        if (expectedSignature !== signature) {
            throw new common_1.BadRequestException('Invalid webhook signature');
        }
        if (body.event === 'payment.captured') {
            const paymentId = body.payload.payment.entity.id;
            const { error } = await this.supabase.client
                .from('Payment')
                .update({ status: 'SUCCESSFUL' })
                .eq('gatewayRef', paymentId);
            if (error)
                throw new common_1.InternalServerErrorException(error.message);
        }
        return { status: 'ok' };
    }
};
exports.PaymentService = PaymentService;
exports.PaymentService = PaymentService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], PaymentService);
//# sourceMappingURL=payment.service.js.map