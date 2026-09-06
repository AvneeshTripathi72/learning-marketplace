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
exports.ReportsService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let ReportsService = class ReportsService {
    constructor(supabase) {
        this.supabase = supabase;
    }
    async getLeaderboard() {
        const { data, error } = await this.supabase.client
            .from('Video')
            .select('*, category:Category(*)')
            .eq('status', 'APPROVED')
            .order('submittedAt', { ascending: false })
            .limit(10);
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async getRevenueSummary() {
        const { data, error } = await this.supabase.client
            .from('Payment')
            .select('amount')
            .eq('status', 'SUCCESSFUL');
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        const totalRevenue = data.reduce((sum, payment) => sum + (Number(payment.amount) || 0), 0);
        return { totalRevenue };
    }
};
exports.ReportsService = ReportsService;
exports.ReportsService = ReportsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], ReportsService);
//# sourceMappingURL=reports.service.js.map