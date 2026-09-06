import { PrismaService } from '../prisma/prisma.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';
export declare class YouTubeService {
    private prisma;
    constructor(prisma: PrismaService);
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
    create(dto: CreateYouTubeVideoDto, userId: string): import(".prisma/client").Prisma.Prisma__VideoClient<{
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
