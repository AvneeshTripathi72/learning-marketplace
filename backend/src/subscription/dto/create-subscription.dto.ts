import { IsEnum, IsNotEmpty, IsNumber, IsString } from 'class-validator';
import { PackageTier } from '@prisma/client';

export class CreateSubscriptionDto {
  @IsString()
  @IsNotEmpty()
  publicationId: string;

  @IsEnum(PackageTier)
  package: PackageTier;

  @IsString()
  @IsNotEmpty()
  paymentId: string;

  @IsNumber()
  durationMonths: number;
}
