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
var AuthService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
let AuthService = AuthService_1 = class AuthService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(AuthService_1.name);
        this.jwtSecret = process.env.JWT_SECRET || 'super_secret_jwt_key_2026';
    }
    async register(dto) {
        const cleanEmail = dto.email.trim().toLowerCase();
        const existing = await this.prisma.user.findUnique({ where: { email: cleanEmail } });
        if (existing) {
            this.logger.warn(`Register attempt failed (User already exists): ${cleanEmail}`);
            throw new common_1.BadRequestException('User email already registered. Please login instead.');
        }
        const hashedPassword = await bcrypt.hash(dto.password, 10);
        let pubId = null;
        if (dto.publicationId) {
            const pubExists = await this.prisma.publication.findUnique({ where: { id: dto.publicationId } });
            if (pubExists)
                pubId = dto.publicationId;
        }
        const user = await this.prisma.user.create({
            data: {
                name: dto.name,
                email: cleanEmail,
                password: hashedPassword,
                role: dto.role,
                publicationId: pubId,
            },
        });
        this.logger.log(`👤 New User Registered Successfully: ${user.email} | Role: ${user.role} | ID: ${user.id}`);
        const token = this.generateToken(user);
        return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, publicationId: user.publicationId } };
    }
    async login(dto) {
        const cleanEmail = dto.email.trim().toLowerCase();
        const user = await this.prisma.user.findUnique({ where: { email: cleanEmail } });
        if (!user) {
            this.logger.warn(`Login attempt failed (User not found): ${cleanEmail}`);
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        const isPasswordValid = await bcrypt.compare(dto.password, user.password);
        if (!isPasswordValid) {
            this.logger.warn(`Login attempt failed (Invalid password): ${cleanEmail}`);
            throw new common_1.UnauthorizedException('Invalid credentials');
        }
        this.logger.log(`🔐 User Logged In Successfully: ${user.email} | Role: ${user.role} | ID: ${user.id}`);
        const token = this.generateToken(user);
        return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, publicationId: user.publicationId } };
    }
    async getAllUsers() {
        try {
            const users = await this.prisma.user.findMany({
                select: { id: true, name: true, email: true, role: true, publicationId: true, createdAt: true },
                orderBy: { createdAt: 'desc' },
            });
            return users;
        }
        catch (e) {
            return [];
        }
    }
    generateToken(user) {
        return jwt.sign({ sub: user.id, email: user.email, role: user.role, publicationId: user.publicationId }, this.jwtSecret, { expiresIn: '7d' });
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = AuthService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AuthService);
//# sourceMappingURL=auth.service.js.map