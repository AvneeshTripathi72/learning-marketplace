import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private prisma: PrismaService) {}

  async getLeaderboard() {
    return this.prisma.video.findMany({
      take: 10,
      where: { status: 'APPROVED' },
      include: { category: true },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async getRevenueSummary() {
    const totalPayments = await this.prisma.payment.aggregate({
      where: { status: 'SUCCESSFUL' },
      _sum: { amount: true },
    });
    return { totalRevenue: totalPayments._sum.amount || 0 };
  }
}
