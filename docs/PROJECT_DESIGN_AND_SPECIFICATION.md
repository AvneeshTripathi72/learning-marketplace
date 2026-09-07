# Publication & Education Platform — Project Design & Specification

---

## 📌 Executive Overview

The **Publication & Education Platform** is a cross-platform Flutter application and backend ecosystem designed for educational publishers, educators, and students. It enables seamless digital publishing, interactive eBook reading, curated educational video streaming, and automated question/test paper generation.

---

## 🎨 Design System Specifications

### 1. Google Fonts Hierarchy

| Usage Area | Font Family | Allowed Weights | Purpose |
| :--- | :--- | :--- | :--- |
| **Body / Reading Text** | `Literata` | `400` (Regular), `500` (Medium) | Long-form eye-comfort reading |
| **Headings / Chapters** | `Lexend` | `600` (SemiBold), `700` (Bold) | Clean, modern structural headings |
| **UI / Buttons / Navigation** | `Inter` | `400` (Regular), `500` (Medium) | Crisp UI labels, buttons, and navigation |

> *Note: Font assets are bundled locally in `assets/fonts/` to ensure offline reading capability.*

---

### 2. Typography Scale & Layout Metrics

- **H1 (Chapter Title)**: `Lexend 700`, `24sp`
- **H2 (Section Title)**: `Lexend 600`, `20sp`
- **Body (Reading Text)**: `Literata 400`, Base `16sp - 18sp` *(User adjustable `14sp` to `22sp`)*
- **Caption / Metadata**: `Inter 400`, `12sp`
- **Button Text**: `Inter 500`, `14sp`
- **Line Height**: `1.5x - 1.6x` for reading comfort
- **Reading Line Width**: `60 - 75 characters` max per line

---

### 3. Dark & Light Theme Color Palettes

#### 🌙 Dark Theme Palette
```json
{
  "background": "#121212",
  "surface": "#1E1E1E",
  "elevatedSurface": "#2A2A2A",
  "textPrimary": "#E8E8E8",
  "textSecondary": "#A0A0A0",
  "accentPrimary": "#7C9CFF",
  "accentAlt": "#FFB84C",
  "divider": "#333333",
  "error": "#FF6B6B",
  "success": "#4CD964"
}
```

#### ☀️ Light Theme Palette
```json
{
  "background": "#FFFFFF",
  "surface": "#F5F5F7",
  "elevatedSurface": "#FFFFFF",
  "textPrimary": "#1A1A1A",
  "textSecondary": "#6B6B6B",
  "accentPrimary": "#4A6CF7",
  "accentAlt": "#F5A623",
  "divider": "#E0E0E0",
  "error": "#E5484D",
  "success": "#2FB344"
}
```

---

### 4. UI Corner Radii & Component Guidelines

- **Cards & Containers**: `12px` border radius
- **Buttons**: `8px` border radius
- **Bottom Sheets & Dialogs**: `20px` border radius
- **Soft Shadows & Layering**: Soft elevation shadows in Light Mode (`2-4dp`), surface color layering in Dark Mode (`#121212` base $\rightarrow$ `#1E1E1E` surface $\rightarrow$ `#2A2A2A` elevated).
- **Eye Comfort Standard**: No pure stark black (`#000000`) or pure harsh white (`#FFFFFF`) on reading screens.

---

## 🏗️ Architecture & Technology Stack

- **Frontend**: Flutter (Dart) with Riverpod State Management & GoRouter Navigation
- **Database & Realtime Sync**: Supabase PostgreSQL (`Video`, `EBook`, `Category`, `User` tables)
- **Media Engine**: Syncfusion PDF Viewer & YouTube Embed/Iframe Player
