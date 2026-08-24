import { Module } from '@nestjs/common';
import { EBookService } from './ebook.service';
import { EBookController } from './ebook.controller';

@Module({
  controllers: [EBookController],
  providers: [EBookService],
  exports: [EBookService],
})
export class EBookModule {}
