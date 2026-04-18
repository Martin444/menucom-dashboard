---
name: widget-composition-strict
description: "Reglas estrictas de composición de widgets: Atomic Design con pu_material como único export."
triggers:
  - "crear widget"
  - "crear widgets"
  - "componer widgets"
  - "composición de widgets"
  - "atomic design"
  - "widget composition"
  - "molecule"
  - "molécula"
  - "organism"
  - "organismo"
  - "template"
  - "page"
  - "átomo"
  - "atomo"
  - "pu_material"
  - "organizar widgets"
  - "jerarquía de widgets"
---

# widget-composition-strict

Esta skill establece las reglas de composición de widgets para el proyecto Flutter Menucom Dashboard.

## Reglas de Composición (OBLIGATORIAS)

### 1. Módulo Único de Exportación

**Todos los widgets reutilizables DEBEN ser exportados desde un único archivo:**
```dart
// ÚNICO punto de exportación
export 'package:pu_material/pu_material.dart';
```

Todo widget (átomo, molécula, organismo) debe estar registrado en `pu_material/lib/pu_material.dart`. Queda prohibido importar directamente sub-archivos del paquete.

### 2. Jerarquía Atómica Estricta

La composición DEBE seguir esta jerarquía exacta:

```
Page (View)
  └── Template (Layout)
        └── Organismo
              └── Molécula
                    └── Átomo
```

**Cada nivel tiene restricciones:**
- **Page:** Solo contiene Templates. NO usa átomos/moléculas directamente.
- **Template:** Solo contiene Organismos. NO usa átomos/moléculas directamente.
- **Organismo:** Usa Moléculas y Átomos.
- **Molécula:** Usa solo Átomos.
- **Átomo:** Elementos indivisibles (no usa otros widgets).

### 3. Regla de Importación Inversa Prohibida

- **Átomo:** Puede vivir en `pu_material` o en la feature.
- **Molécula:** Puede vivir en `pu_material` o en la feature.
- **Organismo:** Puede vivir en `pu_material` o en la feature.
- **Template:** Solo en la feature.
- **Page:** Solo en la feature.

**Regla clave:** Un nivel inferior NUNCA puede importar de un nivel superior.

### 4. Integración con ui-ux-pro-max

**ANTES de crear cualquier widget, consulta la skill ui-ux-pro-max:**

```bash
python3 .agent/skills/ui-ux-pro-max/scripts/search.py "<descripción del widget>" --design-system -p "Menucom Dashboard"
```

Esto asegura que el diseño cumpla con:
- Guía de estilos recomendada
- Paletas de color apropiadas
- Tipografía correcta
- Patrones UX validados
- Efectos y animaciones apropiados

## Ejemplo de Composición Correcta

```dart
// Page: página completa
class MiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MiTemplate(); // ✅ Solo usa Templates
  }
}

// Template: organiza organismos
class MiTemplate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HeaderOrganismo(), // ✅ Solo usa Organismos
        ContentOrganismo(),
      ],
    );
  }
}

// Organismo: combina moléculas
class HeaderOrganismo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TituloMolecula(), // ✅ Usa Moléculas
        AccionMolecula(),
      ],
    );
  }
}

// Molécula: combina átomos
class TituloMolecula extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconoAtomo(), // ✅ Usa Átomos
        TextoAtomo(),
      ],
    );
  }
}

// Átomo: elemento base
class TextoAtomo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('hola'); // ✅ Sin otros widgets
  }
}
```

## Workflow para Crear Widgets

1. **Analizar nivel atómico** - Determinar si es átomo, molécula, organismo, template o page.
2. **Consultar ui-ux-pro-max** - Obtener guía de diseño antes de implementar.
3. **Crear en ubicación correcta:**
   - Átomo/Molécula/Organismo genérico → `pu_material/lib/widgets/`
   - Átomo/Molécula/Organismo específico → Feature `lib/widgets/`
   - Template/Page → Feature `lib/presentation/views/`
4. **Exportar desde pu_material.dart** - Registrar el widget en el archivo de export.
5. **Verificar composición** -确保 no hay violaciones de jerarquía.

## Validación de Arquitectura

Al crear o modificar widgets, verifica:
- [ ] ¿El widget está en el nivel correcto de la jerarquía?
- [ ] ¿Los hijos son del nivel inmediatamente inferior?
- [ ] ¿Está exportado desde pu_material.dart si es genérico?
- [ ] ¿Se consultó ui-ux-pro-max para el diseño?