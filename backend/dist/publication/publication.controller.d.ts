import { PublicationService } from './publication.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';
export declare class PublicationController {
    private publicationService;
    constructor(publicationService: PublicationService);
    findAll(): Promise<{
        id: string;
        name: string;
        email: string;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
        createdAt: Date;
    }[]>;
    findOne(id: string): Promise<{
        id: string;
        name: string;
        email: string;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
        createdAt: Date;
    }>;
    create(dto: CreatePublicationDto): Promise<{
        id: string;
        name: string;
        email: string;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
        createdAt: Date;
    }>;
    update(id: string, dto: UpdatePublicationDto): Promise<{
        id: string;
        name: string;
        email: string;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
        createdAt: Date;
    }>;
    toggleStatus(id: string, isActive: boolean): Promise<{
        id: string;
        name: string;
        email: string;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
        createdAt: Date;
    }>;
}
