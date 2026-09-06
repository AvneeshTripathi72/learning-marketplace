import { PublicationService } from './publication.service';
import { CreatePublicationDto } from './dto/create-publication.dto';
import { UpdatePublicationDto } from './dto/update-publication.dto';
export declare class PublicationController {
    private publicationService;
    constructor(publicationService: PublicationService);
    findAll(): Promise<any[]>;
    findOne(id: string): Promise<any>;
    create(dto: CreatePublicationDto): Promise<any>;
    update(id: string, dto: UpdatePublicationDto): Promise<any>;
    toggleStatus(id: string, isActive: boolean): Promise<any>;
}
