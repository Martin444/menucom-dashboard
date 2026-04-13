# Migración de Wardrobes/Menu a Catalogs - Documentación Técnica

## Resumen

Este documento describe la migración del sistema deprecated `Wardrobe`/`Menu` al nuevo sistema unificado `Catalogs` en el dashboard.

**Fecha de migración**: Abril 2026  
**Estado**: Completada

---

## Arquitectura Anterior vs Nueva

### Anterior (Deprecated)
- **Wardrobe Service**: Gestión de guardarropas/prendas (`WardrobeModel`)
- **Menu Service**: Gestión de menús/platos (`MenuModel`)
- Dos servicios separados con modelos diferentes

### Nueva (Catalogs - Actual)
- **Catalog Service**: Sistema unificado para cualquier tipo de catálogo
- Tipos: `menu`, `wardrobe`, `service`, etc.
- Un solo modelo: `CatalogModel` + `CatalogItemModel`

---

## Archivos Modificados

### 1. API Exports (`menu_dart_api/lib/menu_com_api.dart`)

Agregados exports para Catalog:
```dart
export 'package:menu_dart_api/by_feature/catalog/models/catalog_model.dart';
export 'package:menu_dart_api/by_feature/catalog/models/create_catalog_params.dart';
export 'package:menu_dart_api/by_feature/catalog/models/update_catalog_params.dart';
export 'package:menu_dart_api/by_feature/catalog/models/create_catalog_item_params.dart';
export 'package:menu_dart_api/by_feature/catalog/models/update_catalog_item_params.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/get_my_catalogs_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/create_catalog_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/update_catalog_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/delete_catalog_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/get_catalog_by_id_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/create_catalog_item_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/update_catalog_item_usecase.dart';
export 'package:menu_dart_api/by_feature/catalog/data/usecase/delete_catalog_item_usecase.dart';
```

### 2. Nuevo CatalogsController (`lib/features/catalogs/getx/`)

**Ubicación**: `lib/features/catalogs/getx/catalogs_controller.dart`

Métodos principales:
- `loadCatalogsByType(String type)` - Carga catálogos por tipo (menu/wardrobe/service)
- `createCatalog(String type)` - Crea nuevo catálogo
- `editCatalog(catalog, newDescription)` - Actualiza catálogo
- `deleteCatalog(catalog)` - Elimina catálogo
- `createCatalogItem()` - Crea item en catálogo
- `editCatalogItem()` - Actualiza item
- `deleteCatalogItem(item)` - Elimina item
- `changeCatalogSelected(catalog)` - Cambia catálogo seleccionado

Constantes de tipos:
```dart
static const String TYPE_MENU = 'menu';
static const String TYPE_WARDROBE = 'wardrobe';
static const String TYPE_SERVICE = 'service';
```

### 3. DinningController Actualizado

**Ubicación**: `lib/features/home/controllers/dinning_controller.dart`

Nuevos métodos:
- `getCatalogsByType(String type)` - Reemplaza `getWardrobebyDining()` y `getmenuByDining()`

Nuevas variables:
- `catalogsList` - Lista de catálogos
- `catalogSelected` - Catálogo seleccionado

Getters de retrocompatibilidad:
- `wardList` → `catalogsList`
- `menusList` → `catalogsList`
- `wardSelected` → `catalogSelected`
- `menuSelected` → `catalogSelected`

Métodos deprecated (para retrocompatibilidad):
- `getWardrobebyDining()` - Ahora llama internamente a `getCatalogsByType('wardrobe')`
- `getmenuByDining()` - Ahora llama internamente a `getCatalogsByType('menu')`

### 4. Vistas Actualizadas

#### menu_home_view.dart
- Ahora usa `CatalogsController` directamente
- Carga catálogos con tipo `'menu'`
- Convierte `CatalogItemModel` a `MenuItemModel` para compatibilidad con widgets

#### ward_home_view.dart
- Ahora usa `CatalogsController` directamente
- Carga catálogos con tipo `'wardrobe'`
- Convierte `CatalogItemModel` a `ClothingItemModel` para compatibilidad con widgets

---

## Modelos de Datos

### CatalogModel
```dart
class CatalogModel {
  final String id;
  final String catalogType;  // 'menu', 'wardrobe', 'service'
  final String? name;
  final String? description;
  final String ownerId;
  final String status;
  final String slug;
  final bool isPublic;
  final String? coverImageUrl;
  final int itemCount;
  final int capacity;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? settings;
  final List<String>? tags;
  final List<CatalogItemModel>? items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
}
```

### CatalogItemModel
```dart
class CatalogItemModel {
  final String id;
  final String catalogId;
  final String name;
  final String? description;
  final String? photoURL;
  final double price;
  final double? discountPrice;
  final int quantity;
  final String? sku;
  final String status;
  final bool isAvailable;
  final bool isFeatured;
  final Map<String, dynamic>? attributes;
  final List<String>? additionalImages;
  final String? category;
  final List<String>? tags;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## Uso del Nuevo Sistema

### Cargar catálogos por tipo
```dart
// Cargar menús
final menuCatalogs = await GetMyCatalogsUseCase().execute(type: 'menu');

// Cargar guardarropas
final wardrobeCatalogs = await GetMyCatalogsUseCase().execute(type: 'wardrobe');

// Cargar servicios
final serviceCatalogs = await GetMyCatalogsUseCase().execute(type: 'service');
```

### Crear catálogo
```dart
final newCatalog = await CreateCatalogUseCase().execute(
  CreateCatalogParams(
    catalogType: 'menu',
    description: 'Mi Menú Principal',
  ),
);
```

### Crear item en catálogo
```dart
final newItem = await CreateCatalogItemUseCase().execute(
  CreateCatalogItemParams(
    catalogId: 'catalog-id',
    name: 'Nuevo Producto',
    price: 25.99,
    description: 'Descripción del producto',
    tags: ['tag1', 'tag2'],
    quantity: 10,
  ),
);
```

### Actualizar item
```dart
final updatedItem = await UpdateCatalogItemUseCase().execute(
  UpdateCatalogItemParams(
    catalogId: 'catalog-id',
    itemId: 'item-id',
    name: 'Nuevo nombre',
    price: 29.99,
  ),
);
```

### Eliminar item
```dart
await DeleteCatalogItemUseCase().execute(
  catalogId: 'catalog-id',
  itemId: 'item-id',
);
```

---

## Errores Comunes y Soluciones

### 1. "The getter 'items' isn't defined"
**Problema**: El modelo anterior usaba `.items` y el nuevo usa `.items` pero en el widget builder hay unwrapping.
**Solución**: Usar `.value` para acceder al valor del Rx: `selected?.items ?? []`

### 2. "CatalogModel? noAssignable"
**Solución**: Provide un valor por defecto o verificar null antes de pasar:
```dart
selectedItem: selected ?? catalogs.first
```

### 3. Tipos no compatibles en widgets legacy
**Problema**: Los widgets antiguos esperan `MenuModel` o `WardrobeModel`.
**Solución**: Crear métodos de conversión:
```dart
MenuItemModel _convertCatalogItemToMenuItem(CatalogItemModel item) {
  return MenuItemModel(
    id: item.id,
    name: item.name,
    photoUrl: item.photoURL,
    price: item.price,
    ingredients: item.tags,
  );
}
```

---

## Pendiente / Work in Progress

✅ **COMPLETADO** - Abril 2026

Todas las tareas de migración han sido completadas:

1. ✅ **Controladores de menú/wardrobe** - Migrados a usar `CatalogsController`
2. ✅ **Páginas de creación** - Migradas a usar el nuevo sistema:
   - `create_menu_page.dart`
   - `create_ward_page.dart`
   - `create_item_page.dart`
   - `create_ward_item_page.dart`
3. ✅ **Rutas** - Actualizadas `pages.dart` para usar `CatalogsBinding` en lugar de `MenuBinding` y `WardrobesBinding`
4. ✅ **Vistas del Home** - `menu_home_view.dart` y `ward_home_view.dart` migradas a `CatalogModel`

---

## Estado Final de Archivos

---

## Rollback Plan

Si hay problemas críticos, se puede revertir parcialmente:

1. Mantener los métodos deprecated activos en `DinningController`
2. Los getters de retrocompatibilidad (`wardList`, `menusList`, etc.) aún funcionan
3. Las vistas pueden usar los getters legacy mientras se corrigen los issues

---

## Links Relacionados

- [Estado de Migración](./MIGRATION_STATUS.md)
- [Modelo de Catalog](menu_dart_api/lib/by_feature/catalog/models/catalog_model.dart)
- [Casos de Uso de Catalog](menu_dart_api/lib/by_feature/catalog/data/usecase/)

---

*Documento generado automáticamente - Abril 2026*