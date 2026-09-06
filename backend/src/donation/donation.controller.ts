import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { DonationService } from './donation.service';
import { CreateDonationDto } from './dto/create-donation.dto';


import { UserRole } from '../common/enums';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { AccessControlGuard } from '../auth/guards/access-control.guard';

@Controller('donations')
export class DonationController {
  constructor(private service: DonationService) {}

  @Get(':channelName')
  findByChannel(@Param('channelName') channelName: string) {
    return this.service.findByChannel(channelName);
  }

  @Post()
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'donation', action: 'ALL', roles: [UserRole.ADMIN] })
  create(@Body() dto: CreateDonationDto) {
    return this.service.create(dto);
  }
}
