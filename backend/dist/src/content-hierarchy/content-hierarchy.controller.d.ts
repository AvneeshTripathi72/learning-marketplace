import { ContentHierarchyService } from './content-hierarchy.service';
export declare class ContentHierarchyController {
    private service;
    constructor(service: ContentHierarchyService);
    getSeries(publicationId: string): Promise<any[]>;
    getClasses(seriesId: string): Promise<any[]>;
    getSubjects(classId: string): Promise<any[]>;
}
