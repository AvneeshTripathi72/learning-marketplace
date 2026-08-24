# Day 08: Video Submission Hub (Publication Side)

## 🎯 Day Objective
Build the Video Submission Form screen allowing Publication users to submit external video links (YouTube, Instagram, Facebook) with metadata (URL, Channel Name, Category, Tags, Keywords) and track submissions under Active and Inactive/Pending tabs.

---

## 📋 Execution Status: COMPLETED ✅

- [x] **Video Submission Form**: Implemented `UploadVideoScreen` with social media link pattern validation (`YouTube`, `Instagram`, `Facebook`), category selection, tags, and keywords.
- [x] **My Uploads Tracking Screen**: Implemented `MyUploadsScreen` with dual TabBar view (`Active Videos` tab + `Inactive / Pending` tab) displaying moderation status tags.
- [x] **Router Integration**: Registered `/pub/hub/upload` and `/pub/hub/my-uploads` routes in `app_router.dart`.

---

## 🏗️ Code File Locations Created / Updated

- [upload_video_screen.dart](file:///e:/Freelance/Ebook/lib/screens/publication/public_hub/upload_video_screen.dart)
- [my_uploads_screen.dart](file:///e:/Freelance/Ebook/lib/screens/publication/public_hub/my_uploads_screen.dart)
- [app_router.dart](file:///e:/Freelance/Ebook/lib/core/routing/app_router.dart)

---

## 🔍 Verification Criteria Passed
- Submitting invalid non-social URLs triggers validation error feedback.
- Submitting valid YouTube/Instagram link redirects to `MyUploadsScreen` displaying pending status badge.
