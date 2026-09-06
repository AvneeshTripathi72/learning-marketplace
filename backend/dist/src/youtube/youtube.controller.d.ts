import { YouTubeService } from './youtube.service';
import { CreateYouTubeVideoDto } from './dto/create-youtube-video.dto';
export declare class YouTubeController {
    private service;
    constructor(service: YouTubeService);
    findBySubject(subjectId: string): Promise<any[]>;
    create(dto: CreateYouTubeVideoDto, req: any): Promise<any>;
}
