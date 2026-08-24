import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ContentHierarchyService {
  constructor(private prisma: PrismaService) {}

  getSeries(publicationId: string) {
    return this.prisma.series.findMany({ where: { publicationId } });
  }

  getClasses(seriesId: string) {
    return this.prisma.class.findMany({ where: { seriesId } });
  }

  getSubjects(classId: string) {
    return this.prisma.subject.findMany({ where: { classId } });
  }
}
