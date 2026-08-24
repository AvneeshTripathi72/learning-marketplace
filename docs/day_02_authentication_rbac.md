# Day 02: Authentication & Multi-Tenant Logo Routing

## 🎯 Day Objective
Implement user login, token storage, role-based user state, and dynamic header branding (Publication Logo vs. Default Platform Logo).

---

## 📋 Task Checklist & Deliverables

- [ ] **UserModel**: Define `UserModel` schema with `UserRole` enum (`publication`, `public`, `admin`).
- [ ] **AuthProvider**: Build `AuthNotifier` state provider with secure token persistence (`flutter_secure_storage`).
- [ ] **Login Screen UI**: Responsive login form with email/password and OAuth placeholders.
- [ ] **Dynamic Logo Switcher**:
  - Publication Login $\rightarrow$ Render Publication Logo (`publication.logoUrl`).
  - Public Login $\rightarrow$ Render Default App Logo (`app_logo.png`).
- [ ] **GoRouter Guards**: Enforce authentication checks on `/pub/*` routes.

---

## 🔍 Verification Criteria
- Logging in as `publication` user sets role state and shows custom publication logo.
- Logging in as `public` user displays default platform logo.
