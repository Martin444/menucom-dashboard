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

### 1.1 Centralizar redirect URIs de MercadoPago

**Qué:** Reemplazar 3 ocurrencias de string hardcodeado por `Config.mpRedirectUri`.

**Archivos:**
- [ ] `lib/features/home/presentation/organisms/head_dinning.dart` (líneas 137, 224)
- [ ] `lib/features/home/presentation/atoms/user_info_header.dart` (línea 64)

**Verificación:** `git grep 'menucom-api.onrender.com/payments/oauth/callback'` debe dar 0 resultados.

### 1.2 Fix memory leak en DinningController

**Qué:** Agregar `@override void dispose()` con `.dispose()` para `nameController`, `priceController`, `deliveryController`.

**Archivo:**
- [ ] `lib/features/home/controllers/dinning_controller.dart`

**Verificación:** `flutter analyze` sin warnings de controllers sin dispose.

### 1.3 Centralizar breakpoints

**Qué:** Crear constantes compartidas en pu_material.

**Archivo NUEVO (pu_material):**
- [ ] `pu_material/lib/utils/pu_breakpoints.dart`
  - `kMobileBreakpoint = 768`
  - `kTabletBreakpoint = 1024`
  - `kSmallBreakpoint = 450`

**Archivos a actualizar importando desde pu_material:**
- [ ] `lib/features/home/presentation/organisms/mp_link_banner.dart` (usaba 700, 450)
- [ ] `lib/features/home/presentation/widget/unlinked_catalogs_banner.dart` (usaba 700)
- [ ] `lib/features/home/presentation/organisms/head_dinning.dart` (usaba 768, 1024)

### 1.4 Reemplazar `Icons.*` por `FluentIcons.*`

**Archivos:**
- [ ] `lib/features/home/presentation/atoms/ward_item_tile.dart:29` → `FluentIcons.edit_16_regular`
- [ ] `lib/features/home/presentation/widget/mp_oauth_gate_widget.dart:204,241,278`
- [ ] `lib/features/home/presentation/widget/mp_banner_header.dart:40,80`

**Referencia:** `docs/FLUENT_ICONS_MAPPING.md`

---

## Fase 2: Refactor de DinningController (God Object)

### 2.1 Extraer controladores

**NUEVOS archivos en `lib/features/home/controllers/`:**

| Controlador | Responsabilidad | Métodos a migrar |
|---|---|---|
| `user_session_controller.dart` | Login, logout, token, user info, roles | `dinningLogin()`, `getMyDinningInfo()`, `closeSesion()`, `hashAccessToken()`, `_initUserData()` |
| `mp_link_controller.dart` | Vinculación MP, OAuth flow | `_verifyMPLinkingStatus()`, `linkMPAccount()`, `unlinkMPAccount()` |
| `catalog_selection_controller.dart` | Listas de catálogos, cambio de contexto | `menusList`, `catalogList`, `wardList`, `changeCommerceContext()`, `loadCatalogsByRole()` |
| `form_controller.dart` | Formularios de creación/edición | `nameController`, `priceController`, `deliveryController`, `menusToEdit` |

**Archivo a modificar:**
- [ ] `lib/features/home/controllers/dinning_controller.dart` → queda como orquestador mínimo (~80 líneas) con solo `dinningLogin`, `isLoadingDataUser`, `isCustomerRole`. O se elimina por completo si cada sub-controlador se vuelve independiente.

### 2.2 Actualizar binding

- [ ] `lib/features/home/getx/dinning_binding.dart` → registrar todos los nuevos controladores con `Get.lazyPut`

### 2.3 Migrar referencias

- [ ] Actualizar `Get.find<DinningController>()` en ~15 widgets al controlador específico correspondiente
- [ ] `lib/features/home/presentation/pages/home_page.dart`
- [ ] `lib/features/home/presentation/organisms/head_dinning.dart`
- [ ] `lib/features/home/presentation/organisms/head_actions.dart`
- [ ] `lib/features/home/presentation/widget/get_function_button.dart`
- [ ] `lib/features/home/presentation/widget/mp_oauth_gate_widget.dart`
- [ ] `lib/features/home/presentation/organisms/mp_link_banner.dart`
- [ ] `lib/features/home/presentation/widget/mp_banner_header.dart`
- [ ] `lib/features/home/presentation/widget/mp_banner_actions.dart`
- [ ] `lib/features/home/presentation/widget/unlinked_catalogs_banner.dart`
- [ ] `lib/features/home/presentation/widget/missing_logo_banner.dart`
- [ ] `lib/features/home/presentation/molecules/context_switcher_molecule.dart`
- [ ] `lib/features/home/presentation/atoms/user_info_header.dart`
- [ ] `lib/features/home/presentation/views/menu_home_view.dart`
- [ ] `lib/features/home/presentation/views/ward_home_view.dart`
- [ ] `lib/features/home/presentation/widget/menu_side.dart`

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
         ✅ git grep 'menucom-api.onrender.com/payments/oauth/callback' = 0
         ✅ Todos los breakpoints usan constantes de pu_material
         ✅ 0 ocurrencias de Icons.* en lib/features/home/

Fase 2: ✅ DinningController < 100 líneas (o eliminado)
         ✅ Todos los Get.find apuntan al controlador correcto
         ✅ flutter analyze sin errores
         ✅ git add + commit

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
