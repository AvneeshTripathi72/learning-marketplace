import { VideoHubService } from './video-hub.service';
import { SubmitVideoDto } from './dto/submit-video.dto';
export declare class VideoHubController {
    private service;
    constructor(service: VideoHubService);
    submitVideo(dto: SubmitVideoDto, req: any): Promise<{
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
    getMyUploads(req: any): Promise<({
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
    moderateVideo(id: string, dto: any): Promise<{
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
