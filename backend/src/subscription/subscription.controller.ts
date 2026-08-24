import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';
import { Roles } from '../auth/decorators/roles.decorator';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UserRole } from '@prisma/client';

@Controller('subscriptions')
export class SubscriptionController {
  constructor(private service: SubscriptionService) {}

  @Get('packages')
  getPackages() {
    return this.service.getPackages();
  }

  @Get('publication/:publicationId')
  getPublicationSubscription(@Param('publicationId') publicationId: string) {
    return this.service.getPublicationSubscription(publicationId);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.PUBLICATION, UserRole.ADMIN)
  createSubscription(@Body() dto: CreateSubscriptionDto) {
    return this.service.createSubscription(dto);
  }
}
