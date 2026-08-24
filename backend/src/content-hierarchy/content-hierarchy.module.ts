import { Module } from '@nestjs/common';
import { ContentHierarchyService } from './content-hierarchy.service';
import { ContentHierarchyController } from './content-hierarchy.controller';

@Module({
  controllers: [ContentHierarchyController],
  providers: [ContentHierarchyService],
  exports: [ContentHierarchyService],
})
export class ContentHierarchyModule {}
