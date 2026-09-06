export declare class AppController {
    getHealth(): {
        status: string;
        service: string;
        timestamp: string;
    };
    getHealthCheck(): {
        status: string;
        timestamp: string;
    };
}
