import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class VideoHubService {
  constructor(private prisma: PrismaService) {}

  async submitVideo(dto: any, userId: string) {
    const categoryName = dto.category || 'Educational';

    let category = await this.prisma.category.findFirst({
      where: { name: { equals: categoryName, mode: 'insensitive' } },
    });

    if (!category) {
      category = await this.prisma.category.create({
        data: { name: categoryName, isEnabled: true },
      });
    }

    let user = await this.prisma.user.findFirst({
      where: { OR: [{ id: userId }, { email: 'hariom.info07@gmail.com' }] },
    });
    if (!user) {
      user = await this.prisma.user.findFirst();
    }

    let platform = 'YOUTUBE';
    const urlLower = (dto.url || '').toLowerCase();
    if (urlLower.includes('instagram')) platform = 'INSTAGRAM';
    if (urlLower.includes('facebook')) platform = 'FACEBOOK';

    return this.prisma.video.create({
      data: {
        url: dto.url,
        platform: platform as any,
        channelName: dto.channelName || 'User Channel',
        categoryId: category.id,
        submittedById: user ? user.id : 'user_demo',
        status: 'PENDING',
      },
    });
  }

  async getMyUploads(userId: string) {
    return this.prisma.video.findMany({
      where: {
        OR: [
          { submittedById: userId },
          { submittedBy: { email: 'hariom.info07@gmail.com' } },
        ],
      },
      include: { category: true },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async getPendingQueue() {
    return this.prisma.video.findMany({
      where: { status: 'PENDING' },
      include: { submittedBy: true, category: true },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async moderateVideo(id: string, status: any) {
    const video = await this.prisma.video.findUnique({ where: { id } });
    if (!video) throw new NotFoundException('Video not found');

    return this.prisma.video.update({
      where: { id },
      data: { status },
    });
  }
}
