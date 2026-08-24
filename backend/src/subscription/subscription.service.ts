import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { PackageTier, SubscriptionStatus } from '@prisma/client';

@Injectable()
export class SubscriptionService {
  constructor(private prisma: PrismaService) {}

  getPackages() {
    return [
      { tier: PackageTier.SILVER, price: 999, videoLimit: 10, name: 'Silver Tier' },
      { tier: PackageTier.BRONZE, price: 1999, videoLimit: 25, name: 'Bronze Tier' },
      { tier: PackageTier.GOLD, price: 3999, videoLimit: 50, name: 'Gold Tier' },
      { tier: PackageTier.DIAMOND, price: 7999, videoLimit: -1, name: 'Diamond Unlimited' },
    ];
  }

  async getPublicationSubscription(publicationId: string) {
    const sub = await this.prisma.subscription.findFirst({
      where: { publicationId, status: SubscriptionStatus.ACTIVE },
      orderBy: { endDate: 'desc' },
      include: { payment: true },
    });
    return sub || { status: SubscriptionStatus.INACTIVE, package: null };
  }

  async createSubscription(dto: CreateSubscriptionDto) {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + dto.durationMonths);

    return this.prisma.subscription.create({
      data: {
        publicationId: dto.publicationId,
        package: dto.package,
        startDate,
        endDate,
        status: SubscriptionStatus.ACTIVE,
        paymentId: dto.paymentId,
      },
    });
  }
}
