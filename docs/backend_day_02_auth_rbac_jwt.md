# Node.js / NestJS Backend — Day 02: Authentication & Multi-Tenant Role Guards

## 🎯 Objective
Implement NestJS Authentication Module (`auth.module.ts`), Passport JWT strategy (`jwt.strategy.ts`), bcrypt password hashing, and role-based access control (`@Roles()` decorator & `roles.guard.ts`) for `PUBLICATION`, `PUBLIC`, and `ADMIN` user types.

---

## 📋 Technical Deliverables & Endpoints

- [ ] **Auth DTOs**: Create `LoginDto`, `RegisterDto`, and `AuthResponseDto`.
- [ ] **Passport JWT Strategy (`jwt.strategy.ts`)**: Extract Bearer token from header, validate payload (`sub`, `email`, `role`, `publicationId`), and attach to request `user`.
- [ ] **RBAC Guard (`roles.guard.ts`)**: Reflect metadata roles (`PUBLICATION`, `PUBLIC`, `ADMIN`) and intercept unauthorized route calls.
- [ ] **REST Endpoints**:
  - `POST /auth/login` (Returns JWT access token + user details).
  - `POST /auth/register` (Public & Publication user signup).
  - `GET /auth/me` (Returns authenticated user profile).

---

## 💻 NestJS Roles Guard Pattern (`roles.guard.ts`)

```typescript
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole } from '@prisma/client';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>('roles', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user?.role === role);
  }
}
```
