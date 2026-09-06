<div align="center">
  <h1>📚 Publication, Education & Video Content Platform</h1>
  <p><i>A premium E-Book and Video Learning Marketplace</i></p>

  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img alt="Node.js" src="https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white" />
  <img alt="PostgreSQL" src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img alt="Prisma" src="https://img.shields.io/badge/Prisma-3982CE?style=for-the-badge&logo=Prisma&logoColor=white" />
  <img alt="Supabase" src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
</div>

<br />

Welcome to the **Publication, Education & Video Content Platform** repository. This platform empowers creators, educators, and publishers to distribute multi-tenant e-books, educational magazines, question papers, and video content directly to end-users with seamless monetization and administration.

---

## ✨ Features

- **Premium UX/UI**: Bespoke design system utilizing `Lexend`, `Literata`, and `Inter` fonts, animated KPIs, custom dark/light modes, and strict eye comfort guidelines.
- **Dynamic Content Discovery**: High-performance debounced search bars, taxonomy filtering (Board, Class, Subject), and intuitive empty states.
- **Direct Media Uploads**: Built-in support for uploading MP4 video chunks and PDF files directly to Supabase storage buckets with live progress visualization.
- **Robust Role-Based Access Control**: Route guarding with `go_router` for Admin vs. Public views, including publisher-specific hubs.
- **Admin Dashboard**: Visual analytics leveraging `fl_chart` for revenue tracking and KPI monitoring.

---

## 📄 Core Project Documentation

1. 📖 **[Master Project Requirements Document (PRD)](./PROJECT_REQUIREMENTS.md)**
   - Complete system overview, multi-tenant publication taxonomy, public hub moderation pipeline, dynamic advertisement engine, direct creator donation model, and administrative capabilities.

2. 🏗️ **[Android App & Technical Evaluation Plan](./TECHNICAL_EVALUATION_AND_PLAN.md)**
   - Tech stack comparison (Flutter selected for app, Node.js + Express + Prisma + PostgreSQL for backend), risk mitigations, folder skeletons (`lib/` & `backend/`), data models, and service layer specifications.

3. 🎨 **[Design System Specification](./docs/DESIGN_SYSTEM_SPEC.md)**
   - Fonts, typography scale, Light & Dark mode color hex palettes, elevation guidelines, and eye comfort reading rules.

4. 📅 **[30-Day Master Execution Plan](./docs/DAY_BY_DAY_PLAN.md)**
   - Dedicated `docs/` folder containing the 10-Day Node.js Backend Plan and the 20-Day App Plan.

---

## 🛠️ Node.js Backend Architecture & Plan (10 Days)

| Day | Focus Area | Plan Document |
| :---: | :--- | :--- |
| **01** | Server Architecture & PostgreSQL Setup | [backend_day_01_server_db_setup.md](./docs/backend_day_01_server_db_setup.md) |
| **02** | Authentication & RBAC Middleware | [backend_day_02_auth_rbac_jwt.md](./docs/backend_day_02_auth_rbac_jwt.md) |
| **03** | Publication Registry APIs | [backend_day_03_publication_registry_api.md](./docs/backend_day_03_publication_registry_api.md) |
| **04** | Educational Taxonomy & eBook APIs | [backend_day_04_ebook_taxonomy_api.md](./docs/backend_day_04_ebook_taxonomy_api.md) |
| **05** | Publication YouTube Streams API | [backend_day_05_youtube_mapping_api.md](./docs/backend_day_05_youtube_mapping_api.md) |
| **06** | Question & Test Paper PDF Compiler | [backend_day_06_pdf_compiler_generator.md](./docs/backend_day_06_pdf_compiler_generator.md) |
| **07** | Public Hub Moderation Queue APIs | [backend_day_07_moderation_queue_api.md](./docs/backend_day_07_moderation_queue_api.md) |
| **08** | Ad Subscription Package Engine | [backend_day_08_ad_subscription_engine.md](./docs/backend_day_08_ad_subscription_engine.md) |
| **09** | Razorpay Webhook & Double Verification API | [backend_day_09_razorpay_double_verification.md](./docs/backend_day_09_razorpay_double_verification.md) |
| **10** | Reports Engine, Donations & Docker Deploy | [backend_day_10_reports_donations_deployment.md](./docs/backend_day_10_reports_donations_deployment.md) |

---

## 🔒 Workspace Rules & Guidelines

- Refer to **[.agents/AGENTS.md](./.agents/AGENTS.md)** for mandatory project constraints and design system specifications.
