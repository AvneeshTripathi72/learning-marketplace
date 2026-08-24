import { YouTubeService } from './youtube.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';
export declare class YouTubeController {
    private service;
    constructor(service: YouTubeService);
    findBySubject(subjectId: string): import(".prisma/client").Prisma.PrismaPromise<({
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
    create(dto: CreateYouTubeVideoDto, req: any): import(".prisma/client").Prisma.Prisma__VideoClient<{
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
}
