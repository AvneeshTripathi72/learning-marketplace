# Node.js / NestJS Backend — Day 04: Educational Taxonomy & eBook APIs

## 🎯 Objective
Build educational taxonomy NestJS controllers (`Series`, `Class`, `Subject`) and eBook PDF resource distribution endpoints.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Taxonomy Endpoints**:
  - `GET /series?publicationId=...` (List series under specific publication).
  - `GET /classes?seriesId=...` (List classes under series).
  - `GET /subjects?classId=...` (List subjects under class).
- [ ] **eBook Management Endpoints**:
  - `GET /ebooks?subjectId=...` (Fetch eBooks list for subject).
  - `POST /ebooks` (Admin endpoint: upload eBook PDF file & cover image).
  - `PATCH /ebooks/:id/activate` | `PATCH /ebooks/:id/deactivate`.
