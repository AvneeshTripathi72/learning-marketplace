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
const supabase_service_1 = require("../supabase/supabase.service");
const enums_1 = require("../common/enums");
let SubscriptionService = class SubscriptionService {
    constructor(supabase) {
        this.supabase = supabase;
    }
    getPackages() {
        return [
            { tier: enums_1.PackageTier.SILVER, price: 999, videoLimit: 10, name: 'Silver Tier' },
            { tier: enums_1.PackageTier.BRONZE, price: 1999, videoLimit: 25, name: 'Bronze Tier' },
            { tier: enums_1.PackageTier.GOLD, price: 3999, videoLimit: 50, name: 'Gold Tier' },
            { tier: enums_1.PackageTier.DIAMOND, price: 7999, videoLimit: -1, name: 'Diamond Unlimited' },
        ];
    }
    async getPublicationSubscription(publicationId) {
        const { data: sub, error } = await this.supabase.client
            .from('Subscription')
            .select('*, payment:Payment(*)')
            .eq('publicationId', publicationId)
            .eq('status', enums_1.SubscriptionStatus.ACTIVE)
            .order('endDate', { ascending: false })
            .limit(1)
            .single();
        if (error && error.code !== 'PGRST116') {
            throw new common_1.InternalServerErrorException(error.message);
        }
        return sub || { status: enums_1.SubscriptionStatus.INACTIVE, package: null };
    }
    async createSubscription(dto) {
        const startDate = new Date();
        const endDate = new Date();
        endDate.setMonth(endDate.getMonth() + dto.durationMonths);
        const { data, error } = await this.supabase.client
            .from('Subscription')
            .insert({
            publicationId: dto.publicationId,
            package: dto.package,
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString(),
            status: enums_1.SubscriptionStatus.ACTIVE,
            paymentId: dto.paymentId,
        })
            .select()
            .single();
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
};
exports.SubscriptionService = SubscriptionService;
exports.SubscriptionService = SubscriptionService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], SubscriptionService);
//# sourceMappingURL=subscription.service.js.map