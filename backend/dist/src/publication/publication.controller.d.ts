import { PublicationService } from './publication.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';
export declare class PublicationController {
    private publicationService;
    constructor(publicationService: PublicationService);
    findAll(): Promise<{
        email: string;
        name: string;
        id: string;
        createdAt: Date;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
    }[]>;
    findOne(id: string): Promise<{
        email: string;
        name: string;
        id: string;
        createdAt: Date;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
    }>;
    create(dto: CreatePublicationDto): Promise<{
        email: string;
        name: string;
        id: string;
        createdAt: Date;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
    }>;
    update(id: string, dto: UpdatePublicationDto): Promise<{
        email: string;
        name: string;
        id: string;
        createdAt: Date;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
    }>;
    toggleStatus(id: string, isActive: boolean): Promise<{
        email: string;
        name: string;
        id: string;
        createdAt: Date;
        mobile: string;
        address: string;
        logoUrl: string;
        inquiryNumber: string;
        isActive: boolean;
    }>;
}
