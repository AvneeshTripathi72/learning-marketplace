import { Controller, Get, Query } from '@nestjs/common';
import { ContentHierarchyService } from './content-hierarchy.service';

@Controller('hierarchy')
export class ContentHierarchyController {
  constructor(private service: ContentHierarchyService) {}

  @Get('series')
  getSeries(@Query('publicationId') publicationId: string) {
    return this.service.getSeries(publicationId);
  }

  @Get('classes')
  getClasses(@Query('seriesId') seriesId: string) {
    return this.service.getClasses(seriesId);
  }

  @Get('subjects')
  getSubjects(@Query('classId') classId: string) {
    return this.service.getSubjects(classId);
  }
}
