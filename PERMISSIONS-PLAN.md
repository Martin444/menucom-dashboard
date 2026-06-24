# Plan: Adaptar Home a Permisos por Rol

## Estado: ✅ COMPLETADO

## Matriz de Permisos

| Acción | Permiso | OWNER | MANAGER | OPERATOR |
|--------|---------|:-----:|:-------:|:--------:|
| Crear catálogo | CREATE_CATALOG | ✅ | ❌ | ❌ |
| Editar catálogo | UPDATE_CATALOG | ✅ | ✅ | ❌ |
| Eliminar catálogo | DELETE_CATALOG | ✅ | ❌ | ❌ |
| Agregar item | CREATE_ITEM | ✅ | ✅ | ❌ |
| Editar item | UPDATE_ITEM | ✅ | ✅ | ❌ |
| Eliminar item | DELETE_ITEM | ✅ | ✅ | ❌ |

## Comportamiento UI
- Acciones no permitidas → **ocultas completamente** de la UI
- El backend ya valida permisos en endpoints de escritura
- Esta implementación es **solo frontend** (adaptación de UI)

## Archivos

### Nuevo
- [x] `lib/features/home/controllers/user_role_service.dart` — Servicio centralizado de permisos

### Modificados
- [x] `lib/features/home/controllers/dinning_binding.dart` — Registrar UserRoleService
- [x] `lib/features/home/controllers/dinning_controller.dart` — Sync rol → permisos
- [x] `pu_material/lib/widgets/buttons/mc_option_buttons_tile.dart` — showEdit/showDelete
- [x] `pu_material/lib/molecule/menu_ward_item_tiles.dart` — Pasar permisos
- [x] `pu_material/lib/features/catalog/organisms/catalog_grid_organism.dart` — onCreateItem nullable
- [x] `pu_material/lib/organisms/catalog_empty_state.dart` — onCreateCatalog nullable
- [x] `lib/features/home/presentation/widget/catalog_sidebar.dart` — onEdit/onDelete nullable
- [x] `lib/features/home/presentation/views/menu_home_view.dart` — Gating permisos
- [x] `lib/features/home/presentation/views/ward_home_view.dart` — Gating permisos

## Flujo de Datos

```
UserSessionController.currentUserRole ("owner"/"manager"/"operator")
    ↓ ever()
DinningController.onInit() → UserRoleService.updateRole(role)
    ↓
UserRoleService.canCreateCatalog / canUpdateCatalog / ...
    ↓ Get.find<UserRoleService>()
MenuHomeView / WardsHomeView → pasa flags a widgets hijos
```

## Cambios por Archivo

### 1. user_role_service.dart (NUEVO)
- Servicio GetX con `fenix: true`
- Mapeo estático role → permisos
- Getters: canCreateCatalog, canUpdateCatalog, canDeleteCatalog, canCreateItem, canUpdateItem, canDeleteItem
- Método updateRole(String role)

### 2. dinning_binding.dart
- Agregado `Get.lazyPut(() => UserRoleService(), fenix: true)` antes de DinningController

### 3. dinning_controller.dart
- Inyectado UserRoleService via `Get.find<UserRoleService>()`
- En onInit(): `ever(_session.currentUserRole, (_) { _roleService.updateRole(...); update(); })`

### 4. mc_option_buttons_tile.dart
- Agregados `showEditAction` y `showDeleteAction` (bool, default true)
- PopupMenuItem condicionados según flags
- Si ambos false, retorna `SizedBox.shrink()` (no muestra el menú)

### 5. menu_ward_item_tiles.dart
- MenuItemTile/WardItemTile: agregados showEditAction/showDeleteAction (default true)
- Pasan flags a McOptionBtnTile

### 6. catalog_grid_organism.dart
- `onCreateItem`: `VoidCallback?` (nullable, antes required)
- En empty state: solo muestra botón si `onCreateItem != null`

### 7. catalog_empty_state.dart
- `onCreateCatalog`: `VoidCallback?` (nullable, antes required)
- Cuando null: muestra empty state simplificado sin botón

### 8. catalog_sidebar.dart
- `onEdit`: `ValueChanged<CatalogModel>?` (nullable, antes required)
- `onDelete`: `Future<void> Function(CatalogModel)?` (nullable, antes required)
- ItemCategoryTile oculta botones cuando callbacks son null

### 9. menu_home_view.dart
- Obtiene UserRoleService en initState
- Condicionaliza: actionButtons, onEditSelected, onDeleteSelected, onCreateItem, onCreateCatalog, onAdd, onEdit, onDelete en CatalogSidebar
- MenuItemTile recibe showEditAction/showDeleteAction según permisos
- Callback actionSelected verifica permisos antes de ejecutar

### 10. ward_home_view.dart
- Mismos cambios que menu_home_view.dart

## Reglas de GetX Aplicadas
- UserRoleService registrado con fenix: true en DinningBinding
- No se duplica lógica de permisos en CatalogsController
- Get.find<UserRoleService>() solo en initState de las vistas
- ever() para propagar cambios reactivos del rol

## Verificación
- [x] flutter analyze sin errores
- [x] OWNER ve todas las acciones (crear, editar, eliminar catálogos e items)
- [x] MANAGER ve: editar catálogo, crear/editar/eliminar items (no crear/eliminar catálogo)
- [x] OPERATOR ve: solo lectura (sin botones de acción)
