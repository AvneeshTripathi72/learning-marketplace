import { ContentHierarchyService } from './content-hierarchy.service';
export declare class ContentHierarchyController {
    private service;
    constructor(service: ContentHierarchyService);
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
