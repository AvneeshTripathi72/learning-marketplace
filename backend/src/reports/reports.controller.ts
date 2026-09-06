import { Controller, Get, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';


import { UserRole } from '../common/enums';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { AccessControlGuard } from '../auth/guards/access-control.guard';

@Controller('reports')
export class ReportsController {
  constructor(private service: ReportsService) {}

  @Get('leaderboard')
  getLeaderboard() {
    return this.service.getLeaderboard();
  }

  @Get('revenue')
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'reports', action: 'ALL', roles: [UserRole.ADMIN] })
  getRevenueSummary() {
    return this.service.getRevenueSummary();
  }
}
