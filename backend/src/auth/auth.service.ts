import { Injectable, UnauthorizedException, BadRequestException, Logger } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly jwtSecret = process.env.JWT_SECRET || 'super_secret_jwt_key_2026';

  constructor(private supabase: SupabaseService) {}

  async register(dto: RegisterDto) {
    const cleanEmail = dto.email.trim().toLowerCase();
    
    const { data: existing } = await this.supabase.from('User').select('*').eq('email', cleanEmail).single();
    if (existing) {
      this.logger.warn(`Register attempt failed (User already exists): ${cleanEmail}`);
      throw new BadRequestException('User email already registered. Please login instead.');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    
    let pubId: string | null = null;
    if (dto.publicationId) {
      const { data: pubExists } = await this.supabase.from('Publication').select('id').eq('id', dto.publicationId).single();
      if (pubExists) pubId = dto.publicationId;
    }

    const { data: user, error } = await this.supabase.from('User').insert([
      {
        name: dto.name,
        email: cleanEmail,
        password: hashedPassword,
        role: dto.role,
        publicationId: pubId,
      }
    ]).select().single();

    if (error || !user) {
       throw new BadRequestException('Error creating user');
    }

    this.logger.log(`👤 New User Registered Successfully: ${user.email} | Role: ${user.role} | ID: ${user.id}`);

    const token = this.generateToken(user);
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, publicationId: user.publicationId } };
  }

  async login(dto: LoginDto) {
    const cleanEmail = dto.email.trim().toLowerCase();
    const { data: user } = await this.supabase.from('User').select('*').eq('email', cleanEmail).single();
    if (!user) {
      this.logger.warn(`Login attempt failed (User not found): ${cleanEmail}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);
    if (!isPasswordValid) {
      this.logger.warn(`Login attempt failed (Invalid password): ${cleanEmail}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    this.logger.log(`🔐 User Logged In Successfully: ${user.email} | Role: ${user.role} | ID: ${user.id}`);

    const token = this.generateToken(user);
    return { token, user: { id: user.id, name: user.name, email: user.email, role: user.role, publicationId: user.publicationId } };
  }

  async getAllUsers() {
    try {
      const { data: users, error } = await this.supabase.from('User').select('id, name, email, role, publicationId, createdAt').order('createdAt', { ascending: false });
      if (error) throw error;
      return users || [];
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
