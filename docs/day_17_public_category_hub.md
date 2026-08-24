# Day 17: Server-Driven Public Category Hub

## 🎯 Day Objective
Implement the Public Video Hub with server-driven category filtering and admin-controlled parental toggle support.

---

## 📋 Task Checklist & Deliverables

- [ ] **Category Chips Bar**: Build `category_chip_list.dart` rendering server-driven categories (*Educational, Informative, Religious, Entertainment, Technology*).
- [ ] **Admin Toggle Filter**: Wire `enabledCategoriesProvider` to automatically hide disabled categories.
- [ ] **Public Video Submission Form**: Upload URL, Channel Name, and Category selection.

---

## 🔍 Verification Criteria
- Disabling a category via backend config hides the category chip in real-time.
