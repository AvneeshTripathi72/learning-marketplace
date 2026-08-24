import { Controller, Post, Body, Headers } from '@nestjs/common';
import { PaymentService } from './payment.service';
import { VerifyPaymentDto } from './dto/verify-payment.dto';

@Controller('payments')
export class PaymentController {
  constructor(private service: PaymentService) {}

  @Post('verify')
  verifyDoubleCheck(@Body() dto: VerifyPaymentDto) {
    return this.service.verifyDoubleCheck(dto);
  }

  @Post('webhook')
  handleWebhook(@Body() body: any, @Headers('x-razorpay-signature') signature: string) {
    return this.service.handleWebhook(body, signature);
  }
}
