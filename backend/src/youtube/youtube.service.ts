import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';

@Injectable()
export class YouTubeService {
  constructor(private prisma: PrismaService) {}

  findBySubject(subjectId: string) {
    return this.prisma.video.findMany({
      where: { subjectId, status: 'APPROVED' },
      include: { category: true },
      orderBy: { submittedAt: 'desc' },
    });
  }

  create(dto: CreateYouTubeVideoDto, userId: string) {
    return this.prisma.video.create({
      data: {
        ...dto,
        submittedById: userId,
        status: 'APPROVED',
      },
    });
  }
}
