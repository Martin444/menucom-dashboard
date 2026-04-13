# Registro de Tipos de Comercio - Seguimiento

## Fecha: 2026-04-12

## Objetivo
Agregar soporte en UI y Backend para múltiples tipos de comercio (ropa, comida, distribuidores, servicios, etc.)

---

## Avances

### ✅ Completado

| Fecha | Cambio | Archivo |
|-------|--------|---------|
| 2026-04-12 | Corregido bug UI: campo teléfono duplicado | `register_commerce.dart` |
| 2026-04-12 | Nuevo modelo TypeComerceModel con 12 tipos | `type_comerce_model.dart` |
| 2026-04-12 | Actualizada lista de comercios disponibles | `login_controller.dart` |
| 2026-04-12 | Coord con backend para switch extendido | `auth.service.ts` |
| 2026-04-12 | Expandido RolesUsers enum con 12 tipos | `roles_users.dart` |
| 2026-04-12 | Expandido BusinessType con 12 tipos | `business_type.dart` |
| 2026-04-12 | Actualizado DinningController para más tipos | `dinning_controller.dart` |
| 2026-04-12 | Actualizado CustomerDataHelper | `customer_data_helper.dart` |
| 2026-04-12 | Actualizado MenuNavigationItems | `menu_navigation_items.dart` |
| 2026-04-12 | Actualizado CustomerOrganisms | `customer_organisms.dart` |
| 2026-04-12 | Actualizado StarterBanner | `starter_banner.dart` |
| 2026-04-12 | Actualizado getFuncionButton | `get_funcion_button.dart` |
| 2026-04-12 | Actualizado BusinessTypeCard | `business_type_card.dart` |

---

## Inconsistencias Resueltas

- RolesUsers: eliminados `commerce` y `distributor` replaced by nuevos tipos
- DinningController: ahora soporta todo tipo de commerce para catálogo (`wardrobe`)
- CustomerDataHelper: usa lista completa de roles de negocio
- Menú: todos los roles de catálogo tienen acceso a menús y pedidos
- Navegación: roles de restaurante (`dinning`, `food`) van a menús, demás van a catálogos

---

## Pendientes

- [ ] Ninguno - Implementación completa ✅

---

## Mapeo Propuesto

| Code | Descripción | Context | Rol |
|------|-------------|---------|-----|
| `retail` | Venta de productos general | MARKETPLACE | OWNER |
| `water_distributor` | Distribuidora de agua | MARKETPLACE | OWNER |
| `grocery` | Distribuidora de alimentos | MARKETPLACE | OWNER |
| `food` | Restaurant/Comida | RESTAURANT | OWNER |
| `clothes` | Venta de ropa | WARDROBE | OWNER |
| `accessories` | Accesorios | MARKETPLACE | OWNER |
| `electronics` | Electrónica | MARKETPLACE | OWNER |
| `pharmacy` | Farmacia | GENERAL | OWNER |
| `beauty` | Belleza | GENERAL | OWNER |
| `construction` | Materiales de construcción | MARKETPLACE | OWNER |
| `automotive` | Automotriz | GENERAL | OWNER |
| `pets` | Petshop | MARKETPLACE | OWNER |

---

## Referencia

- Proposal: `C:\Users\aleja\Escritorio\Menucom\docs\commerce_types_proposal.md`
- Backend doc: `menucom-api/docs/modules/auth-module.md`