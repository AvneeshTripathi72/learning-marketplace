import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SubmitVideoDto } from './dto/submit-video.dto';

@Injectable()
export class VideoHubService {
  constructor(private prisma: PrismaService) {}

  submitVideo(dto: SubmitVideoDto, userId: string) {
    return this.prisma.video.create({
      data: {
        ...dto,
        submittedById: userId,
        status: 'PENDING',
      },
    });
  }

  getMyUploads(userId: string) {
    return this.prisma.video.findMany({
      where: { submittedById: userId },
      orderBy: { submittedAt: 'desc' },
    });
  }

  getPendingQueue() {
    return this.prisma.video.findMany({
      where: { status: 'PENDING' },
      include: { submittedBy: true },
      orderBy: { submittedAt: 'asc' },
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
