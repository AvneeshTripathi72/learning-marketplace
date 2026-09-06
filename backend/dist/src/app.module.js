"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const prisma_module_1 = require("./prisma/prisma.module");
const auth_module_1 = require("./auth/auth.module");
const publication_module_1 = require("./publication/publication.module");
const content_hierarchy_module_1 = require("./content-hierarchy/content-hierarchy.module");
const ebook_module_1 = require("./ebook/ebook.module");
const youtube_module_1 = require("./youtube/youtube.module");
const paper_compiler_module_1 = require("./paper-compiler/paper-compiler.module");
const video_hub_module_1 = require("./video-hub/video-hub.module");
const subscription_module_1 = require("./subscription/subscription.module");
const payment_module_1 = require("./payment/payment.module");
const donation_module_1 = require("./donation/donation.module");
const reports_module_1 = require("./reports/reports.module");
const app_controller_1 = require("./app.controller");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            prisma_module_1.PrismaModule,
            auth_module_1.AuthModule,
            publication_module_1.PublicationModule,
            content_hierarchy_module_1.ContentHierarchyModule,
            ebook_module_1.EBookModule,
            youtube_module_1.YouTubeModule,
            paper_compiler_module_1.PaperCompilerModule,
            video_hub_module_1.VideoHubModule,
            subscription_module_1.SubscriptionModule,
            payment_module_1.PaymentModule,
            donation_module_1.DonationModule,
            reports_module_1.ReportsModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map