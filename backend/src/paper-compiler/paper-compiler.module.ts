import { Module } from '@nestjs/common';
import { PaperCompilerService } from './paper-compiler.service';
import { PaperCompilerController } from './paper-compiler.controller';

@Module({
  controllers: [PaperCompilerController],
  providers: [PaperCompilerService],
  exports: [PaperCompilerService],
})
export class PaperCompilerModule {}
