# Node.js / NestJS Backend — Day 07: Public Hub Moderation Queue APIs

## 🎯 Objective
Build video submission moderation workflow service (`video-moderation.service.ts`) and administrative moderation endpoints (`PENDING -> APPROVED / REJECTED`).

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Moderation Endpoints**:
  - `GET /admin/moderation/pending` (Fetch queue of submitted videos awaiting review).
  - `PATCH /videos/:id/approve` (Admin endpoint: set `VideoStatus = APPROVED`).
  - `PATCH /videos/:id/reject` (Admin endpoint: set `VideoStatus = REJECTED`).
- [ ] **User Submissions Endpoint**: `GET /users/me/submissions` (Returns user's submitted links with status badges).
