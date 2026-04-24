# Menucom API Generator

Genera nuevos endpoints para menu_dart_api siguiendo el patrón Clean Architecture del proyecto.

## Estructura del patrón

```
menu_dart_api/lib/by_feature/{feature}/
├── models/
│   └── {feature}_xxx_model.dart
├── data/
│   ├── provider/
│   │   └── {feature}_provider.dart
│   ├── repository/
│   │   └── {feature}_repository.dart
│   └── usecase/
│       └── xxx_usecase.dart
```

Y exports en `menu_com_api.dart`.

## Reglas

1. **Model**: `class {Feature}XxxModel` con `fromJson()` y `toJson()`
2. **Provider**: extiende `{Feature}Repository`, implementa métodos HTTP con Dio usando `API.defaulBaseUrl`
3. **Repository**: define métodos abstractos
4. **UseCase**: clase con `_repository`, método `call()`
5. **Exportar en menu_com_api.dart** todos los archivos públicos
6. **Seguir naming conventions**: camelCase para archivos, PascalCase para clases, snake_case para constantes

## Como generar

Para crear un nuevo endpoint:
1. Crear modelo en `models/` si no existe
2. Agregar método en provider siguiendo patrón existente
3. Definir método abstracto en repository
4. Crear use case en `usecase/`
5. Agregar export en `menu_com_api.dart`

## Activadores

- "agregar endpoint"
- "nueva función api"
- "crear endpoint"
- "generar api"
- "menucom api"