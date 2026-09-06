import { VideoHubService } from './video-hub.service';
import { SubmitVideoDto } from './dto/submit-video.dto';
export declare class VideoHubController {
    private service;
    constructor(service: VideoHubService);
    submitVideo(dto: SubmitVideoDto, req: any): Promise<any>;
    getMyUploads(req: any): Promise<any[]>;
    getPendingQueue(): Promise<any[]>;
    moderateVideo(id: string, dto: any): Promise<any>;
}
