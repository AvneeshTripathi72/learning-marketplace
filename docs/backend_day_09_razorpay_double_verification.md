# Node.js / NestJS Backend — Day 09: Razorpay Webhook & Double Verification API

## 🎯 Objective
Implement Razorpay payment module (`payment.module.ts`, `payment.controller.ts`), HMAC SHA256 webhook signature validation, and server-side Double Verification endpoint.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Razorpay Order Endpoint**: `POST /payments/initiate` (Generates Razorpay order ID).
- [ ] **Razorpay Webhook Handler**: `POST /payments/webhook` (Verifies signature, records `PaymentStatus = SUCCESSFUL` in PostgreSQL).
- [ ] **Double Verification Endpoint (`/subscriptions/:id/verify`)**:
  - Validates `Subscription.status == ACTIVE` AND `Payment.status == SUCCESSFUL` before unlocking premium features.
