import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateDonationDto } from './dto/create-donation.dto';

@Injectable()
export class DonationService {
  constructor(private prisma: PrismaService) {}

  async findByChannel(channelName: string) {
    const donation = await this.prisma.donation.findFirst({ where: { channelName } });
    if (!donation) throw new NotFoundException('Creator donation details not found');
    return donation;
  }

  create(dto: CreateDonationDto) {
    return this.prisma.donation.create({ data: dto });
  }
}
