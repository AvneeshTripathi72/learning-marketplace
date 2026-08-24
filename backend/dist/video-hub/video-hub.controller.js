"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.VideoHubController = void 0;
const common_1 = require("@nestjs/common");
const video_hub_service_1 = require("./video-hub.service");
const submit_video_dto_1 = require("./dto/submit-video.dto");
const moderate_video_dto_1 = require("./dto/moderate-video.dto");
const roles_decorator_1 = require("../auth/decorators/roles.decorator");
const roles_guard_1 = require("../auth/guards/roles.guard");
const client_1 = require("@prisma/client");
let VideoHubController = class VideoHubController {
    constructor(service) {
        this.service = service;
    }
    submitVideo(dto, req) {
        const userId = req.user?.sub || 'demo_user';
        return this.service.submitVideo(dto, userId);
    }
    getMyUploads(req) {
        const userId = req.user?.sub || 'demo_user';
        return this.service.getMyUploads(userId);
    }
    getPendingQueue() {
        return this.service.getPendingQueue();
    }
    moderateVideo(id, dto) {
        return this.service.moderateVideo(id, dto.status);
    }
};
exports.VideoHubController = VideoHubController;
__decorate([
    (0, common_1.Post)('submit'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [submit_video_dto_1.SubmitVideoDto, Object]),
    __metadata("design:returntype", void 0)
], VideoHubController.prototype, "submitVideo", null);
__decorate([
    (0, common_1.Get)('my-uploads'),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], VideoHubController.prototype, "getMyUploads", null);
__decorate([
    (0, common_1.Get)('admin/queue'),
    (0, common_1.UseGuards)(roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], VideoHubController.prototype, "getPendingQueue", null);
__decorate([
    (0, common_1.Patch)('admin/moderate/:id'),
    (0, common_1.UseGuards)(roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(client_1.UserRole.ADMIN),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, moderate_video_dto_1.ModerateVideoDto]),
    __metadata("design:returntype", void 0)
], VideoHubController.prototype, "moderateVideo", null);
exports.VideoHubController = VideoHubController = __decorate([
    (0, common_1.Controller)('video-hub'),
    __metadata("design:paramtypes", [video_hub_service_1.VideoHubService])
], VideoHubController);
//# sourceMappingURL=video-hub.controller.js.map