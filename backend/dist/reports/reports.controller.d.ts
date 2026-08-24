import { ReportsService } from './reports.service';
export declare class ReportsController {
    private service;
    constructor(service: ReportsService);
    getLeaderboard(): Promise<({
        category: {
            name: string;
            id: string;
            isEnabled: boolean;
        };
    } & {
        id: string;
        subjectId: string | null;
        url: string;
        platform: import(".prisma/client").$Enums.VideoPlatform;
        channelName: string;
        categoryId: string;
        status: import(".prisma/client").$Enums.VideoStatus;
        submittedById: string;
        submittedAt: Date;
    })[]>;
    getRevenueSummary(): Promise<{
        totalRevenue: number | import("@prisma/client/runtime/library").Decimal;
    }>;
}
