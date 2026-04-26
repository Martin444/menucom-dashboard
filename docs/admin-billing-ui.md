# Documentación: Admin Billing Management UI

> **Fecha**: 2026-04-26
> **Estado**: A implementar
> **Referencia**: `ADMIN-BILLING-SYSTEM.md` del API

---

## 1. Análisis de Requisitos

### Producto
- **Tipo**: SaaS Admin Dashboard - Gestión de Facturación
- **Usuario**: Administrador de Menucom
- **Funcionalidad**: Control completo de facturación de membresías de usuarios

### Flujos de Usuario

| Endpoint | Acción | UI |
|----------|--------|-----|
| `generate-payment-link` | Generar link de pago manual | Modal con form |
| `enable-auto-billing` | Activar suscripción automática | Modal con card token |
| `get-billing-details` | Ver detalles de billing | Panel lateral o página |
| `change-billing_amount` | Cambiar monto | Modal con input |
| `migrate-to-auto-billing` | Migrar manual → auto | Modal confirmation |
| `migrate-to-manual` | Migrar auto → manual | Modal confirmation |
| `pause/resume/extend` | Gestionar suscripción | Botones de acción |

---

## 2. Design System

### 2.1 Patrón
- **Layout**: Admin Dashboard con sidebar navegación
- **Navegación**: Tabs o sub-secciones en vista de usuario

### 2.2 Colores (Based on existing palette)

| Propósito | Color | Usage |
|----------|-------|-------|
| Primary | `#1E40AF` (blue-800) | Buttons, links |
| Success | `#16A34A` (green-600) | Active subscriptions |
| Warning | `#D97706` (amber-600) | Pending payments |
| Danger | `#DC2626` (red-600) | Cancel, pause |
| Neutral | `#6B7280` (gray-500) | Inactive |

### 2.3 Estados de Facturación

| Billing Mode | Color | Badge |
|--------------|-------|-------|
| `none` | Gray | Sin facturar |
| `manual` | Amber | Link pendiente / Pagado |
| `auto` | Green | Activo / Pausado |

### 2.4 Tipografía
- **Font**:现有的pu_material typography
- **Headings**: 18px bold
- **Body**: 14px regular
- **Labels**: 12px medium, gray-500

### 2.5 Efectos
- Card elevation: `box-shadow: 0 1px 3px rgba(0,0,0,0.1)`
- Hover: `transition: all 150ms ease`
- Modals: centered, max-width 500px

---

## 3. Componentes UI

### 3.1 Billing Summary Card (en User List)

```
┌─────────────────────────────────────────┐
│ [Avatar] Nombre Apellido                 │
│ email@domain.com                        │
│ ────────────────────────────────────── │
│ Plan: Premium    Estado: Activo        │
│ 💳 Auto-Billing | Próximo: 25/05/2026 │
│ [View Details] [Generate Link] [Edit]│
└─────────────────────────────────────────┘
```

### 3.2 Billing Details Panel

```
┌────────────────────────────────────────────────────────┐
│ DETALLES DE FACTURACIÓN                     [X]        │
│ ─────────────────────────────────────────────────────│
│ Usuario: Juan Pérez                                    │
│ Plan: Premium (base: $15,000)                        │
│ Modo: AUTO ✓                        [Cambiar Modo ▼] │
│ ┌──────────────────────────────────────────────────┐│
│ │ PRECIO                                       ││
│ │ $12,000 (override admin)        [Cambiar Monto]  ││
│ └──────────────────────────────────────────────────┘│
│ ┌──────────────────────────────────────────────────┐│
│ │ AUTO-BILLING (Mercado Pago)                      ││
│ │ Preapproval: preapproval_xxx                       ││
│ │ Estado: authorized                          ││
│ │ Próximo cobro: 25/05/2026                 ││
│ │ [--Pausar--] [--Reanudar--]              ││
│ └──────────────────────────────────────────────────┘│
│ ┌──────────────────────────────────────────────────┐│
│ │ HISTORIAL DE PAGOS                          ││
│ │ 25/04/2026 $12,000 ✓ approved           ││
│ │ 25/03/2026 $12,000 ✓ approved           ││
│ │ 25/02/2026 $12,000 ✓ approved           ││
│ └──────────────────────────────────────────────────┘│
│                                          [Cerrar] │
└────────────────────────────────────────────────────────┘
```

### 3.3 Generate Payment Link Modal

```
┌─────────────────────────────────────────┐
│ GENERAR LINK DE PAGO          [X]       │
│ ────────────────────────────────────── │
│ Plan: [Premium ▼]                      │
│ Monto: [$    ] (base: $15,000)         │
│ Período: [1 ▼] meses                   │
│ Descripción: [                        ] │
│ ────────────────────────────────────── │
│ [Cancelar]              [Generar Link]  │
└─────────────────────────────────────────┘
```

### 3.4 Enable Auto-Billing Modal

```
┌─────────────────────────────────────────┐
│ HABILITAR AUTO-BILLING         [X]        │
│ ────────────────────────────────────── │
│ Plan: [Premium ▼]                      │
│ Monto (opcional): [$    ]              │
│ Card Token: [tok_xxx] (from MP SDK)   │
│ Ciclo: (○ Mensual ● Anual)            │
│ ────────────────────────────────────── │
│ [Cancelar]              [Habilitar]   │
└─────────────────────────────────────────┘
```

### 3.5 Billing Mode Actions

| Current Mode | Available Actions |
|-------------|-------------------|
| `NONE` | Generate Link, Enable Auto |
| `MANUAL` | Enable Auto, View Details |
| `AUTO` | Change Amount, Pause, Resume, Migrate to Manual, View Details |

---

## 4. Estructura de Archivos

### Implementar en:

```
lib/features/admin/
├── presentation/
│   ├── controllers/
│   │   └── users_controller.dart    ← AGREGAR billing use cases
│   └── views/
│       └── users_view.dart        ← AGREGAR billing UI
```

### Nuevos métodos en UsersController:

```dart
// Billing Use Cases
late final GeneratePaymentLinkUseCase generatePaymentLinkUseCase;
late final EnableAutoBillingUseCase enableAutoBillingUseCase;
late final GetBillingDetailsUseCase getBillingDetailsUseCase;
late final ChangeBillingAmountUseCase changeBillingAmountUseCase;
late final MigrateToAutoBillingUseCase migrateToAutoBillingUseCase;
late final MigrateToManualBillingUseCase migrateToManualBillingUseCase;
late final ManageUserSubscriptionUseCase manageUserSubscriptionUseCase;

// Billing State
final currentBillingDetails = Rx<BillingDetailsModel?>(null);
final isLoadingBilling = false.obs;
```

---

## 5. Estados y Manejo de Errores

### Estados de Carga
- `isLoadingBilling`: Show skeleton/spinner

### Errores Comunes
| Error | Mensaje UI |
|-------|-----------|
| `user not found` | "Usuario no encontrado" |
| `invalid card` | "Tarjeta inválida" |
| `amount invalid` | "Monto inválido" |
| `network error` | "Error de conexión" |

### Validaciones
- Amount ≥ 0
- Period Months: 1-12
- Description: max 200 chars
- Card Token: required for auto-billing

---

## 6. Checklist de Implementación

- [ ] Agregar imports de billing use cases
- [ ] Inicializar use cases en constructor
- [ ] Agregar método `showBillingDetails(userId)`
- [ ] Agregar método `showGeneratePaymentLinkModal(userId)`
- [ ] Agregar método `showEnableAutoBillingModal(userId)`
- [ ] Agregar método `changeBillingAmount(membershipId, newAmount)`
- [ ] Agregar método `migrateToAuto(membershipId, cardToken)`
- [ ] Agregar método `migrateToManual(membershipId)`
- [ ] Agregar método `pauseSubscription(membershipId)`
- [ ] Agregar método `resumeSubscription(membershipId)`
- [ ] Agregar método `extendMembership(membershipId, months)`
- [ ] Integrar UI en UsersView
- [ ] Testing

---

## 7. Mock Data para Testing

```dart
final testBillingDetails = BillingDetailsModel(
  membershipId: 'test-uuid',
  userId: 'user-uuid',
  billingMode: BillingMode.auto,
  currentPlan: BillingPlanInfo(
    name: 'premium',
    displayName: 'Premium Mensual',
    basePrice: 15000,
  ),
  effectivePrice: 12000,
  adminSetPrice: 12000,
  autoBilling: AutoBillingInfo(
    mpPreapprovalId: 'preapproval_123',
    status: 'authorized',
    nextBillingDate: DateTime(2026, 5, 25),
    lastPaymentAt: DateTime(2026, 4, 25),
    paymentMethodId: '137894525',
  ),
  manualBilling: null,
  paymentHistory: [
    PaymentHistoryItem(
      id: 'pay_1',
      date: DateTime(2026, 4, 25),
      amount: 12000,
      status: 'approved',
      type: 'subscription_payment',
      periodMonths: 1,
      isAdminGenerated: false,
    ),
  ],
);
```

---

## 8. Referencias

- API Docs: `menucom-api/docs/integration/ADMIN-BILLING-SYSTEM.md`
- Menu Dart API: `menu_dart_api/lib/by_feature/membership/`
- Existing UI: `lib/features/admin/presentation/views/users_view.dart`
- Membership Controller: `lib/features/admin/presentation/controllers/membership_admin_controller.dart`