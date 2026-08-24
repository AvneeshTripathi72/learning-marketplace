# Node.js / NestJS Backend — Day 10: Creator Donations, Admin Reports & Docker Deployment

## 🎯 Objective
Build direct creator donation endpoints (`Donation` with `creatorPhotoUrl`), administrative analytics report controllers (`reports.controller.ts`), and Docker containerization.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Donation Endpoints**: `GET /donations/:channelId` (Returns UPI ID, QR Code URL, Channel Name, and Creator Photo URL).
- [ ] **Admin Reports Endpoints**:
  - `GET /reports/channels` (Subscriber growth, view counts, likes leaderboard).
  - `GET /reports/publications` (Financial subscription revenue reports).
- [ ] **Deployment & Integration QA**: Dockerize app (`Dockerfile` + `docker-compose.yml` for Node.js + PostgreSQL + Redis), setup CORS, run integration suite.
