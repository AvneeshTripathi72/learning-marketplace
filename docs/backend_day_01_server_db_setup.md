# Node.js / NestJS Backend — Day 01: NestJS Architecture & Prisma PostgreSQL Setup

## 🎯 Objective
Initialize the NestJS + TypeScript backend REST API server, setup environment configuration, and configure Prisma ORM with the complete PostgreSQL database schema matching client brief specifications.

---

## 📋 Technical Deliverables & Tasks

- [x] **NestJS Server Init**: Initialize `backend/` directory with NestJS CLI (`nest new backend`), TypeScript, and modular architecture.
- [x] **Prisma ORM Setup**: Install `@prisma/client` and `prisma`. Initialize PostgreSQL provider (`npx prisma init`).
- [x] **Prisma Database Schema**: Define full database models in `prisma/schema.prisma`:
  - `Publication` (`id`, `name`, `email`, `mobile`, `address`, `logoUrl`, `inquiryNumber`, `isActive`, `createdAt`)
  - `Series`, `Class`, `Subject` (Educational Hierarchy)
  - `EBook` (`id`, `subjectId`, `coverUrl`, `fileUrl`, `isActive`)
  - `Video` (`id`, `url`, `platform`, `channelName`, `categoryId`, `status`, `submittedById`, `submittedAt`)
  - `Category` (`id`, `name`, `isEnabled` - admin parental control toggle)
  - `Subscription` (`id`, `publicationId`, `package`, `startDate`, `endDate`, `status`, `paymentId`)
  - `Payment` (`id`, `transactionId`, `amount`, `status`, `gatewayRef`)
  - `Donation` (`id`, `channelName`, `upiId`, `qrCodeUrl`, `creatorPhotoUrl`)
  - `User` (`id`, `name`, `email`, `role`, `publicationId`)
- [x] **Database Migration & Validation**: Verify schema sync with PostgreSQL (`npx prisma db push`).

---

## 🏗️ NestJS Modular Directory Structure (`backend/src/`)

```
src/
├── main.ts
├── app.module.ts
├── prisma/
│   ├── prisma.module.ts
│   └── prisma.service.ts
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── guards/roles.guard.ts
│   └── strategies/jwt.strategy.ts
├── publication/
│   ├── publication.module.ts
│   ├── publication.controller.ts
│   └── publication.service.ts
├── content-hierarchy/
│   ├── series/
│   ├── class/
│   └── subject/
├── ebook/
├── video/
│   ├── video.module.ts
│   ├── video.controller.ts
│   ├── video.service.ts
│   └── video-moderation.service.ts
├── question-paper/
├── test-paper/
├── category/
├── subscription/
│   ├── subscription.module.ts
│   ├── subscription.controller.ts
│   └── subscription.service.ts
├── payment/
│   ├── payment.module.ts
│   ├── payment.controller.ts
│   └── payment.service.ts
├── donation/
├── reports/
└── notifications/
```

---

## 📜 Full Prisma Schema Definition (`prisma/schema.prisma`)

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

enum UserRole {
  PUBLICATION
  PUBLIC
  ADMIN
}

model User {
  id            String       @id @default(uuid())
  name          String
  email         String       @unique
  password      String
  role          UserRole
  publicationId String?
  publication   Publication? @relation(fields: [publicationId], references: [id])
  videos        Video[]
  createdAt     DateTime     @default(now())
  updatedAt     DateTime     @updatedAt
}

model Publication {
  id            String         @id @default(uuid())
  name          String
  email         String         @unique
  mobile        String
  address       String
  logoUrl       String
  inquiryNumber String
  isActive      Boolean        @default(true)
  series        Series[]
  users         User[]
  subscriptions Subscription[]
  createdAt     DateTime       @default(now())
}

model Series {
  id            String      @id @default(uuid())
  name          String
  publicationId String
  publication   Publication @relation(fields: [publicationId], references: [id])
  classes       Class[]
}

model Class {
  id       String    @id @default(uuid())
  name     String
  seriesId String
  series   Series    @relation(fields: [seriesId], references: [id])
  subjects Subject[]
}

model Subject {
  id      String  @id @default(uuid())
  name    String
  classId String
  class   Class   @relation(fields: [classId], references: [id])
  ebooks  EBook[]
  videos  Video[]
}

model EBook {
  id        String  @id @default(uuid())
  title     String
  subjectId String
  subject   Subject @relation(fields: [subjectId], references: [id])
  coverUrl  String
  fileUrl   String
  isActive  Boolean @default(true)
}

enum VideoPlatform {
  YOUTUBE
  INSTAGRAM
  FACEBOOK
}

enum VideoStatus {
  PENDING
  APPROVED
  REJECTED
  INACTIVE
  DELETED
}

model Video {
  id            String        @id @default(uuid())
  url           String
  platform      VideoPlatform
  channelName   String
  categoryId    String
  category      Category      @relation(fields: [categoryId], references: [id])
  status        VideoStatus   @default(PENDING)
  submittedById String
  submittedBy   User          @relation(fields: [submittedById], references: [id])
  subjectId     String?
  subject       Subject?      @relation(fields: [subjectId], references: [id])
  submittedAt   DateTime      @default(now())
}

model Category {
  id        String  @id @default(uuid())
  name      String
  isEnabled Boolean @default(true)
  videos    Video[]
}

enum PackageTier {
  SILVER
  BRONZE
  GOLD
  DIAMOND
}

enum SubscriptionStatus {
  ACTIVE
  INACTIVE
  EXPIRED
  PENDING_UPGRADE
}

model Subscription {
  id            String             @id @default(uuid())
  publicationId String
  publication   Publication        @relation(fields: [publicationId], references: [id])
  package       PackageTier
  startDate     DateTime
  endDate       DateTime
  status        SubscriptionStatus
  paymentId     String
  payment       Payment            @relation(fields: [paymentId], references: [id])
}

enum PaymentStatus {
  PENDING
  SUCCESSFUL
  FAILED
  REFUNDED
  CANCELLED
}

model Payment {
  id            String         @id @default(uuid())
  transactionId String         @unique
  amount        Decimal
  status        PaymentStatus
  gatewayRef    String
  subscriptions Subscription[]
  createdAt     DateTime       @default(now())
}

model Donation {
  id              String   @id @default(uuid())
  channelName     String
  upiId           String
  qrCodeUrl       String
  creatorPhotoUrl String
  createdAt       DateTime @default(now())
}
```
