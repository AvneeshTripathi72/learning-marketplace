import { VideoHubService } from './video-hub.service';
import { SubmitVideoDto } from './dto/submit-video.dto';
import { ModerateVideoDto } from './dto/moderate-video.dto';
export declare class VideoHubController {
    private service;
    constructor(service: VideoHubService);
    submitVideo(dto: SubmitVideoDto, req: any): import(".prisma/client").Prisma.Prisma__VideoClient<{
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    getMyUploads(req: any): import(".prisma/client").Prisma.PrismaPromise<{
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    }[]>;
    getPendingQueue(): import(".prisma/client").Prisma.PrismaPromise<({
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
    moderateVideo(id: string, dto: ModerateVideoDto): Promise<{
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
