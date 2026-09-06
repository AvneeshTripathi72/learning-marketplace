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
exports.EBookController = void 0;
const common_1 = require("@nestjs/common");
const ebook_service_1 = require("./ebook.service");
const create_ebook_dto_1 = require("./dto/create-ebook.dto");
const roles_decorator_1 = require("../auth/decorators/roles.decorator");
const roles_guard_1 = require("../auth/guards/roles.guard");
const enums_1 = require("../common/enums");
let EBookController = class EBookController {
    constructor(service) {
        this.service = service;
    }
    findBySubject(subjectId) {
        return this.service.findBySubject(subjectId);
    }
    create(dto) {
        return this.service.create(dto);
    }
    toggleStatus(id, isActive) {
        return this.service.toggleStatus(id, isActive);
    }
};
exports.EBookController = EBookController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('subjectId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], EBookController.prototype, "findBySubject", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(enums_1.UserRole.ADMIN),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_ebook_dto_1.CreateEBookDto]),
    __metadata("design:returntype", void 0)
], EBookController.prototype, "create", null);
__decorate([
    (0, common_1.Patch)(':id/status'),
    (0, common_1.UseGuards)(roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(enums_1.UserRole.ADMIN),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)('isActive')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Boolean]),
    __metadata("design:returntype", void 0)
], EBookController.prototype, "toggleStatus", null);
exports.EBookController = EBookController = __decorate([
    (0, common_1.Controller)('ebooks'),
    __metadata("design:paramtypes", [ebook_service_1.EBookService])
], EBookController);
//# sourceMappingURL=ebook.controller.js.map