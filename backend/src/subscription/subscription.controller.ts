import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { SubscriptionService } from './subscription.service';
import { CreateSubscriptionDto } from './dto/create-subscription.dto';


import { UserRole } from '../common/enums';
import { RequirePermissions } from '../auth/decorators/permissions.decorator';
import { AccessControlGuard } from '../auth/guards/access-control.guard';

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
  @UseGuards(AccessControlGuard)
  @RequirePermissions({ module: 'subscription', action: 'ALL', roles: [UserRole.PUBLICATION, UserRole.ADMIN] })
  createSubscription(@Body() dto: CreateSubscriptionDto) {
    return this.service.createSubscription(dto);
  }
}
