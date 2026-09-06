import { DonationService } from './donation.service';
import { CreateDonationDto } from './dto/create-donation.dto';
export declare class DonationController {
    private service;
    constructor(service: DonationService);
    findByChannel(channelName: string): Promise<{
        id: string;
        createdAt: Date;
        channelName: string;
        upiId: string;
        qrCodeUrl: string;
        creatorPhotoUrl: string;
    }>;
    create(dto: CreateDonationDto): import(".prisma/client").Prisma.Prisma__DonationClient<{
        id: string;
        createdAt: Date;
        channelName: string;
        upiId: string;
        qrCodeUrl: string;
        creatorPhotoUrl: string;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
}
