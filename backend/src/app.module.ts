import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { PublicationModule } from './publication/publication.module';
import { ContentHierarchyModule } from './content-hierarchy/content-hierarchy.module';
import { EBookModule } from './ebook/ebook.module';
import { YouTubeModule } from './youtube/youtube.module';
import { PaperCompilerModule } from './paper-compiler/paper-compiler.module';
import { VideoHubModule } from './video-hub/video-hub.module';
import { SubscriptionModule } from './subscription/subscription.module';
import { PaymentModule } from './payment/payment.module';
import { DonationModule } from './donation/donation.module';
import { ReportsModule } from './reports/reports.module';

import { AppController } from './app.controller';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    PublicationModule,
    ContentHierarchyModule,
    EBookModule,
    YouTubeModule,
    PaperCompilerModule,
    VideoHubModule,
    SubscriptionModule,
    PaymentModule,
    DonationModule,
    ReportsModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
