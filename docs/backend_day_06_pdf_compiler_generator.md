# Node.js / NestJS Backend — Day 06: Question & Test Paper PDF Compiler Engine

## 🎯 Objective
Build a NestJS PDF Compilation Engine (`pdf-kit` / `puppeteer`) that dynamically generates custom Question Papers and Model Test Sheets with publication watermark headers and solution schemes.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Question Bank Prisma Schema**: `Question` table (subjectId, chapterName, difficulty, questionText, marks, options, answerScheme).
- [ ] **Compiler Service (`paper-compiler.service.ts`)**:
  - Selects questions randomly based on chapter selection & total marks budget.
  - Renders branded PDF with Publication Logo, Header Watermark, Exam Instructions, and Answer Key tab.
- [ ] **Endpoints**:
  - `POST /generators/question-paper` (Generate Question Paper PDF).
  - `POST /generators/test-paper` (Generate Model Test Paper + Solution Scheme PDF).
