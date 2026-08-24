# Day 19: Direct Creator UPI / QR Code Donation Engine

## 🎯 Day Objective
Build the zero-commission Direct Creator Donation screen featuring creator profile photos, UPI IDs, QR code rendering, and mobile UPI payment intent launchers.

---

## 📋 Task Checklist & Deliverables

- [ ] **Donation Screen UI**: Display `DonationModel` details (Creator photo, Channel Name, UPI ID, QR Code).
- [ ] **Dynamic QR Code Renderer**: Render QR code image for UPI scanning.
- [ ] **Mobile UPI Intent Launcher**: Launch UPI apps (`upi://pay?pa=...&pn=...`) via `url_launcher`.
- [ ] **Legal Disclaimer Notice**: Render explicit disclaimer informing users that donations are direct peer-to-peer transfers.

---

## 🔍 Verification Criteria
- Tapping "Donate via UPI" opens GPay / PhonePe / Paytm intent launcher on physical device.
