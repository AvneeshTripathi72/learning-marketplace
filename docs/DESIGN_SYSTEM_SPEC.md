# Class 10 eBook App — Design System Specification

---

## 🎨 Fonts (Google Fonts)

| Usage Area | Font Family | Allowed Weights |
| :--- | :--- | :--- |
| **Body / Reading Text** | `Literata` | `400` (Regular), `500` (Medium) |
| **Headings / Chapters** | `Lexend` | `600` (SemiBold), `700` (Bold) |
| **UI / Buttons / Navigation** | `Inter` | `400` (Regular), `500` (Medium) |

*Note: All fonts must be bundled offline in assets/fonts/ to prevent internet dependency during offline reading.*

---

## 📏 Typography Scale & Metrics

- **H1 (Chapter Title)**: `Lexend 700`, Size: `24sp`
- **H2 (Section Title)**: `Lexend 600`, Size: `20sp`
- **Body (Reading Text)**: `Literata 400`, Base Size: `16-18sp` *(User adjustable from `14sp` to `22sp`)*
- **Caption / Metadata**: `Inter 400`, Size: `12sp`
- **Button Text**: `Inter 500`, Size: `14sp`
- **Line Height**: `1.5x - 1.6x` for body text
- **Reading Area Line Width**: Max `60 - 75 characters` per line (Optimized for eye strain reduction)

---

## 🌙 Dark Theme Palette

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

---

## ☀️ Light Theme Palette

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

## ⚙️ Implementation Guidelines (`theme.dart`)

1. **Dual Color Schemes**: Build explicit `lightColorScheme` and `darkColorScheme` supporting System Default mode + Manual User Switch.
2. **Corner Radii Tokens**:
   - Cards & Containers: `12px`
   - Buttons: `8px`
   - Bottom Sheets & Dialog Modals: `20px`
3. **Elevation Rules**:
   - Light Mode: Use soft drop shadows (`2-4dp` elevation).
   - Dark Mode: Avoid harsh drop shadows. Utilize surface color elevation layering (`#121212` base $\rightarrow$ `#1E1E1E` surface $\rightarrow$ `#2A2A2A` elevated).
4. **Eye Comfort Reading Mode**: Never use pure black (`#000000`) or harsh stark white (`#FFFFFF`) on reading screens. Always utilize `#121212` off-black and `#E8E8E8` / `#F5F5F7` soft tones.
