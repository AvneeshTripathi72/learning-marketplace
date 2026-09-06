import { Module } from '@nestjs/common';
import { EBookService } from './ebook.service';
import { EBookController } from './ebook.controller';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [EBookController],
  providers: [EBookService],
  exports: [EBookService],
})
export class EBookModule {}

