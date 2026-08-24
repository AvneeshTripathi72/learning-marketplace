# Node.js / NestJS Backend — Day 05: Publication YouTube Mapping & Category APIs

## 🎯 Objective
Build NestJS controllers (`video.controller.ts`, `category.controller.ts`) for managing YouTube video links mapped to publication taxonomy, and server-driven category toggle APIs (`Category.isEnabled`).

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Video Endpoints**:
  - `GET /videos?category=...&status=approved` (Public Hub video list filtered by enabled categories).
  - `POST /videos` (Submit video link for moderation with platform detection: `YOUTUBE`, `INSTAGRAM`, `FACEBOOK`).
- [ ] **Category Endpoints**:
  - `GET /categories` (Returns active categories list).
  - `PATCH /categories/:id/toggle` (Admin endpoint: toggle `isEnabled` parental control setting).
