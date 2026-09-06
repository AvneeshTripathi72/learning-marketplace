import { VideoPlatform } from '../../common/enums';
export declare class CreateYouTubeVideoDto {
    url: string;
    platform: VideoPlatform;
    channelName: string;
    categoryId: string;
    subjectId?: string;
}
