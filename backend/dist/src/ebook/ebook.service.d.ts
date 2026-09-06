import { PrismaService } from '../prisma/prisma.service';
import { CreateEBookDto } from './dto/create-ebook.dto';
export declare class EBookService {
    private prisma;
    constructor(prisma: PrismaService);
    findBySubject(subjectId: string): import(".prisma/client").Prisma.PrismaPromise<{
        id: string;
        isActive: boolean;
        title: string;
        subjectId: string;
        coverUrl: string;
        fileUrl: string;
    }[]>;
    create(dto: CreateEBookDto): import(".prisma/client").Prisma.Prisma__EBookClient<{
        id: string;
        isActive: boolean;
        title: string;
        subjectId: string;
        coverUrl: string;
        fileUrl: string;
    }, never, import("@prisma/client/runtime/library").DefaultArgs>;
    toggleStatus(id: string, isActive: boolean): Promise<{
        id: string;
        isActive: boolean;
        title: string;
        subjectId: string;
        coverUrl: string;
        fileUrl: string;
    }>;
}
