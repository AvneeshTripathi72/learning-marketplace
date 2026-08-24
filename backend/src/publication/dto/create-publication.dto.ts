import { IsEmail, IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class CreatePublicationDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @IsNotEmpty()
  mobile: string;

  @IsString()
  @IsNotEmpty()
  address: string;

  @IsUrl()
  logoUrl: string;

  @IsString()
  @IsNotEmpty()
  inquiryNumber: string;
}
