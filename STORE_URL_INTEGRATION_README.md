# Store URL Integration - MenuCom Dashboard

## 📋 Resumen de Cambios

**Fecha:** 2025-09-12  
**Funcionalidad:** Integración de redirección a tienda desde BusinessCardMolecule

## 🎯 Objetivo

Implementar la funcionalidad de redirección a tiendas directamente desde las tarjetas de negocio (BusinessCard) utilizando el nuevo campo `storeURL` devuelto por la API de usuarios por roles.

## 🔧 Cambios Implementados

### 1. Modelo de Datos - UserByRoleModel

**Archivo:** `menu_dart_api/lib/by_feature/user/get_users_by_roles/model/user_by_role_model.dart`

**Cambios:**
- ✅ Agregado campo `storeURL` de tipo `String?`
- ✅ Actualizado constructor para incluir `storeURL`
- ✅ Actualizado `fromJson()` para parsear `storeURL` del JSON
- ✅ Actualizado `toJson()` para incluir `storeURL` en la serialización

```dart
class UserByRoleModel {
  // ... otros campos
  final String? storeURL;  // ✅ Nuevo campo

  const UserByRoleModel({
    // ... otros parámetros
    this.storeURL,  // ✅ Nuevo parámetro
    // ...
  });
}
```

### 2. Componente UI - BusinessCardMolecule

**Archivo:** `pu_material/lib/molecule/business_card_molecule.dart`

**Cambios:**
- ✅ Agregado parámetro `storeURL` de tipo `String?`
- ✅ Agregado callback `onStoreUrlTap` de tipo `VoidCallback?`
- ✅ Implementación automática de botón "Ir a Tienda" cuando `storeURL` está disponible
- ✅ Seguimiento de lineamientos arquitectónicos: no funciones que retornen widgets

```dart
class BusinessCardMolecule extends StatelessWidget {
  // ... otros parámetros
  final String? storeURL;              // ✅ Nuevo parámetro
  final VoidCallback? onStoreUrlTap;   // ✅ Callback personalizable

  @override
  Widget build(BuildContext context) {
    // Crear lista de acciones incluyendo botón de tienda automático
    final allActions = <BusinessCardAction>[
      ...actions,
      if (storeURL != null && storeURL!.isNotEmpty)  // ✅ Generación automática
        BusinessCardAction(
          label: 'Ir a Tienda',
          icon: FluentIcons.store_microsoft_20_regular,
          onPressed: onStoreUrlTap ?? () => _openStoreURL(storeURL!),
          backgroundColor: PUColors.primaryColor,
        ),
    ];
    // ...
  }
}
```

## 📊 Estructura del JSON API

### Respuesta de getUsersByRoles - ANTES:
```json
{
  "id": "38a82c85-9abe-4814-92e7-ca1b9ba7f570",
  "photoURL": "https://...",
  "name": "Comedor Martina",
  "email": "Username@username.com",
  "phone": "387341330",
  "role": "dinning",
  // ... otros campos
  "menus": [...]
}
```

### Respuesta de getUsersByRoles - DESPUÉS:
```json
{
  "id": "38a82c85-9abe-4814-92e7-ca1b9ba7f570",
  "photoURL": "https://...",
  "name": "Comedor Martina",
  "email": "Username@username.com",
  "phone": "387341330",
  "role": "dinning",
  "storeURL": "https://menu-comerce.netlify.app/38a82c85-9abe-4814-92e7-ca1b9ba7f570", // ✅ NUEVO
  // ... otros campos
  "menus": [...]
}
```

## 🔄 Flujo de Integración

1. **API Response** → UserByRoleModel incluye `storeURL`
2. **Data Parsing** → `fromJson()` extrae `storeURL` del JSON
3. **UI Creation** → BusinessCardMolecule recibe `storeURL`
4. **Auto Button** → Se genera automáticamente botón "Ir a Tienda"
5. **User Interaction** → Usuario toca botón
6. **URL Opening** → Se ejecuta `onStoreUrlTap` o fallback

## 💻 Ejemplos de Uso

### Uso Básico - Automático
```dart
BusinessCardMolecule(
  name: 'Comedor Martina',
  category: 'Restaurante',
  imageUrl: 'https://...',
  storeURL: 'https://menu-comerce.netlify.app/38a82c85...', // ✅ Botón automático
)
```

### Uso Avanzado - Con Callback Personalizado
```dart
BusinessCardMolecule(
  name: 'Comedor Martina',
  category: 'Restaurante',
  imageUrl: 'https://...',
  storeURL: 'https://menu-comerce.netlify.app/38a82c85...',
  onStoreUrlTap: () async {
    // Implementación personalizada con url_launcher
    final uri = Uri.parse(storeURL);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  },
)
```

### Desde UserByRoleModel
```dart
// Crear BusinessCard desde modelo de API
final businessCard = BusinessCardFromUserModel.fromUserByRoleModel(
  userModel,
  onStoreUrlTap: () => _openStoreURL(userModel.storeURL!),
);
```

## 🏗️ Conformidad Arquitectónica

✅ **Lineamientos Seguidos:**
- ❌ No funciones que retornen widgets → Todos los widgets son clases dedicadas
- ✅ Atomic Design → Estructura mantiene separación átomo/molécula/organismo
- ✅ Separación de responsabilidades → UI separada de lógica de negocio
- ✅ Inmutabilidad → Uso de `const` y `final`
- ✅ Callback pattern → `onStoreUrlTap` permite implementación externa

## 📁 Archivos Modificados

1. **`menu_dart_api/.../user_by_role_model.dart`** - Modelo de datos
2. **`pu_material/.../business_card_molecule.dart`** - Componente UI
3. **`testsprite_tests/tmp/code_summary.json`** - Documentación del proyecto
4. **`STORE_URL_INTEGRATION_EXAMPLE.dart`** - Ejemplos de implementación (nuevo)

## 🧪 Testing

### Casos de Prueba Sugeridos:
1. ✅ BusinessCard con `storeURL` → Debe mostrar botón "Ir a Tienda"
2. ✅ BusinessCard sin `storeURL` → No debe mostrar botón de tienda
3. ✅ Callback personalizado → Debe ejecutar `onStoreUrlTap` cuando se proporciona
4. ✅ Fallback → Debe usar `_openStoreURL` cuando no hay callback personalizado
5. ✅ UserByRoleModel parsing → Debe parsear correctamente `storeURL` del JSON

## 🚀 Próximos Pasos

1. **Implementar url_launcher** en pubspec.yaml si no está disponible
2. **Testing** de la funcionalidad completa
3. **Documentación** adicional para el equipo
4. **Optimizaciones** de rendimiento si es necesario

## 📝 Notas de Desarrollo

- El componente mantiene compatibilidad hacia atrás
- La funcionalidad es opt-in (solo se activa si `storeURL` está presente)
- Se puede personalizar completamente el comportamiento con `onStoreUrlTap`
- Seguimiento estricto de lineamientos arquitectónicos del proyecto