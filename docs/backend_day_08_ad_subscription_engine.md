# Node.js / NestJS Backend — Day 08: Ad Subscription Package & Upgrade Logic APIs

## 🎯 Objective
Build NestJS subscription module (`subscription.module.ts`, `subscription.service.ts`) managing advertisement package tiers (*SILVER, BRONZE, GOLD, DIAMOND*) and prorated package upgrades.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Subscription Endpoints**:
  - `GET /subscriptions/:publicationId` (Fetch publication's current active plan status).
  - `POST /subscriptions/:id/upgrade` (Upgrade plan: computes prorated price difference without fresh re-purchase).
- [ ] **Server-Driven Ad Injection Rules**: Return Redis-cached ad popup caps, banner frequencies, and video pre-roll rules based on publication tier.
