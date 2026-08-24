# Day 11: Out-of-Publication Access Restriction Screen

## 🎯 Day Objective
Implement `RestrictedContentScreen` displayed when a publication user attempts to access resources outside their licensed publication, featuring an interactive inquiry call launcher.

---

## 📋 Task Checklist & Deliverables

- [ ] **RestrictedContentScreen UI**: Render lock icon, message *"Not Available in this Publication"*, and explanation subtext.
- [ ] **Inquiry Phone Launcher**: Fetch `publication.inquiryNumber` from `currentPublicationProvider` and trigger device phone dialer (`url_launcher tel:`).
- [ ] **Route Interceptor Hook**: Auto-redirect unauthorized cross-publication navigation to `/restricted`.

---

## 🔍 Verification Criteria
- Attempting to open content belonging to another publication redirects instantly to `/restricted`.
- Tapping the inquiry button opens phone dialer with pre-filled number.
