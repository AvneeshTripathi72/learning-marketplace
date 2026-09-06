"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentStatus = exports.SubscriptionStatus = exports.PackageTier = exports.VideoStatus = exports.VideoPlatform = exports.UserRole = void 0;
var UserRole;
(function (UserRole) {
    UserRole["PUBLICATION"] = "PUBLICATION";
    UserRole["PUBLIC"] = "PUBLIC";
    UserRole["ADMIN"] = "ADMIN";
})(UserRole || (exports.UserRole = UserRole = {}));
var VideoPlatform;
(function (VideoPlatform) {
    VideoPlatform["YOUTUBE"] = "YOUTUBE";
    VideoPlatform["INSTAGRAM"] = "INSTAGRAM";
    VideoPlatform["FACEBOOK"] = "FACEBOOK";
})(VideoPlatform || (exports.VideoPlatform = VideoPlatform = {}));
var VideoStatus;
(function (VideoStatus) {
    VideoStatus["PENDING"] = "PENDING";
    VideoStatus["APPROVED"] = "APPROVED";
    VideoStatus["REJECTED"] = "REJECTED";
    VideoStatus["INACTIVE"] = "INACTIVE";
    VideoStatus["DELETED"] = "DELETED";
})(VideoStatus || (exports.VideoStatus = VideoStatus = {}));
var PackageTier;
(function (PackageTier) {
    PackageTier["SILVER"] = "SILVER";
    PackageTier["BRONZE"] = "BRONZE";
    PackageTier["GOLD"] = "GOLD";
    PackageTier["DIAMOND"] = "DIAMOND";
})(PackageTier || (exports.PackageTier = PackageTier = {}));
var SubscriptionStatus;
(function (SubscriptionStatus) {
    SubscriptionStatus["ACTIVE"] = "ACTIVE";
    SubscriptionStatus["INACTIVE"] = "INACTIVE";
    SubscriptionStatus["EXPIRED"] = "EXPIRED";
    SubscriptionStatus["PENDING_UPGRADE"] = "PENDING_UPGRADE";
})(SubscriptionStatus || (exports.SubscriptionStatus = SubscriptionStatus = {}));
var PaymentStatus;
(function (PaymentStatus) {
    PaymentStatus["PENDING"] = "PENDING";
    PaymentStatus["SUCCESSFUL"] = "SUCCESSFUL";
    PaymentStatus["FAILED"] = "FAILED";
    PaymentStatus["REFUNDED"] = "REFUNDED";
    PaymentStatus["CANCELLED"] = "CANCELLED";
})(PaymentStatus || (exports.PaymentStatus = PaymentStatus = {}));
//# sourceMappingURL=enums.js.map