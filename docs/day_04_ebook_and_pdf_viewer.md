# Day 04: eBook Reader & PDF Offline Downloader

## 🎯 Day Objective
Implement publication-scoped eBook browsing with the `Series -> Class -> Subject` hierarchy picker, PDF viewer canvas, and background download manager.

---

## 📋 Task Checklist & Deliverables

- [ ] **Hierarchy Picker Widget**: Build reusable `hierarchy_picker.dart` dropdown/tab component (`Series` $\rightarrow$ `Class` $\rightarrow$ `Subject`).
- [ ] **eBook Grid View**: Display `EBookModel` cards filtered by selected publication ID.
- [ ] **PDF Canvas Viewer Screen**: Integrate `syncfusion_flutter_pdfviewer` with page navigation and zoom controls.
- [ ] **Offline Download Service**: Hook up `DownloadManagerService` (`dio` download + Hive local record storage).
- [ ] **Offline Indicator Badge**: Show download status indicator icon on eBook cards.

---

## 🔍 Verification Criteria
- Changing Class/Subject filters updates eBook grid instantly.
- Downloaded PDFs open seamlessly when device offline mode is toggled.
