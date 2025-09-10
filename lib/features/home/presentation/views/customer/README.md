# CustomerHomeView - Atomic Design Structure

## 📋 Descripción

Vista específica para usuarios con rol **customer** implementada siguiendo los principios de **Atomic Design** para garantizar máxima reutilización, mantenibilidad y escalabilidad.

## 🏗️ Estructura de Atomic Design

```
customer/
├── atoms/                     # Componentes básicos e indivisibles
│   └── customer_atoms.dart    # CustomerAvatar, CustomerTitle, CustomerIcon, etc.
├── molecules/                 # Combinaciones de átomos
│   └── customer_molecules.dart # CustomerInfoTile, CommerceCard, etc.
├── organisms/                 # Combinaciones de moléculas
│   └── customer_organisms.dart # CustomerFeaturedCommerces, CustomerServiceInfo, etc.
├── templates/                 # Layouts y estructuras de página
│   └── customer_templates.dart # CustomerMobileTemplate, CustomerDesktopTemplate
└── customer.dart             # Barrel file para facilitar importaciones
```

## 🧩 Componentes por Nivel

### Átomos (atoms/)
- `CustomerAvatar`: Avatar circular con icono
- `CustomerTitle`: Texto de título principal
- `CustomerSubtitle`: Texto de subtítulo
- `CustomerSectionTitle`: Título de sección
- `CustomerIcon`: Icono con color primario
- `CustomerContainer`: Contenedor base con estilos

### Moléculas (molecules/)
- `CustomerInfoTile`: Tile de información con icono y texto
- `CommerceCard`: Card para mostrar comercios registrados
- `CustomerWelcomeHeader`: Header de bienvenida con avatar y saludo
- `CustomerNotification`: Componente de notificación simple

### Organismos (organisms/)
- `CustomerFeaturedCommerces`: Sección de comercios registrados (con mock data)
- `CustomerServiceInfo`: Sección de información del servicio
- `CustomerSidePanel`: Panel lateral con notificaciones y estadísticas

### Templates (templates/)
- `CustomerMobileTemplate`: Layout optimizado para móviles
- `CustomerDesktopTemplate`: Layout de dos columnas para desktop

## 🚀 Mejoras de Scroll y Altura Implementadas

### ✅ Optimizaciones Recientes (v2.0)

#### **Layout Móvil Mejorado:**
- **Header fijo**: El header de bienvenida permanece visible
- **Scroll dual**: 
  - Scroll principal para toda la página
  - Scroll independiente en la sección de comercios (altura fija de 400px)
- **Mejor distribución**: Evita overflow de altura en pantallas pequeñas

#### **Layout Desktop Optimizado:**
- **Columna principal**: Grid de comercios con scroll independiente
- **Panel lateral**: Scroll separado para notificaciones e información
- **Sin restricciones de altura**: Utiliza todo el espacio disponible

#### **Grid de Comercios Mejorado:**
- **12 comercios mock**: Suficientes elementos para demostrar scroll
- **Aspect ratio optimizado**: 
  - Móvil: 4.0 (más horizontal, mejor legibilidad)
  - Desktop: 1.3 (más compacto, mejor aprovechamiento del espacio)
- **Cards rediseñadas**: Layout con `Expanded` para mejor distribución del contenido
- **Contador visual**: Badge que muestra el total de comercios registrados

#### **CommerceCard Rediseñada:**
- **Imagen flexible**: Usa `Expanded(flex: 3)` para adaptarse al tamaño disponible
- **Información optimizada**: `Expanded(flex: 2)` para texto y metadata
- **Mejor legibilidad**: Iconos más pequeños (14px) y texto ajustado
- **Layout responsivo**: Se adapta automáticamente a diferentes tamaños

### 🔧 Estructura de Scroll

```
CustomerMobileTemplate
├── CustomerWelcomeHeader (fijo)
└── Expanded
    └── SingleChildScrollView (scroll principal)
        ├── SizedBox(height: 400) (scroll independiente)
        │   └── CustomerFeaturedCommerces
        │       └── GridView (con scroll)
        └── CustomerServiceInfo

CustomerDesktopTemplate  
├── CustomerWelcomeHeader (fijo)
└── Expanded
    └── Row
        ├── CustomerFeaturedCommerces (scroll independiente)
        └── SingleChildScrollView (panel lateral)
```

## 🎯 Características Principales

### ✅ Eliminación de Dependencias del Controlador
- **Antes**: Componentes dependían directamente del `DinningController`
- **Ahora**: Solo la vista principal obtiene datos del controlador y los pasa como parámetros

### ✅ Mock Data para Comercios
- Reemplazó las "acciones rápidas" por una sección de comercios registrados
- 6 comercios de ejemplo con diferentes categorías
- Datos mockeados listos para conectar con API real

### ✅ Diseño Responsivo
- Layout específico para móvil (single column)
- Layout específico para desktop (two columns + sidebar)
- Adaptación automática de espaciados y tamaños

### ✅ Reutilización de Componentes
- Cada componente es independiente y reutilizable
- Props claramente definidas
- Separación de responsabilidades

## 🔧 Uso

```dart
// Importar solo lo necesario
import 'customer/templates/customer_templates.dart';

// O importar todo el conjunto
import 'customer/customer.dart';

// Uso en la vista
CustomerMobileTemplate(userName: userName)
CustomerDesktopTemplate(userName: userName)
```

## 🚀 Próximos Pasos

1. **Conectar API real** de comercios (reemplazar mock data)
2. **Implementar navegación** en las cards de comercios
3. **Agregar filtros** de búsqueda y categorías
4. **Conectar notificaciones** reales del usuario
5. **Implementar favoritos** de comercios

## 🎨 Lineamientos Seguidos

- ✅ **Atomic Design**: Estructura modular y escalable
- ✅ **Widgets sin estado**: Todos los componentes son `StatelessWidget`
- ✅ **No funciones que retornen widgets**: Solo clases de widget
- ✅ **Separación de responsabilidades**: Cada componente tiene una única responsabilidad
- ✅ **Const y final**: Uso optimizado de constructores const
- ✅ **Documentación**: Comentarios en todos los componentes públicos
- ✅ **Design System**: Uso consistente de `PUColors` y `PuTextStyle`
