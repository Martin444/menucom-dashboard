---
name: flutter-responsive-design
description: Crear interfaces Flutter responsivas que se adapten a cualquier tamaño de pantalla. Usa esta skill cuando el usuario necesite: layouts que respondan a diferentes tamaños de pantalla, evitar overflows en pantallas pequeñas, implementar Mobile/ Tablet/ Desktop con breakpoints específicos, sustituir Row por soluciones más flexibles, o usar medidas relativas en lugar de valores hardcodeados.
---

# Flutter Responsive Design

Crea interfaces Flutter que se adaptan fluidamente a cualquier tamaño de pantalla usando MediaQuery, LayoutBuilder y breakpoints estratégicos.

## Breakpoints Estrictos

| Dispositivo | Ancho | Comportamiento |
|------------|------|---------------|
| Mobile | < 600px | Diseño apilado, navegación inferior o cajón |
| Tablet | 600-1024px | Grillas moderadas, menús laterales colapsables |
| Desktop | > 1024px | Multicolumna, menús expandidos |

```dart
enum DeviceType { mobile, tablet, desktop }

DeviceType getDeviceType(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return DeviceType.mobile;
  if (width < 1024) return DeviceType.tablet;
  return DeviceType.desktop;
}
```

## 1. Adaptabilidad Nativa

### LayoutBuilder para Componentes Aislados

Usa `LayoutBuilder` cuando necesites que un componente responda a su contenedor padre, no a la pantalla completa:

```dart
Widget responsiveCard(BuildContext context, Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 200;
      return Container(
        padding: EdgeInsets.all(isCompact ? 8 : 16),
        child: child,
      );
    },
  );
}
```

### MediaQuery para Layout General

Usa `MediaQuery` para decisiones de layout a nivel de pantalla:

```dart
Widget getScaffoldLayout(BuildContext context) {
  final deviceType = getDeviceType(context);
  
  switch (deviceType) {
    case DeviceType.mobile:
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(...),
      );
    case DeviceType.tablet:
      return Scaffold(
        drawer: NavigationDrawer(...),
      );
    case DeviceType.desktop:
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(...),
            Expanded(child: Content()),
          ],
        ),
      );
  }
}
```

## 2. Flexibilidad Geométrica

### Sustituir Row por Flex

`Flex` permite cambiar la dirección dinámicamente:

```dart
Widget responsiveFlex({
  required List<Widget> children,
  required BuildContext context,
}) {
  final isMobile = MediaQuery.of(context).size.width < 600;
  
  return Flex(
    direction: isMobile ? Axis.vertical : Axis.horizontal,
    children: children,
  );
}
```

### Uso de Wrap para Contenido Flexible

Para chips, etiquetas, botones o tarjetas pequeñas:

```dart
Widget chipList = Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    Chip(label: Text('Chip 1')),
    Chip(label: Text('Chip 2')),
    Chip(label: Text('Chip 3')),
  ],
);
```

### Expanded y Flexible

Usa solo cuando mantengas un eje fijo:

```dart
// Row fijo → usar Flexible
Row(
  children: [
    Flexible(flex: 1, child: Sidebar()),
    Expanded(flex: 3, child: Content()),
  ],
)

// Columna fija → usar Flexible
Column(
  children: [
    Flexible(flex: 2, child: MainContent()),
    Flexible(flex: 1, child: Footer()),
  ],
)
```

## 3. Escalado Relativo

### Factor Multiplicador

Calcula tamaños basados en el ancho de pantalla:

```dart
double scaleWidth(BuildContext context, double baseWidth) {
  final screenWidth = MediaQuery.of(context).size.width;
  const designWidth = 375; // Ancho de diseño base (ej. Figma)
  return baseWidth * (screenWidth / designWidth);
}

double responsivePadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return 12.0;
  if (width < 1024) return 16.0;
  return 24.0;
}
```

### Text Scaler para Fuentes

Usa el TextScaler integrado de Flutter:

```dart
// En lugar de hardcodear fontSize
Text(
  'Título',
  style: TextStyle(
    fontSize: MediaQuery.textScalerOf(context).scale(16),
  ),
)

// O usa un factor relativo
double fontScale(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width / 400; // Base de diseño 400px
}
```

### Padding/Margin Relativo

```dart
Widget responsiveContainer(BuildContext context, Widget child) {
  final width = MediaQuery.of(context).size.width;
  final padding = width * 0.04; // 4% del ancho
  
  return Padding(
    padding: EdgeInsets.all(padding),
    child: child,
  );
}
```

## 4. Mixin Helper

Crea un mixin reutilizable:

```dart
mixin ResponsiveHelper on StatelessWidget {
  DeviceType get deviceType => getDeviceType(context);
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  
  double scale(double base) {
    final width = MediaQuery.of(context).size.width;
    return base * (width / 375);
  }
  
  EdgeInsets responsivePadding([double factor = 0.04]) {
    return EdgeInsets.all(size.width * factor);
  }
}
```

## Ejemplo Completo

```dart
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(context);
    final width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: deviceType == DeviceType.mobile
          ? AppBar(title: Text('App'))
          : null,
      drawer: deviceType == DeviceType.tablet ? Drawer(...) : null,
      body: deviceType == DeviceType.desktop
          ? Row(
              children: [
                NavigationRail(...),
                Expanded(child: _responsiveGrid(width)),
              ],
            )
          : _responsiveGrid(width),
    );
  }
  
  Widget _responsiveGrid(double width) {
    final crossAxisCount = width < 600 ? 1 : (width < 1024 ? 2 : 3);
    final spacing = width < 600 ? 8.0 : 16.0;
    
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: 10,
      itemBuilder: (context, index) => Card(
        child: ResponsiveCard(
          maxWidth: width / crossAxisCount - spacing,
        ),
      ),
    );
  }
}
```

## Reglas Obligatorias

1. **NUNCA** uses valores hardcodeados como `width: 200` o `fontSize: 16`
2. **SIEMPRE** envolvemos elementos que pueden overflow en `Flexible`, `Expanded`, `Wrap`, o `SingleChildScrollView`
3. **SIEMPRE** definimos breakpoints antes de implementar
4. **PREFERIMOS** LayoutBuilder sobre MediaQuery para componentes reutilizables
5. **PREFERIMOS** Wrap sobre Row cuando el contenido sea variable