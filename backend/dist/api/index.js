"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
require("reflect-metadata");
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const app_module_1 = require("../src/app.module");
let cachedServer;
async function bootstrap() {
    if (!cachedServer) {
        const app = await core_1.NestFactory.create(app_module_1.AppModule);
        app.enableCors();
        app.setGlobalPrefix('api/v1');
        app.useGlobalPipes(new common_1.ValidationPipe({ whitelist: true, transform: true }));
        await app.init();
        cachedServer = app.getHttpAdapter().getInstance();
    }
    return cachedServer;
}
async function default_1(req, res) {
    const server = await bootstrap();
    return server(req, res);
}
//# sourceMappingURL=index.js.map