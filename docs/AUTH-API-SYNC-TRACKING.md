# Auth API Sync Tracking

> Sincronización del cliente Dart `menu_dart_api` con la API backend `menucom-api`
> Fecha: 2026-06-13 — **COMPLETADO**

---

## Resumen de Gaps

| Categoría | Endpoints en API | Cubiertos en cliente | Pendientes |
|-----------|-----------------|---------------------|------------|
| Auth | 8 | 8 | 0 |
| User Roles | 7 | 7 | 0 |
| **Total** | **15** | **15** | **0** |

---

## Fase 1: Modelos Base (Enums y Tipos)

| # | Archivo | Estado |
|---|---------|--------|
| 1.1 | `by_feature/auth/models/role_type.dart` — Enum `RoleType` | ✅ Completado |
| 1.2 | `by_feature/auth/models/business_context.dart` — Enum `BusinessContext` | ✅ Completado |
| 1.3 | `by_feature/auth/models/permission.dart` — Enum `Permission` | ✅ Completado |
| 1.4 | `by_feature/auth/models/user_role.dart` — Modelo `UserRole` | ✅ Completado |
| 1.5 | `by_feature/auth/models/commerce_context.dart` — Modelo `CommerceContext` | ✅ Completado |
| 1.6 | `by_feature/auth/auth.dart` — Barrel de exports | ✅ Completado |
| 1.7 | `menu_com_api.dart` — Agregar exports de modelos auth | ✅ Completado |

---

## Fase 2: Nuevos Endpoints de Auth

| # | Carpeta | Endpoint | Estado |
|---|---------|----------|--------|
| 2.1 | `auth/refresh/` | `POST /auth/refresh` | ✅ Completado |
| 2.2 | `auth/switch_context/` | `POST /auth/switch-context` | ✅ Completado |
| 2.3 | `auth/my_contexts/` | `GET /auth/my-contexts` | ✅ Completado |
| 2.4 | `auth/social_login/` (actualizar) | `POST /auth/social/register` | ✅ Completado |

---

## Fase 3: CRUD de User Roles

| # | Carpeta | Endpoint | Estado |
|---|---------|----------|--------|
| 3.1 | `user_roles/assign_role/` | `POST /user-roles/assign` | ✅ Completado |
| 3.2 | `user_roles/revoke_role/` | `DELETE /user-roles/revoke` | ✅ Completado |
| 3.3 | `user_roles/update_role/` | `PATCH /user-roles/:roleId` | ✅ Completado |
| 3.4 | `user_roles/get_user_roles/` | `GET /user-roles/user/:userId` | ✅ Completado |
| 3.5 | `user_roles/get_user_permissions/` | `GET /user-roles/user/:userId/permissions/:context` | ✅ Completado |
| 3.6 | `user_roles/my_roles/` | `GET /user-roles/my-roles` | ✅ Completado |
| 3.7 | `user_roles/my_permissions/` | `GET /user-roles/my-permissions/:context` | ✅ Completado |
| 3.8 | `user_roles/user_roles.dart` — Barrel | ✅ Completado |

---

## Fase 4: Actualizar Modelos Existentes

| # | Archivo | Cambio | Estado |
|---|---------|--------|--------|
| 4.1 | `DinningModel` | Agregar `commerceId`, `socialToken`, `firebaseProvider`, `isEmailVerified`, `lastLoginAt`, `membership`, `businessName`, `slug`, `fcmToken`, `isFeatured`, etc. | ✅ Completado |
| 4.2 | `RolesUsers` enum | Agregar helpers `toRoleType()` y `toBusinessContext()` al nuevo sistema | ✅ Completado |
| 4.3 | `UserSuccess` model | Agregar `commerceId` + actualizar login/register providers | ✅ Completado |
| 4.4 | `SocialLoginResponse` | Agregar `commerceId` | ✅ Completado |

---

## Fase 5: Actualizar Barril Principal

| # | Archivo | Cambio | Estado |
|---|---------|--------|--------|
| 5.1 | `menu_com_api.dart` | Agregar exports de auth, user_roles | ✅ Completado |

---

## Fase 6: Health Check

| # | Carpeta | Endpoint | Estado |
|---|---------|----------|--------|
| 6.1 | `auth/health/` | `GET /auth/firebase/health` | ✅ Completado |

---

## Fase 7: Commerce (Feature completa)

| # | Endpoint | Estado |
|---|----------|--------|
| 7.1 | `POST /commerce` | ✅ Completado |
| 7.2 | `GET /commerce/my` | ✅ Completado |
| 7.3 | `GET /commerce/:commerceId` | ✅ Completado |
| 7.4 | `PUT /commerce/:commerceId` | ✅ Completado |
| 7.5 | `DELETE /commerce/:commerceId` | ✅ Completado |

## Fase 8: Orders (Endpoints faltantes)

| # | Endpoint | Estado |
|---|----------|--------|
| 8.1 | `GET /orders/byAnonymous` | ✅ Completado |
| 8.2 | `PUT /orders/:id` | ✅ Completado |
| 8.3 | `PUT /orders/:id/status` | ✅ Completado |
| 8.4 | `GET /orders/:id` | ✅ Completado |
| 8.5 | `DELETE /orders/:id` | ✅ Completado |

## Fase 9: Payments (Endpoints faltantes)

| # | Endpoint | Estado |
|---|----------|--------|
| 9.1 | `GET /payments/status/:id` | ✅ Completado |
| 9.2 | `POST /payments/checkin/:id` | ✅ Completado |
| 9.3 | `POST /payments/webhooks` | ⬛ No aplica (server-side webhook) |

---

## Leyenda
- ✅ Completado
- 🔄 En progreso
- ❌ Pendiente
- ⏸️ Bloqueado
- ⬛ No aplica
