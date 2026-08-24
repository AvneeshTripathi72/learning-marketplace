# Day 09: Ad Subscription Packages & Razorpay

## 🎯 Day Objective
Implement Advertisement Subscription Package selection screens (*Silver, Bronze, Gold, Diamond*), Razorpay SDK payment integration, and package upgrade requests.

---

## 📋 Task Checklist & Deliverables

- [ ] **Package Selection UI**: Display tier cards (*Silver, Bronze, Gold, Diamond*) showing price, ad impression limits, display priority, and video allocations.
- [ ] **Razorpay Checkout SDK**: Integrate Razorpay payment modal with callback listeners.
- [ ] **Upgrade Request Service**: Build `SubscriptionService.requestUpgrade()` to calculate prorated upgrades.
- [ ] **Subscription Status Screen**: Display active package details, start/end dates, remaining limits, and upgrade CTA.

---

## 🔍 Verification Criteria
- Selecting a package launches the payment checkout overlay cleanly.
- Successful payment triggers backend verification payload.
