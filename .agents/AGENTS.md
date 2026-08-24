# Project Rules

- Do not perform any work or modifications in the Ebook section unless explicitly instructed by the user.

---

# DESIGN SYSTEM SPECIFICATION (MANDATORY)

## Fonts (Google Fonts)
- **Body / Reading Text**: `Literata` — Weights `400`, `500`
- **Headings / Chapters**: `Lexend` — Weights `600`, `700`
- **UI / Buttons / Navigation**: `Inter` — Weights `400`, `500`
- **Font Sourcing**: Bundle font files offline locally (`google_fonts` offline asset bundling or asset assets/fonts/). Do not rely on runtime internet fetching.

## Typography Scale & Metrics
- **H1 (Chapter Title)**: Lexend 700, `24sp`
- **H2 (Section Title)**: Lexend 600, `20sp`
- **Body (Reading Text)**: Literata 400, `16-18sp` (User adjustable range: `14sp - 22sp`)
- **Caption / Metadata**: Inter 400, `12sp`
- **Button Text**: Inter 500, `14sp`
- **Line Height**: `1.5x - 1.6x` for body text
- **Reading Area Max Width**: `60-75 characters` per line (Eye comfort layout constraint)

## Dark Theme Color Palette
- `background`: `#121212`
- `surface`: `#1E1E1E`
- `elevatedSurface`: `#2A2A2A`
- `textPrimary`: `#E8E8E8`
- `textSecondary`: `#A0A0A0`
- `accentPrimary`: `#7C9CFF`
- `accentAlt`: `#FFB84C`
- `divider`: `#333333`
- `error`: `#FF6B6B`
- `success`: `#4CD964`

## Light Theme Color Palette
- `background`: `#FFFFFF`
- `surface`: `#F5F5F7`
- `elevatedSurface`: `#FFFFFF` (Use soft shadows, elevation `2-4dp`)
- `textPrimary`: `#1A1A1A`
- `textSecondary`: `#6B6B6B`
- `accentPrimary`: `#4A6CF7`
- `accentAlt`: `#F5A623`
- `divider`: `#E0E0E0`
- `error`: `#E5484D`
- `success`: `#2FB344`

## UI Implementation Rules
- **Theme Modes**: Implement both `lightColorScheme` and `darkColorScheme` in `theme.dart`. Support system default + manual toggle.
- **Corner Radius**:
  - Cards / Containers: `12px`
  - Buttons: `8px`
  - Bottom Sheets / Dialogs: `20px`
- **Elevation Strategy**: Use subtle soft shadows in Light mode (`2-4dp`). Avoid drop shadows in Dark mode (use surface color layering instead: `#121212` $\rightarrow$ `#1E1E1E` $\rightarrow$ `#2A2A2A`).
- **Eye Comfort Rule**: No pure black (`#000000`) or harsh pure white (`#FFFFFF`) on reading screens. Respect off-black (`#121212`) and off-white (`#E8E8E8`/`#F5F5F7`) values.
