import { VideoPlatform } from '@prisma/client';
export declare class SubmitVideoDto {
    url: string;
    platform: VideoPlatform;
    channelName: string;
    categoryId: string;
}
