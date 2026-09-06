"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SubscriptionService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let SubscriptionService = class SubscriptionService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    getPackages() {
        return [
            { tier: client_1.PackageTier.SILVER, price: 999, videoLimit: 10, name: 'Silver Tier' },
            { tier: client_1.PackageTier.BRONZE, price: 1999, videoLimit: 25, name: 'Bronze Tier' },
            { tier: client_1.PackageTier.GOLD, price: 3999, videoLimit: 50, name: 'Gold Tier' },
            { tier: client_1.PackageTier.DIAMOND, price: 7999, videoLimit: -1, name: 'Diamond Unlimited' },
        ];
    }
    async getPublicationSubscription(publicationId) {
        const sub = await this.prisma.subscription.findFirst({
            where: { publicationId, status: client_1.SubscriptionStatus.ACTIVE },
            orderBy: { endDate: 'desc' },
            include: { payment: true },
        });
        return sub || { status: client_1.SubscriptionStatus.INACTIVE, package: null };
    }
    async createSubscription(dto) {
        const startDate = new Date();
        const endDate = new Date();
        endDate.setMonth(endDate.getMonth() + dto.durationMonths);
        return this.prisma.subscription.create({
            data: {
                publicationId: dto.publicationId,
                package: dto.package,
                startDate,
                endDate,
                status: client_1.SubscriptionStatus.ACTIVE,
                paymentId: dto.paymentId,
            },
        });
    }
};
exports.SubscriptionService = SubscriptionService;
exports.SubscriptionService = SubscriptionService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SubscriptionService);
//# sourceMappingURL=subscription.service.js.map