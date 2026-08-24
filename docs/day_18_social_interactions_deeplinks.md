# Day 18: Social Interactions & App Deep Links

## 🎯 Day Objective
Implement social interaction features (Like, Share, Save, Subscribe) and platform-aware playback redirection (YouTube, Instagram, Facebook).

---

## 📋 Task Checklist & Deliverables

- [ ] **Interaction APIs**: Hook up Like button, Save to bookmarks, Share link, and Channel Subscribe APIs.
- [ ] **Platform Playback Resolver**: Build `VideoService.resolvePlaybackUri()`.
  - **YouTube**: In-app embedded player.
  - **Instagram / Facebook**: Detect native app installation via `url_launcher`; launch native app deep-link if present, fallback to internal WebView login.

---

## 🔍 Verification Criteria
- Instagram and Facebook video links launch native app if installed, or open in-app WebView without crashing.
