import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';

@Injectable()
export class PublicationService {
  constructor(private prisma: PrismaService) {}

  async findAll() {
    return this.prisma.publication.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const pub = await this.prisma.publication.findUnique({ where: { id } });
    if (!pub) throw new NotFoundException('Publication not found');
    return pub;
  }

  async create(dto: CreatePublicationDto) {
    return this.prisma.publication.create({ data: dto });
  }

  async update(id: string, dto: UpdatePublicationDto) {
    await this.findOne(id);
    return this.prisma.publication.update({
      where: { id },
      data: dto,
    });
  }

  async toggleStatus(id: string, isActive: boolean) {
    await this.findOne(id);
    return this.prisma.publication.update({
      where: { id },
      data: { isActive },
    });
  }
}
