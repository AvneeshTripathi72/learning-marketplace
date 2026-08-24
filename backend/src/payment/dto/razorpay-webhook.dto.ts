import { IsNotEmpty, IsObject, IsString } from 'class-validator';

export class RazorpayWebhookDto {
  @IsString()
  @IsNotEmpty()
  event: string;

  @IsObject()
  payload: any;
}
