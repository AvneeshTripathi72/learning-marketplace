import { PrismaService } from '../prisma/prisma.service';
export declare class VideoHubService {
    private prisma;
    constructor(prisma: PrismaService);
    submitVideo(dto: any, userId: string): Promise<{
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    }>;
    getMyUploads(userId: string): Promise<({
        category: {
            name: string;
            id: string;
            isEnabled: boolean;
        };
    } & {
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    })[]>;
    getPendingQueue(): Promise<({
        category: {
            name: string;
            id: string;
            isEnabled: boolean;
        };
        submittedBy: {
            email: string;
            password: string;
            name: string;
            role: import(".prisma/client").$Enums.UserRole;
            publicationId: string | null;
            id: string;
            createdAt: Date;
            updatedAt: Date;
        };
    } & {
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    })[]>;
    moderateVideo(id: string, status: any): Promise<{
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    }>;
}
