import { PrismaService } from '../prisma/prisma.service';
export declare class ContentHierarchyService {
    private prisma;
    constructor(prisma: PrismaService);
    getSeries(publicationId: string): import(".prisma/client").Prisma.PrismaPromise<{
        name: string;
        publicationId: string;
        id: string;
    }[]>;
    getClasses(seriesId: string): import(".prisma/client").Prisma.PrismaPromise<{
        name: string;
        id: string;
        seriesId: string;
    }[]>;
    getSubjects(classId: string): import(".prisma/client").Prisma.PrismaPromise<{
        name: string;
        id: string;
        classId: string;
    }[]>;
}
