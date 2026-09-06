import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    register(dto: RegisterDto): Promise<{
        token: string;
        user: {
            id: string;
            name: string;
            email: string;
            role: import(".prisma/client").$Enums.UserRole;
            publicationId: string;
        };
    }>;
    login(dto: LoginDto): Promise<{
        token: string;
        user: {
            id: string;
            name: string;
            email: string;
            role: import(".prisma/client").$Enums.UserRole;
            publicationId: string;
        };
    }>;
    getAllUsers(): Promise<{
        email: string;
        name: string;
        role: import(".prisma/client").$Enums.UserRole;
        publicationId: string;
        id: string;
        createdAt: Date;
    }[]>;
}
