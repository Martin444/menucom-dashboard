---
name: atomic-design-strict
description: "Estrictas reglas de diseño atómico para Flutter: cero funciones que retornen Widgets, un archivo único por clase, y jerarquía atómica obligatoria."
---

# atomic-design-strict

Esta skill impone directrices arquitectónicas rigurosas basadas en *Atomic Design* para proyectos Flutter. **Lee esto antes de escribir código UI.**

---

## 🚨 Reglas de Oro (Obligatorio Cumplir)

| # | Regla | Violación Común |
|---|-------|-----------------|
| 1 | **Cero funciones que retornen Widget** | `Widget _buildHeader() => ...` |
| 2 | **Un archivo por clase** | Múltiples `class` en un .dart |
| 3 | **Jerarquía atómica obligatoria** | Mezclar niveles (átomo en páginas) |

---

## 1. Cero Funciones que Retornen Widgets

### Por qué importa
- Flutter no puede optimizar widgets creados en funciones
- Rompe el árbol de renderizado y causa re-renderizados innecesarios
- Dificulta testing unitario

### ❌ MALO (Violaciones)
```dart
// Violación 1: Función privada que retorna Widget
Widget _buildHeader() {
  return Container(
    child: Text('Hola'),
  );
}

// Violación 2: Builder en línea dentro del build
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(), // ← Violación
      _buildBody(),  // ← Violación
    ],
  );
}

// Violación 3: Función con parámetros que retorna Widget
Widget _buildCard(String title, Color color) {
  return Card(
    color: color,
    child: Text(title),
  );
}
```

### ✅ BUENO (Correcto)
```dart
// Correcto: Clase dedicada para cada componente
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hola'),
    );
  }
}

// Uso en el build:
Widget build(BuildContext context) {
  return Column(
    children: [
      const HeaderWidget(), // ← Correcto
      const BodyWidget(),
    ],
  );
}
```

### Excepciones permitidas
- `builder` en `FutureBuilder`, `StreamBuilder`, `LayoutBuilder`
- `itemBuilder` en `ListView.builder`
- Funciones helper que retornan **datos** (no Widgets): `String _formatDate()`, `Color _getColor()`

---

## 2. Un Archivo por Clase

### Por qué importa
- Single Responsibility Principle
- Facilita búsqueda y mantenimiento
- Permite imports selectivos

### ❌ MALO
```dart
// main_dialog.dart - ¡No hacer esto!
class OkButton extends StatelessWidget { ... }
class CancelButton extends StatelessWidget { ... }
class DialogHeader extends StatelessWidget { ... }
```

### ✅ BUENO
```
lib/
├── widgets/
│   ├── ok_button.dart
│   ├── cancel_button.dart
│   └── dialog_header.dart
```

---

## 3. Escalafón Atómico Estricto

### Estructura de Carpetas
```
lib/
├── features/
│   └── [feature]/
│       └── presentation/
│           ├── atoms/         # Elementos indivisibles
│           ├── molecules/      # Grupos de átomos
│           ├── organisms/     # Secciones complejas
│           └── pages/         # Vistas completas
├── widgets/                   # Componentes compartidos
│   ├── atoms/
│   ├── molecules/
│   └── organisms/
└── pu_material/              # Librería de UI
```

### Niveles Definidos

| Nivel | Definición | Ejemplos | ¿Tiene estado? |
|-------|------------|----------|----------------|
| **Átomo** | Elemento indivisible | `Text`, `Button`, `Input`, `Icon` | No ( StatelessWidget) |
| **Molécula** | Grupo de átomos relacionados | `SearchField`, `ChipGroup`, `FormField` | Puede tener estado interno mínimo |
| **Organismo** | Sección independiente compleja | `Header`, `Sidebar`, `DataTable`, `CardWithActions` | Sí (StatefulWidget) |
| **Página** | Vista completa con rutas | `HomePage`, `SettingsPage` | Sí, con Controller |

### Ubicación Correcta
- **Átomos/Moléculas genéricos** → `pu_material/`
- **Componentes de feature** → `features/[name]/presentation/[level]/`
- **Widgets reutilizables** → `lib/widgets/`

---

## 4. Aislamiento de UI (pu_material)

Todo componente visual reusable debe vivir en `pu_material/`:

```dart
// ✅ En tu feature
import 'package:pu_material/pu_material.dart';

// ❌ NO hacer esto en tu feature
import '../widgets/my_custom_button.dart'; // Ya está en pu_material
```

---

## ✅ Checklist de Auto-Verificación

Antes de commitear, verifica:

```
□ No hay funciones _buildX() que retornen Widget
□ Cada clase tiene su propio archivo
□ El archivo está en la carpeta correcta (atoms/molecules/organisms)
□ Los átomos no dependen de organismos o páginas
□ Los componentes reusable están en pu_material/
```

---

## 🔍 Comandos de Detección

Ejecuta esto para encontrar violaciones:

```powershell
# Buscar funciones que retornan Widget
Get-ChildItem -Path lib -Recurse -Include *.dart | Select-String -Pattern "Widget _build|Widget build[A-Z]"

# Buscar múltiples clases en un archivo
Get-ChildItem -Path lib -Recurse -Include *.dart | ForEach-Object { 
    $count = (Select-String -Path $_.FullName -Pattern "^class " -AllMatches).Matches.Count
    if ($count -gt 1) { Write-Host "$($_.FullName): $count classes" }
}
```

---

## 📖 Anti-Patrones Comunes

| Anti-Patrón | Problema | Solución |
|-------------|----------|----------|
| `_buildTitle()` | Función retornando Widget | Crear `TitleWidget` |
| `_Section()` | Método en build() | Extraer a clase |
| `List<Widget> items = []` | Lista de widgets en variable | Usar `ListView.builder` |
| Clase en medio de otra clase | Multi-clase en archivo | Separar a archivo propio |
| Lógica de negocio en Widget | Acoplamiento | Mover a Controller |

---

## 🎯 Ejemplo Completo: Refactorización

### Antes (Violación)
```dart
class MyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          _buildHeader(), // ❌ Violación
          _buildContent(), // ❌ Violación
          _buildActions(), // ❌ Violación
        ],
      ),
    );
  }

  Widget _buildHeader() => Text('Título');
  Widget _buildContent() => Text('Contenido');
  Widget _buildActions() => Row(children: [...]);
}
```

### Después (Correcto)
```
lib/features/example/presentation/
├── atoms/
│   └── title_text.dart
├── molecules/
│   └── dialog_header.dart
│   └── dialog_actions.dart
├── organisms/
│   └── my_dialog_content.dart
└── pages/
    └── my_dialog.dart
```
