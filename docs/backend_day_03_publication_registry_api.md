# Node.js / NestJS Backend — Day 03: Publication Management APIs

## 🎯 Objective
Build administrative NestJS APIs (`publication.controller.ts`) for registering, managing, activating, deactivating multi-tenant Publications, and managing publication inquiry numbers.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Publication Controller (`publication.controller.ts`)**:
  - `GET /publications` (Fetch all publications list).
  - `POST /publications` (Admin endpoint: register new publication with logoUrl, address, mobile, inquiryNumber).
  - `PATCH /publications/:id/activate` (Admin toggle active status).
  - `PATCH /publications/:id/deactivate` (Admin toggle inactive status).
- [ ] **S3 / Cloudflare R2 Multer Storage Service**: Presigned URL generator for publication logo uploads.
