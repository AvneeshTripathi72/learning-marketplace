import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class CreateDonationDto {
  @IsString()
  @IsNotEmpty()
  channelName: string;

  @IsString()
  @IsNotEmpty()
  upiId: string;

  @IsUrl()
  qrCodeUrl: string;

  @IsUrl()
  creatorPhotoUrl: string;
}
