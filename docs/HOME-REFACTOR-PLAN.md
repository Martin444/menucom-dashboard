# Refactor Plan: `lib/features/home/`

> **Regla fundamental:** Todo widget NUEVO creado durante este refactor debe ir en `pu_material/` como componente compartido y parametrizado, siguiendo Atomic Design estricto. Los widgets existentes en home NO se migran a pu_material a menos que se demuestre reutilización cross-feature.

---

## Resumen de deuda técnica

| Item | Severidad | Archivos impactados |
|---|---|---|
| `DinningController` God Object (~430 líneas) | 🔴 | 15+ widgets |
| Duplicación `menu_home_view` / `ward_home_view` (~80% igual) | 🔴 | 2 vistas |
| Redirect URIs hardcodeadas en 3 archivos | 🔴 | 3 archivos |
| Memory leak (`TextEditingController` sin dispose) | 🔴 | 1 controlador |
| `GetBuilder` anidado + `Obx` redundante en `home_page` | 🟡 | 1 página |
| Switch de roles duplicado en `get_function_button` (3 veces) | 🟡 | 1 widget |
| `LayoutBuilder` redundante en 5 widgets | 🟡 | 5 widgets |
| Iconos decorativos sin acción (`head_dinning`) | 🔵 | 1 widget |
| Badges muertos en `menu_side` | 🔵 | 1 widget |

---

## Fase 1: Quick Wins (independientes, sin riesgo)

> ✅ **COMPLETADA** — 2026-06-20

### 1.1 Centralizar redirect URIs de MercadoPago

**Qué:** Reemplazar 3 ocurrencias de string hardcodeado por `Config.mpRedirectUri`.

**Archivos:**
- [x] `lib/features/home/presentation/widget/head_dinning.dart` (2 ocurrencias)
- [x] `lib/features/home/presentation/widget/user_info_header.dart` (1 ocurrencia)

**Nota:** Las rutas reales difieren del plan original (`widget/` en vez de `organisms/` y `atoms/`).

### 1.2 Fix memory leak en DinningController

**Qué:** Agregar `@override void onClose()` con `.dispose()` para `nameController`, `priceController`, `deliveryController`.

**Archivo:**
- [x] `lib/features/home/controllers/dinning_controller.dart`

**Nota:** Se usó `onClose()` (GetX) en vez de `dispose()`. Luego migró a `FormController.onClose()`.

### 1.3 Centralizar breakpoints

**Archivo NUEVO (pu_material):**
- [x] `pu_material/lib/utils/pu_breakpoints.dart`

**Archivos actualizados:**
- [x] `lib/features/home/presentation/organisms/mp_link_banner.dart`
- [x] `lib/features/home/presentation/organisms/unlinked_catalogs_banner.dart`
- [x] `lib/features/home/presentation/widget/head_dinning.dart`

### 1.4 Reemplazar `Icons.*` por `FluentIcons.*`

**Archivos actualizados (18 ocurrencias en 10 archivos):**
- [x] `ward_item_tile.dart` → `FluentIcons.edit_16_regular`
- [x] `mp_oauth_gate_widget.dart` → `error_circle_24_regular`, `wallet_24_regular`, `checkmark_circle_24_regular`, `open_24_regular`
- [x] `mp_banner_header.dart` → `wallet_24_regular`, `dismiss_24_regular`
- [x] `mp_banner_benefits.dart` → `flash_24_regular`, `shield_checkmark_24_regular`, `data_trending_24_regular`
- [x] `mp_banner_actions.dart` → `arrow_right_24_regular`
- [x] `mp_link_banner.dart` → `wallet_24_regular`
- [x] `mp_refresh_button.dart` → `arrow_sync_24_regular`
- [x] `dinning_controller.dart` → `error_circle_24_regular`, `checkmark_circle_24_regular`
- [x] `category_tags_section.dart` → `apps_24_regular`
- [x] `service_home_view.dart` → `wrench_24_regular`, `clipboard_task_list_ltr_24_regular`

### 1.5 Fix extra (no planeado): `home_page.dart` — Corrección en `_buildMainContent`

- [x] Validar `commerceId` no vacío además de `hasSelectedCommerce` para mostrar `_CommerceGate`

---

## Fase 2: Refactor de DinningController (God Object)

> ✅ **COMPLETADA** — 2026-06-20

### Arquitectura resultante

| Controlador | Líneas | Responsabilidad |
|---|---|---|
| `dinning_controller.dart` | ~95 | Fachada/orquestador. Delega todo a sub-controladores. Expone mismos getters/métodos que antes para retrocompatibilidad. |
| `user_session_controller.dart` | ~195 | Sesión, user info, roles, `getMyDinningInfo()`, `closeSesion()`, `getUsersByRoles()`, `usersByRolesList`, `everyListEmpty` |
| `mp_link_controller.dart` | ~103 | Vinculación MP, OAuth, banner visibility, `checkMPStatus()`, `vincularMercadoPago()` |
| `form_controller.dart` | ~32 | `TextEditingController`s, `menusToEdit` |

**Controladores NO creados (desviación del plan):**
- `catalog_selection_controller.dart` — **Eliminado**. Era un duplicado innecesario de `CatalogsController` (de `lib/features/catalogs/getx/`) que la UI ya usaba. Causó bugs de sincronización.

### Lecciones aprendidas (GetX + ciclo de vida)

1. **`fenix: true` en `Get.lazyPut` es necesario** cuando una ruta usa `Get.offAllNamed()`. Sin `fenix`, el controller se destruye al hacer pop de la ruta y la UI nueva observa una instancia fresca sin datos.

2. **No duplicar controladores existentes.** Si la UI ya usa `CatalogsController`, no crear un `CatalogSelectionController` paralelo. La sesión debe usar el mismo controlador o delegar la carga a las vistas.

3. **`GetBuilder(init: controller)` + `assignId: true`** puede re-disparar `onInit()` en GetX 5.x. Usar solo `GetBuilder(builder: ...)` sin `init:` cuando el controller ya está registrado vía binding.

4. **No cargar catálogos desde `getMyDinningInfo()`** si las vistas (`menu_home_view`, `ward_home_view`) ya lo hacen. Causa doble llamado a `loadCatalogsByType()` con conflicto de guard `_isLoadingCatalogsInternal`.

5. **`ever()` en el orquestador** propaga cambios de Rx en sub-controladores para que `GetBuilder`/`GetView` (que dependen de `update()`) sigan funcionando.

### Binding final

```dart
// dinning_binding.dart
Get.lazyPut(() => UserSessionController(), fenix: true);
Get.lazyPut(() => MPLinkController(), fenix: true);
Get.lazyPut(() => FormController(), fenix: true);
Get.lazyPut(() => DinningController(), fenix: true);
```

### Widgets actualizados

Los widgets **no se migraron** a usar sub-controladores directamente. `DinningController` mantiene la misma API pública mediante getters delegados, por lo que `Get.find<DinningController>()` y `GetBuilder<DinningController>` siguen funcionando sin cambios en ~15 widgets.

---

## Fase 3: Unificar `menu_home_view` + `ward_home_view`

### 3.1 Crear template genérico

**NUEVO (pu_material):** Template genérico de catálogo.

- [ ] `pu_material/lib/features/catalog/templates/catalog_home_template.dart`
  - Props: `List<T> items`, `Widget Function(T) itemBuilder`, `String roleType`, `VoidCallback onCreateCatalog`, `bool isMobile`, `bool isLoading`, `Widget? emptyState`
  - Ref: los archivos existentes `pu_material/lib/features/orders/ui/templates/orders_template.dart`

**NUEVO (pu_material):** Organismo de grid de catálogo.
- [ ] `pu_material/lib/features/catalog/organisms/catalog_grid_organism.dart`
  - Props: `List<T> items`, `Widget Function(T) itemBuilder`, `bool isMobile`, `ScrollController? scrollController`

### 3.2 Simplificar vistas existentes

- [ ] `lib/features/home/presentation/views/menu_home_view.dart` → ~50 líneas, delega a `CatalogHomeTemplate<MenuItemTile>`
- [ ] `lib/features/home/presentation/views/ward_home_view.dart` → ~50 líneas, delega a `CatalogHomeTemplate<WardItemTile>`

### 3.3 Registrar barrel de pu_material

- [ ] `pu_material/lib/pu_material.dart` → agregar exports del nuevo feature `catalog`

---

## Fase 4: Refactor de performance en widgets clave

### 4.1 Eliminar `GetBuilder` anidado + `Obx` redundante en `home_page.dart`

- [ ] `lib/features/home/presentation/pages/home_page.dart` → todo el subtree bajo un solo `Obx`, eliminar `GetBuilder` intermedio

### 4.2 Extraer `ResponsiveBuilder` widget compartido

**NUEVO (pu_material):**
- [ ] `pu_material/lib/widgets/pu_responsive_builder.dart`
  - Usa `LayoutBuilder` internamente, expone `isMobile`, `isTablet`, `isDesktop`, `breakpoint` como context extension o builder callback.
  - Elimina la necesidad de `LayoutBuilder` en 5 widgets del home.

**Archivos a simplificar:**
- [ ] `lib/features/home/presentation/organisms/mp_link_banner.dart`
- [ ] `lib/features/home/presentation/widget/unlinked_catalogs_banner.dart`
- [ ] `lib/features/home/presentation/organisms/head_dinning.dart`
- [ ] `lib/features/home/presentation/widget/share_link_menu_dialog.dart`
- [ ] `lib/features/home/presentation/pages/home_page.dart`

### 4.3 Refactor `get_function_button.dart`

**Qué:** Reemplazar el switch de roles triplicado por un `List<RoleActionConfig>` parametrizado.

**NUEVO (pu_material):**
- [ ] `pu_material/lib/atoms/role_action_config.dart` → Data class `RoleActionConfig` con `icon`, `label`, `route`, `onTap`, `planRequired`

**Archivo a refactor:**
- [ ] `lib/features/home/presentation/widget/get_function_button.dart` → construir botones desde lista de `RoleActionConfig`

### 4.4 Unificar builds mobile/desktop en `menu_side.dart`

- [ ] `lib/features/home/presentation/widget/menu_side.dart` → extraer widget común entre los dos builds

---

## Fase 5: UI/UX Fixes

- [ ] `lib/features/home/presentation/widget/menu_side.dart` — Eliminar badges muertos (`_shouldShowBadge`, `_getBadgeText`)
- [ ] `lib/features/home/presentation/pages/home_page.dart:121` — Corregir doble padding con `MPLinkBanner`
- [ ] `lib/features/home/presentation/organisms/head_dinning.dart:117-119,206` — Quitar iconos decorativos sin `onTap` o conectar a funcionalidad real
- [ ] `lib/features/home/presentation/widget/catalog_empty_state.dart` — Hacer `onCreateCatalog` obligatorio (no default que navega a wardrobes)

---

## Fase 6: Testing

- [ ] `test/features/home/controllers/user_session_controller_test.dart`
- [ ] `test/features/home/controllers/mp_link_controller_test.dart`
- [ ] `test/features/home/controllers/catalog_selection_controller_test.dart`
- [ ] `test/features/home/controllers/form_controller_test.dart`
- [ ] `test/pu_material/features/catalog/templates/catalog_home_template_test.dart`
- [ ] `test/pu_material/widgets/pu_responsive_builder_test.dart`

---

## Checklist de verificación por fase

```
Fase 1: ✅ flutter analyze sin errores
         ✅ git grep 'menucom-api.onrender.com/payments/oauth/callback' en home = 0
         ✅ Todos los breakpoints usan constantes de pu_material
         ✅ 0 ocurrencias de Icons.* en lib/features/home/

Fase 2: ✅ DinningController ~95 líneas (orquestador)
         ✅ 3 sub-controladores extraídos + FormController
         ✅ CatalogSelectionController eliminado (duplicado de CatalogsController)
         ✅ flutter analyze sin errores
         ✅ catálogos se muestran correctamente
         ✅ commerce gate funciona tras switchContext

Fase 3: ✅ menu_home_view.dart + ward_home_view.dart < 60 líneas c/u
         ✅ CatalogHomeTemplate en pu_material con tests
         ✅ flutter analyze sin errores

Fase 4: ✅ home_page.dart usa solo Obx (sin GetBuilder anidado)
         ✅ ResponsiveBuilder en pu_material con test
         ✅ get_function_button.dart sin switch duplicado
         ✅ flutter analyze sin errores

Fase 5: ✅ 0 iconos decorativos sin acción
         ✅ 0 doble padding en layouts
         ✅ flutter analyze sin errores

Fase 6: ✅ Tests pasando
         ✅ flutter analyze sin errores
```

---

## Reglas para nuevos widgets en pu_material

```dart
// Template para todo widget NUEVO en pu_material:
//
// 1. Ubicación según Atomic Design:
//    atoms/       → bloques básicos (botón, texto, input)
//    molecule/    → combinación de atoms (tarjeta, header simple)
//    organisms/   → sección funcional compleja (grid, tabla, formulario)
//    widgets/     → wrappers técnicos (network image, responsive builder)
//    features/    → templates y páginas completas por dominio
//
// 2. Todo widget debe:
//    - Tener constructor con TODAS las props como parámetros (nada hardcodeado)
//    - Aceptar `VoidCallback?` o `Function` para toda interacción
//    - Recibir strings como parámetros (no texto hardcodeado)
//    - Soportar `isMobile` o `breakpoint` para responsividad
//    - Ser `const` siempre que sea posible
//    - NO depender de GetX (no Get.find dentro del widget)
//    - NO importar de `lib/features/` (pu_material no conoce features)
//
// 3. Exportar en pu_material.dart
//
// 4. Test unitario obligatorio
```

---

## Archivos NO modificados (sin cambios planificados)

```
lib/features/home/presentation/views/service_home_view.dart
lib/features/home/presentation/views/events_home_view.dart
lib/features/home/presentation/customer/
```
