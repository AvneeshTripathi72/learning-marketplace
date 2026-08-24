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
const prisma_service_1 = require("../prisma/prisma.service");
let VideoHubService = class VideoHubService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    submitVideo(dto, userId) {
        return this.prisma.video.create({
            data: {
                ...dto,
                submittedById: userId,
                status: 'PENDING',
            },
        });
    }
    getMyUploads(userId) {
        return this.prisma.video.findMany({
            where: { submittedById: userId },
            orderBy: { submittedAt: 'desc' },
        });
    }
    getPendingQueue() {
        return this.prisma.video.findMany({
            where: { status: 'PENDING' },
            include: { submittedBy: true },
            orderBy: { submittedAt: 'asc' },
        });
    }
    async moderateVideo(id, status) {
        const video = await this.prisma.video.findUnique({ where: { id } });
        if (!video)
            throw new common_1.NotFoundException('Video not found');
        return this.prisma.video.update({
            where: { id },
            data: { status },
        });
    }
};
exports.VideoHubService = VideoHubService;
exports.VideoHubService = VideoHubService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], VideoHubService);
//# sourceMappingURL=video-hub.service.js.map