# 30-Day Master Execution Plan & Daily Trackers

This directory contains individual daily execution documents for the **Publication, Education & Video Content Platform**, divided into **Part 1: Node.js Backend APIs (10 Days)** and **Part 2: Flutter Android App (20 Days)**.

---

## 📌 Part 1: Node.js Backend REST APIs & Database (Days B01 – B10)

| Day File | Title & Focus Area | Target Output | Status |
| :--- | :--- | :--- | :---: |
| **[Backend Day 01](file:///e:/Freelance/Ebook/docs/backend_day_01_server_db_setup.md)** | Server Architecture & PostgreSQL Setup | Node.js init, Prisma ORM, DB Push | ⏳ Next Up |
| **[Backend Day 02](file:///e:/Freelance/Ebook/docs/backend_day_02_auth_rbac_jwt.md)** | Authentication & RBAC Middleware | JWT Tokens, bcrypt, role access guards | ⏳ Scheduled |
| **[Backend Day 03](file:///e:/Freelance/Ebook/docs/backend_day_03_publication_registry_api.md)** | Publication Registry & Management APIs | Publication CRUD, logo presigned upload URLs | ⏳ Scheduled |
| **[Backend Day 04](file:///e:/Freelance/Ebook/docs/backend_day_04_ebook_taxonomy_api.md)** | Educational Taxonomy & eBook APIs | `Series -> Class -> Subject -> eBook PDF` | ⏳ Scheduled |
| **[Backend Day 05](file:///e:/Freelance/Ebook/docs/backend_day_05_youtube_mapping_api.md)** | Publication YouTube Streams API | YouTube metadata oEmbed fetch & mapping | ⏳ Scheduled |
| **[Backend Day 06](file:///e:/Freelance/Ebook/docs/backend_day_06_pdf_compiler_generator.md)** | Question & Test Paper PDF Compiler | Dynamic question selection, PDF generator engine | ⏳ Scheduled |
| **[Backend Day 07](file:///e:/Freelance/Ebook/docs/backend_day_07_moderation_queue_api.md)** | Public Video Hub Moderation APIs | Submission API, Admin Moderation queue | ⏳ Scheduled |
| **[Backend Day 08](file:///e:/Freelance/Ebook/docs/backend_day_08_ad_subscription_engine.md)** | Ad Package Subscriptions & Rule Engine | Tier packages (*Silver/Bronze/Gold/Diamond*), Redis rules | ⏳ Scheduled |
| **[Backend Day 09](file:///e:/Freelance/Ebook/docs/backend_day_09_razorpay_double_verification.md)** | Razorpay Webhook & Double Verification API | Webhook HMAC check, double verification endpoint | ⏳ Scheduled |
| **[Backend Day 10](file:///e:/Freelance/Ebook/docs/backend_day_10_reports_donations_deployment.md)** | Reports Engine, Donations & Docker Deploy | Leaderboard reports, UPI log API, Dockerize | ⏳ Scheduled |

---

## 📌 Part 2: Flutter Android App Execution (Days 01 – 20)

### Phase 1: Publication Core Module (Days 1 – 13)

| Day File | Title & Focus Area | Target Output | Status |
| :--- | :--- | :--- | :---: |
| **[App Day 01](file:///e:/Freelance/Ebook/docs/day_01_setup_and_architecture.md)** | Project Setup & Architecture Skeleton | Repo init, Flutter tree, Riverpod + GoRouter setup | ✅ **COMPLETED** |
| **[App Day 02](file:///e:/Freelance/Ebook/docs/day_02_authentication_rbac.md)** | Auth & Multi-Tenant Logo Routing | Login UI, `AuthProvider`, Dynamic Logo switching | ✅ **COMPLETED** |
| **[App Day 03](file:///e:/Freelance/Ebook/docs/day_03_publication_dashboard.md)** | Publication Dashboard | Liked/Subscribed/Shared/Recommended carousels | ✅ **COMPLETED** |
| **[App Day 04](file:///e:/Freelance/Ebook/docs/day_04_ebook_and_pdf_viewer.md)** | eBook Reader & PDF Offline Downloader | Hierarchy picker, PDF Canvas, background download | ✅ **COMPLETED** |
| **[App Day 05](file:///e:/Freelance/Ebook/docs/day_05_publication_youtube.md)** | Publication YouTube Streams | Mapped video feed, responsive YouTube player | ✅ **COMPLETED** |
| **[App Day 06](file:///e:/Freelance/Ebook/docs/day_06_question_paper_generator.md)** | Question Paper Generator | Parameter filters, question paper PDF export | ✅ **COMPLETED** |
| **[App Day 07](file:///e:/Freelance/Ebook/docs/day_07_test_paper_generator.md)** | Model test sheet generator, answer key layout | ✅ **COMPLETED** |
| **[App Day 08](file:///e:/Freelance/Ebook/docs/day_08_public_hub_video_upload.md)** | Video Submission Hub (Pub Side) | URL submission form, Active/Inactive tracking | ✅ **COMPLETED** |
| **[App Day 09](file:///e:/Freelance/Ebook/docs/day_09_ad_subscription_packages.md)** | Ad Subscription Packages & Razorpay | Packages (Silver/Bronze/Gold/Diamond), upgrade flow | ✅ **COMPLETED** |
| **[App Day 10](file:///e:/Freelance/Ebook/docs/day_10_double_verification_payment.md)** | Double Verification Payment Logic | Server check (`Active Status` + `Valid Payment ID`) | ✅ **COMPLETED** |
| **[App Day 11](file:///e:/Freelance/Ebook/docs/day_11_restricted_content_screen.md)** | Out-of-Publication Access Restriction | `RestrictedContentScreen` + Phone Dialer launcher | ✅ **COMPLETED** |
| **[App Day 12](file:///e:/Freelance/Ebook/docs/day_12_publication_qa_polish.md)** | Publication Module Integration QA | Offline download stress test, integration fixes | ✅ **COMPLETED** |
| **[App Day 13](file:///e:/Freelance/Ebook/docs/day_13_client_demo_day.md)** | **CLIENT DEMO DAY 🎯** | Presentation & feedback collection for Phase 1 | ✅ **COMPLETED (Phase 1 Lock)** |

### Phase 2: Public Module & Final Delivery (Days 14 – 20)

| Day File | Title & Focus Area | Target Output | Status |
| :--- | :--- | :--- | :---: |
| **[App Day 14](file:///e:/Freelance/Ebook/docs/day_14_public_dashboard.md)** | Public User Dashboard | Generic branding dashboard, public feed | ✅ **COMPLETED** |
| **[App Day 15](file:///e:/Freelance/Ebook/docs/day_15_public_ebooks_and_youtube.md)** | Public eBooks & YouTube Feeds | All-Series public content pickers | ✅ **COMPLETED** |
| **[App Day 16](file:///e:/Freelance/Ebook/docs/day_16_public_paper_generators.md)** | Public Question & Test Generators | Public model test & question paper tools | ✅ **COMPLETED** |
| **[App Day 17](file:///e:/Freelance/Ebook/docs/day_17_public_category_hub.md)** | Server-Driven Public Category Hub | Category chips, admin parental toggle support | ✅ **COMPLETED** |
| **[App Day 18](file:///e:/Freelance/Ebook/docs/day_18_social_interactions_deeplinks.md)** | Social Interactions & App Deep Links | Like/Share/Save APIs, FB/Insta native launcher | ✅ **COMPLETED** |
| **[App Day 19](file:///e:/Freelance/Ebook/docs/day_19_creator_donation_engine.md)** | Direct Creator UPI / QR Donation | Creator photo, UPI ID, QR Code & intent dialer | ✅ **COMPLETED** |
| **[App Day 20](file:///e:/Freelance/Ebook/docs/day_20_notifications_final_release.md)** | Notifications & Production Build | FCM setup, full regression pass, Release APK/AAB | ✅ **COMPLETED (App Fully Done)** |
