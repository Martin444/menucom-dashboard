# maxCommerces — Límite de Comercios por Plan

## ¿Qué se implementó?

Se agregó un límite `maxCommerces` en los planes de membresía para controlar cuántos comercios puede crear un usuario.

### Backend (menucom-api)

| Archivo | Cambio |
|---------|--------|
| `src/membership/enums/membership-plan.enum.ts` | Se agregó `maxCommerces` a `PLAN_LIMITS` |
| `src/membership/entities/subscription-plan.entity.ts` | Se agregó `maxCommerces: number` al tipo `limits` |
| `src/membership/dto/create-subscription-plan.dto.ts` | Se agregó `maxCommerces` a `PlanLimitsDto` |
| `src/membership/services/subscription-plan.service.ts` | Se agregó `maxCommerces` a los planes seed |
| `src/commerce/commerce.service.ts` | Se inyectó `MembershipService` y se agregó validación en `create()` |
| `src/commerce/commerce.controller.ts` | Se pasa `isAdmin` desde el request |
| `src/commerce/commerce.module.ts` | Se agregó `forwardRef(() => MembershipModule)` |

### Frontend (menucom-dashboard)

| Archivo | Cambio |
|---------|--------|
| `menu_dart_api/lib/by_feature/membership/models/membership_plan_model.dart` | Se agregó `maxCommerces` al modelo |
| `lib/features/admin/presentation/widgets/plan_form_dialog.dart` | Se agregó campo `Máx. Comercios` al formulario |
| `lib/features/admin/presentation/widgets/membership_plans_table.dart` | Se agregó `M` a la columna de límites |

### Límites por plan

| Plan | maxCommerces |
|------|-------------|
| FREE | 1 |
| PREMIUM | 3 |
| ENTERPRISE | -1 (ilimitado) |

### Comportamiento

- **ADMIN** bypass: si `isAdmin=true`, salta la validación
- Retrocompatible: planes sin `maxCommerces` en DB reciben `undefined` → `count >= undefined` es `false` → creación permitida
- Se cuentan todos los comercios (activos e inactivos)
- Mensaje de error: "Has alcanzado el límite de comercios permitido por tu plan. Actualiza tu membresía para crear más comercios."

---

## Lo que falta (para el próximo desarrollador)

### 1. 🔴 Frontend: Manejar el error 400 en registro y en creación de comercios

El backend ya devuelve `400 BadRequest` con el mensaje de límite alcanzado, pero el frontend no lo captura de forma específica:

**a) `auth_controller.dart:registerCommerce()`** (registro inicial)
- Línea 385: el `catch (e)` muestra un mensaje genérico "No se pudo completar el registro"
- Detectar si el error es `ApiException` con código 400 y mensaje de límite, mostrar mensaje específico
- En registro igual siempre pasa (1 commerce permitido), pero por si en el futuro se permite registrar desde cuenta existente

**b) No existe flujo para crear comercios adicionales**
- `CreateCommerceUseCase` está definido en `menu_dart_api` pero **nunca se usa** en el dashboard
- No hay pantalla/botón para "Crear nuevo comercio"
- El próximo desarrollador que implemente multi-comercio debe:
  1. Usar `CreateCommerceUseCase` desde algún controller
  2. Capturar `ApiException(400, ...)` cuando se exceda `maxCommerces`
  3. Mostrar mensaje claro al usuario: "Has alcanzado el límite de comercios permitido por tu plan."

### 2. 🟡 Falta implementar switch de contexto real

El `POST /auth/switch-context` está pendiente (mencionado en `AGENTS.md`). Sin esto:
- No hay forma de cambiar entre comercios desde el dashboard
- El `context_switcher_molecule.dart` solo cambia datos locales, no resuelve permisos
- MANAGER no puede operar porque los datos se filtran por `userId`, no `commerceId`

### 3. 🟡 Migración ownerId → commerceId

Todos los servicios que filtran por `ownerId = req.user.userId` deben migrar a `commerceId`. Es el prerrequisito bloqueante para multi-tenant real.

### 4. 🟢 Admin: formulario de planes ya incluye maxCommerces

El `plan_form_dialog.dart` ya tiene el campo. Probado visualmente.

### 5. 🟢 Documentación actualizada

Se actualizaron 6 archivos de documentación con `maxCommerces`. Ver `docs/implementation/CUSTOM_PLANS_IMPLEMENTATION.md` como referencia principal.

---

## Arquitectura de la validación

```
AuthService.registerUser()        CommerceService.create()         MembershipService.getPlanLimits()
  └─► commerceService.create()     └─► check maxCommerces            └─► PLAN_LIMITS[plan]
      (registration)                   ├─ if ADMIN → skip             └─► subscription_plan.limits
                                       ├─ if undefined → allow
                                       ├─ if -1 → allow
                                       └─ if count >= limit → throw

POST /commerce (desde dashboard)
  └─► CommerceService.create()
       (misma validación, no usado aún)
```

---

## Contacto / Historial

Implementado: 2026-06-15 por agente IA
Próximo paso: Un desarrollador humano debe conectar el flujo de creación de comercios en el dashboard
