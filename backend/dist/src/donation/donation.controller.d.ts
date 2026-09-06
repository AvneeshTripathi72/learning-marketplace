import { DonationService } from './donation.service';
import { CreateDonationDto } from './dto/create-donation.dto';
export declare class DonationController {
    private service;
    constructor(service: DonationService);
    findByChannel(channelName: string): Promise<any>;
    create(dto: CreateDonationDto): Promise<any>;
}
