# 📚 Publication & Education Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.22.0-02569B?logo=flutter)](https://flutter.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.5-00599C)](https://riverpod.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase_DB-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A cross-platform digital educational ecosystem built with Flutter, Riverpod, and Supabase. The platform provides a rich environment for educational publishers, teachers, and students to read digital eBooks, stream educational lectures, and manage study content with live database synchronization.

---

## ✨ Key Features

- 📖 **Interactive eBook Library**: Digital textbook reading with built-in PDF viewer, hierarchy filters (Series, Class, Subject), zoom controls, and external reader support.
- 🎥 **Public Video Hub**: Streaming educational video lectures with category filters, YouTube ID regex parsing, in-app video player, and browser fallback.
- ⚡ **Live Real-Time Database Sync**: Live Supabase PostgreSQL integration across `Video`, `EBook`, `Category`, and `User` tables.
- 🛡️ **Role-Based Access Control (RBAC)**: Support for Student/Public users, Publication Vendors, and Platform Administrators.
- 🎨 **Premium Eye-Comfort Design System**: Curated dark and light themes using Google Fonts (`Literata`, `Lexend`, `Inter`) without stark blacks or whites.

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: Flutter (Dart SDK `>=3.2.0 <4.0.0`)
- **State Management**: `flutter_riverpod`
- **Navigation**: `go_router`
- **Database & Auth**: `supabase_flutter` & `flutter_secure_storage`
- **Media & Viewing**: `syncfusion_flutter_pdfviewer`, `youtube_player_flutter`, `cached_network_image`
- **Styling**: `google_fonts` (Literata, Lexend, Inter)

---

## 🚀 Getting Started

### 1. Clone Repository
```bash
git clone https://github.com/AvneeshTripathi72/learning-marketplace.git
cd learning-marketplace
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Supabase Environment
Create a `.env` file in the root directory with your Supabase credentials:
```env
SUPABASE_URL=https://your-supabase-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

### 4. Run Application
```bash
flutter run
```

---

## 📖 Documentation

- [Project Design & Specification](docs/PROJECT_DESIGN_AND_SPECIFICATION.md): Typography, color palettes, layout metrics, and architecture.
- [Google Play Store Deployment Guide](docs/PLAY_STORE_DEPLOYMENT.md): Step-by-step app bundle build and Play Console release instructions.

---

## 📄 License

This project is licensed under the MIT License.
