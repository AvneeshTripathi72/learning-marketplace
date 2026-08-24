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
exports.PublicationService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let PublicationService = class PublicationService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async findAll() {
        return this.prisma.publication.findMany({
            orderBy: { createdAt: 'desc' },
        });
    }
    async findOne(id) {
        const pub = await this.prisma.publication.findUnique({ where: { id } });
        if (!pub)
            throw new common_1.NotFoundException('Publication not found');
        return pub;
    }
    async create(dto) {
        return this.prisma.publication.create({ data: dto });
    }
    async update(id, dto) {
        await this.findOne(id);
        return this.prisma.publication.update({
            where: { id },
            data: dto,
        });
    }
    async toggleStatus(id, isActive) {
        await this.findOne(id);
        return this.prisma.publication.update({
            where: { id },
            data: { isActive },
        });
    }
};
exports.PublicationService = PublicationService;
exports.PublicationService = PublicationService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PublicationService);
//# sourceMappingURL=publication.service.js.map