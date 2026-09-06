import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  private readonly jwtSecret = process.env.JWT_SECRET || 'super_secret_jwt_key_2026';

  constructor(private prisma: PrismaService) {}

  async register(dto: RegisterDto) {
    const cleanEmail = dto.email.trim().toLowerCase();
    const existing = await this.prisma.user.findUnique({ where: { email: cleanEmail } });
    if (existing) throw new BadRequestException('User email already registered. Please login instead.');

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    
    let pubId: string | null = null;
    if (dto.publicationId) {
      const pubExists = await this.prisma.publication.findUnique({ where: { id: dto.publicationId } });
      if (pubExists) pubId = dto.publicationId;
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

    const token = this.generateToken(user);
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, publicationId: user.publicationId } };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);
    if (!isPasswordValid) throw new UnauthorizedException('Invalid credentials');

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
    } catch (e) {
      return [];
    }
  }

  private generateToken(user: any) {
    return jwt.sign(
      { sub: user.id, email: user.email, role: user.role, publicationId: user.publicationId },
      this.jwtSecret,
      { expiresIn: '7d' },
    );
  }
}
