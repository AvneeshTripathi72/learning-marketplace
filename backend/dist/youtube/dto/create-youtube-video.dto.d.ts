import { VideoPlatform } from '@prisma/client';
export declare class CreateYouTubeVideoDto {
    url: string;
    platform: VideoPlatform;
    channelName: string;
    categoryId: string;
    subjectId?: string;
}
