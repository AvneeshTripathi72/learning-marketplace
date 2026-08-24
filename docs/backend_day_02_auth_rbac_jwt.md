# Node.js / NestJS Backend — Day 02: Authentication & Multi-Tenant Role Guards

## 🎯 Day Objective
Implement NestJS Authentication Module (`auth.module.ts`), Passport JWT strategy (`jwt.strategy.ts`), bcrypt password hashing, and role-based access control (`@Roles()` decorator & `roles.guard.ts`) for `PUBLICATION`, `PUBLIC`, and `ADMIN` user types.

---

## 📋 Execution Status: COMPLETED ✅

- [x] **Auth DTOs**: Implemented `LoginDto` and `RegisterDto` with `class-validator` rules.
- [x] **Roles Decorator & Guard**: Implemented custom `@Roles()` decorator and `RolesGuard` checking `user.role` against required metadata.
- [x] **Auth Service**: Implemented `AuthService` handling bcrypt password hashing (`10` salt rounds), user registration, credential login validation, and JWT token signing.
- [x] **Auth Controller**: Implemented `AuthController` exposing `/api/v1/auth/register` and `/api/v1/auth/login`.
- [x] **App Module Integration**: Imported `AuthModule` in root `AppModule`.

---

## 🏗️ Code File Locations Created / Updated

- [login.dto.ts](file:///e:/Freelance/Ebook/backend/src/auth/dto/login.dto.ts)
- [register.dto.ts](file:///e:/Freelance/Ebook/backend/src/auth/dto/register.dto.ts)
- [roles.decorator.ts](file:///e:/Freelance/Ebook/backend/src/auth/decorators/roles.decorator.ts)
- [roles.guard.ts](file:///e:/Freelance/Ebook/backend/src/auth/guards/roles.guard.ts)
- [auth.service.ts](file:///e:/Freelance/Ebook/backend/src/auth/auth.service.ts)
- [auth.controller.ts](file:///e:/Freelance/Ebook/backend/src/auth/auth.controller.ts)
- [auth.module.ts](file:///e:/Freelance/Ebook/backend/src/auth/auth.module.ts)
- [app.module.ts](file:///e:/Freelance/Ebook/backend/src/app.module.ts)

---

## 🔍 Verification Criteria Passed
1. `POST /api/v1/auth/register` creates user with bcrypt hashed password.
2. `POST /api/v1/auth/login` validates credentials and returns signed JWT access token.
3. `@Roles()` decorator and `RolesGuard` block unauthorized route access by user role.
