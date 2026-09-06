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
exports.VideoHubService = void 0;
const common_1 = require("@nestjs/common");
const supabase_service_1 = require("../supabase/supabase.service");
let VideoHubService = class VideoHubService {
    constructor(supabase) {
        this.supabase = supabase;
    }
    async submitVideo(dto, userId) {
        const categoryName = dto.category || 'Educational';
        let { data: category } = await this.supabase.client
            .from('Category')
            .select('*')
            .ilike('name', categoryName)
            .single();
        if (!category) {
            const { data: newCategory, error } = await this.supabase.client
                .from('Category')
                .insert({ name: categoryName, isEnabled: true })
                .select()
                .single();
            if (error)
                throw new common_1.InternalServerErrorException(error.message);
            category = newCategory;
        }
        let { data: user } = await this.supabase.client
            .from('User')
            .select('*')
            .or(`id.eq.${userId},email.eq.hariom.info07@gmail.com`)
            .limit(1)
            .single();
        if (!user) {
            const { data: firstUser } = await this.supabase.client
                .from('User')
                .select('*')
                .limit(1)
                .single();
            user = firstUser;
        }
        if (!user) {
            const { data: newUser, error } = await this.supabase.client
                .from('User')
                .insert({
                name: 'Public Student User',
                email: 'public.student@ebook.app',
                password: 'Password123!',
                role: 'PUBLIC',
            })
                .select()
                .single();
            if (error)
                throw new common_1.InternalServerErrorException(error.message);
            user = newUser;
        }
        let platform = 'YOUTUBE';
        const urlLower = (dto.url || '').toLowerCase();
        if (urlLower.includes('instagram'))
            platform = 'INSTAGRAM';
        if (urlLower.includes('facebook'))
            platform = 'FACEBOOK';
        const { data: video, error } = await this.supabase.client
            .from('Video')
            .insert({
            url: dto.url,
            platform: platform,
            channelName: dto.channelName || 'User Channel',
            categoryId: category.id,
            submittedById: user.id,
            status: 'PENDING',
        })
            .select()
            .single();
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return video;
    }
    async getMyUploads(userId) {
        const { data: adminUser } = await this.supabase.client
            .from('User')
            .select('id')
            .eq('email', 'hariom.info07@gmail.com')
            .single();
        let orQuery = `submittedById.eq.${userId}`;
        if (adminUser) {
            orQuery += `,submittedById.eq.${adminUser.id}`;
        }
        const { data, error } = await this.supabase.client
            .from('Video')
            .select('*, category:Category(*)')
            .or(orQuery)
            .order('submittedAt', { ascending: false });
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async getPendingQueue() {
        const { data, error } = await this.supabase.client
            .from('Video')
            .select('*, submittedBy:User(*), category:Category(*)')
            .eq('status', 'PENDING')
            .order('submittedAt', { ascending: false });
        if (error)
            throw new common_1.InternalServerErrorException(error.message);
        return data;
    }
    async moderateVideo(id, status) {
        const { data: video, error: findError } = await this.supabase.client
            .from('Video')
            .select('*')
            .eq('id', id)
            .single();
        if (findError || !video)
            throw new common_1.NotFoundException('Video not found');
        const { data, error: updateError } = await this.supabase.client
            .from('Video')
            .update({ status })
            .eq('id', id)
            .select()
            .single();
        if (updateError)
            throw new common_1.InternalServerErrorException(updateError.message);
        return data;
    }
};
exports.VideoHubService = VideoHubService;
exports.VideoHubService = VideoHubService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [supabase_service_1.SupabaseService])
], VideoHubService);
//# sourceMappingURL=video-hub.service.js.map