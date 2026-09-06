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
exports.EBookService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let EBookService = class EBookService {
    constructor(supabase) {
        this.supabase = supabase;
    }
    async findBySubject(subjectId) {
        const { data, error } = await this.supabase.client
            .from('EBook')
            .select('*')
            .eq('subjectId', subjectId)
            .eq('isActive', true);
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async create(dto) {
        const { data, error } = await this.supabase.client
            .from('EBook')
            .insert(dto)
            .select()
            .single();
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async toggleStatus(id, isActive) {
        const { data: ebook, error: findError } = await this.supabase.client
            .from('EBook')
            .select('*')
            .eq('id', id)
            .single();
        if (findError || !ebook)
            throw new common_1.NotFoundException('eBook not found');
        const { data, error: updateError } = await this.supabase.client
            .from('EBook')
            .update({ isActive })
            .eq('id', id)
            .select()
            .single();
        if (updateError)
            throw new common_1.InternalServerErrorException(updateError.message);
        return data;
    }
};
exports.EBookService = EBookService;
exports.EBookService = EBookService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], EBookService);
//# sourceMappingURL=ebook.service.js.map