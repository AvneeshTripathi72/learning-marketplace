import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { DonationService } from './donation.service';
import { CreateDonationDto } from './dto/create-donation.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '../common/enums';

@Controller('donations')
export class DonationController {
  constructor(private service: DonationService) {}

  @Get(':channelName')
  findByChannel(@Param('channelName') channelName: string) {
    return this.service.findByChannel(channelName);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  create(@Body() dto: CreateDonationDto) {
    return this.service.create(dto);
  }
}
