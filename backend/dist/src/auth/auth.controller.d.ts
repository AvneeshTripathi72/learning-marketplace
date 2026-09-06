import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
    register(dto: RegisterDto): Promise<{
        token: string;
        user: {
            id: any;
            name: any;
            email: any;
            role: any;
            publicationId: any;
        };
    }>;
    login(dto: LoginDto): Promise<{
        token: string;
        user: {
            id: any;
            name: any;
            email: any;
            role: any;
            publicationId: any;
        };
    }>;
    getAllUsers(): Promise<any>;
}
