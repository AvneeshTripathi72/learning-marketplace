import { IsEnum, IsNotEmpty, IsNumber, IsString } from 'class-validator';
import { PackageTier } from '../../common/enums';

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
