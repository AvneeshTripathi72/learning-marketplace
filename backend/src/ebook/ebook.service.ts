import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateEBookDto } from './dto/create-ebook.dto';

@Injectable()
export class EBookService {
  constructor(private prisma: PrismaService) {}

  findBySubject(subjectId: string) {
    return this.prisma.eBook.findMany({ where: { subjectId, isActive: true } });
  }

  create(dto: CreateEBookDto) {
    return this.prisma.eBook.create({ data: dto });
  }

  async toggleStatus(id: string, isActive: boolean) {
    const ebook = await this.prisma.eBook.findUnique({ where: { id } });
    if (!ebook) throw new NotFoundException('eBook not found');
    return this.prisma.eBook.update({ where: { id }, data: { isActive } });
  }
}
