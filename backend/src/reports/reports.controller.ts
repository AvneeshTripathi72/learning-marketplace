import { Controller, Get, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '@prisma/client';

@Controller('reports')
export class ReportsController {
  constructor(private service: ReportsService) {}

  @Get('leaderboard')
  getLeaderboard() {
    return this.service.getLeaderboard();
  }

  @Get('revenue')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  getRevenueSummary() {
    return this.service.getRevenueSummary();
  }
}
