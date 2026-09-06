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
exports.ContentHierarchyService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let ContentHierarchyService = class ContentHierarchyService {
    constructor(supabase) {
        this.supabase = supabase;
    }
    async getSeries(publicationId) {
        const { data, error } = await this.supabase.client
            .from('Series')
            .select('*')
            .eq('publicationId', publicationId);
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async getClasses(seriesId) {
        const { data, error } = await this.supabase.client
            .from('Class')
            .select('*')
            .eq('seriesId', seriesId);
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async getSubjects(classId) {
        const { data, error } = await this.supabase.client
            .from('Subject')
            .select('*')
            .eq('classId', classId);
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
};
exports.ContentHierarchyService = ContentHierarchyService;
exports.ContentHierarchyService = ContentHierarchyService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], ContentHierarchyService);
//# sourceMappingURL=content-hierarchy.service.js.map