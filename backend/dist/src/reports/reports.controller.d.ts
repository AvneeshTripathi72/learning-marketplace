import { ReportsService } from './reports.service';
export declare class ReportsController {
    private service;
    constructor(service: ReportsService);
    getLeaderboard(): Promise<any[]>;
    getRevenueSummary(): Promise<{
        totalRevenue: number;
    }>;
}
