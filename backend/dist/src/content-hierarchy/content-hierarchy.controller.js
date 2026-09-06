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
exports.ContentHierarchyController = void 0;
const common_1 = require("@nestjs/common");
const content_hierarchy_service_1 = require("./content-hierarchy.service");
let ContentHierarchyController = class ContentHierarchyController {
    constructor(service) {
        this.service = service;
    }
    getSeries(publicationId) {
        return this.service.getSeries(publicationId);
    }
    getClasses(seriesId) {
        return this.service.getClasses(seriesId);
    }
    getSubjects(classId) {
        return this.service.getSubjects(classId);
    }
};
exports.ContentHierarchyController = ContentHierarchyController;
__decorate([
    (0, common_1.Get)('series'),
    __param(0, (0, common_1.Query)('publicationId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ContentHierarchyController.prototype, "getSeries", null);
__decorate([
    (0, common_1.Get)('classes'),
    __param(0, (0, common_1.Query)('seriesId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ContentHierarchyController.prototype, "getClasses", null);
__decorate([
    (0, common_1.Get)('subjects'),
    __param(0, (0, common_1.Query)('classId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ContentHierarchyController.prototype, "getSubjects", null);
exports.ContentHierarchyController = ContentHierarchyController = __decorate([
    (0, common_1.Controller)('hierarchy'),
    __metadata("design:paramtypes", [content_hierarchy_service_1.ContentHierarchyService])
], ContentHierarchyController);
//# sourceMappingURL=content-hierarchy.controller.js.map