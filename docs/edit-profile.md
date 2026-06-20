---
tags:
  - edit-profile
  - controller
  - responsive
  - feedback
aliases:
  - Editar Perfil
  - EditProfileController
  - EditProfilePage
---

# Editar Perfil - Documentación Consolidada

## Lógica del Controlador

### Validación de Cambios

```dart
if (!hasChanges) {
  _showErrorSnackbar('No hay cambios que guardar');
  return;
}
```

### Actualización Segura del DinningController

```dart
void _updateDinningControllerData(Map<String, dynamic>? userData) {
  if (userData != null) {
    _dinningController.dinningLogin.name = userData['name'] ?? nameController.text.trim();
    _dinningController.dinningLogin.email = userData['email'] ?? emailController.text.trim();
    _dinningController.dinningLogin.phone = userData['phone'] ?? phoneController.text.trim();
    if (userData['photoURL'] != null) {
      _dinningController.dinningLogin.photoURL = userData['photoURL'];
    }
  } else {
    _dinningController.dinningLogin.name = nameController.text.trim();
    _dinningController.dinningLogin.email = emailController.text.trim();
    _dinningController.dinningLogin.phone = phoneController.text.trim();
  }
  _dinningController.update();
}
```

### Principio: "Solo si es exitoso, se actualiza"

- Si el API call falla: NO se actualiza el DinningController
- Si el API call es exitoso: SÍ se actualiza el DinningController
- Actualización inmediata: Los cambios se reflejan en toda la app sin recargar

### Flujo de Actualización

1. **Validar formulario** → Si falla, no continúa
2. **Verificar cambios** → Si no hay cambios, no envía nada
3. **Llamar al API** → Envía los datos al backend
4. **Si es exitoso**: Actualiza el DinningController con datos del servidor, limpia imagen seleccionada, cierra pantalla, muestra mensaje de éxito
5. **Si falla**: NO actualiza el DinningController, muestra mensaje de error, mantiene pantalla abierta

### Diagrama de Flujo

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────────┐
│   Edit Profile  │───▶│  Backend API │───▶│ DinningController│
│   Controller    │    │   Update     │    │    Update       │
└─────────────────┘    └──────────────┘    └─────────────────┘
         │                       │                    │
         │              ✅ Success│                    │
         │                       ▼                    ▼
         │              ┌──────────────┐    ┌─────────────────┐
         │              │ Update Local │───▶│  UI Refresh     │
         │              │    Data      │    │  (All App)      │
         │              └──────────────┘    └─────────────────┘
         │
         │              ❌ Error
         ▼                       │
┌─────────────────┐              │
│  Show Error     │◀─────────────┘
│  Keep Original  │
│     Data        │
└─────────────────┘
```

### Componentes que se Actualizan Automáticamente

- Header del Dashboard (nombre del usuario)
- Página de Perfil (todos los datos)
- Menús laterales (información del usuario)
- Cualquier widget que use `Get.find<DinningController>()`

Sin necesidad de recargar la app, hacer logout/login, navegar y volver, o refrescar manualmente.

### Métodos del Controlador

```dart
controller.saveProfile()       // Future<void>
controller.resetForm()         // void
controller.isLoading           // bool
controller.hasChanges          // bool
```

---

## Layout Responsivo

### Mobile (< 768px)

- Layout vertical: Avatar arriba, formulario abajo
- AppBar completa con botón de retroceso, título centrado y botón guardar
- Botones de acción verticales: Guardar arriba, cancelar abajo
- Padding adaptativo de 16px
- Cards separadas para avatar y formulario

```
┌─────────────────┐
│   AppBar        │
├─────────────────┤
│ ┌─────────────┐ │
│ │   Avatar    │ │
│ │   Editor    │ │
│ └─────────────┘ │
│                 │
│ ┌─────────────┐ │
│ │ Formulario  │ │
│ │  Datos      │ │
│ └─────────────┘ │
│                 │
│ [Guardar]       │
│ [Cancelar]      │
└─────────────────┘
```

### Web/Tablet (≥ 768px)

- Layout horizontal: Avatar a la izquierda, formulario a la derecha
- AppBar limpia sin elementos innecesarios para web
- Botones de acción horizontales: Cancelar a la izquierda, guardar a la derecha
- Contenido centrado con ancho máximo de 600-800px
- Padding adaptativo de 24-32px
- Card unificada con avatar y formulario

```
┌─────────────────────────────────┐
│          Título Web             │
│      Ctrl+S, Esc hints         │
├─────────────────────────────────┤
│ ┌─────────┐ ┌─────────────────┐ │
│ │ Avatar  │ │   Formulario    │ │
│ │ Editor  │ │    Datos        │ │
│ │         │ │                 │ │
│ └─────────┘ └─────────────────┘ │
│                                 │
│  [Cancelar]     [Guardar]       │
└─────────────────────────────────┘
```

### Atajos de Teclado (Web)

- `Ctrl + S`: Guardar cambios
- `Esc`: Cancelar/volver
- Indicadores visuales con hints de atajos
- Tooltips informativos en botones de acción
- Manejo del botón de retroceso del navegador

### Breakpoints

```dart
Mobile:    < 768px
Tablet:    768px - 1200px
Desktop:   ≥ 1200px
Web:       ≥ 768px (incluye tablet y desktop)
```

### Componentes (Atomic Design)

```
📁 atoms/
  └── avatar_editor_atom.dart        # Edición de avatar
📁 molecules/
  └── profile_form_molecule.dart     # Formulario de datos
📁 organisms/
  └── profile_editor_organism.dart   # Combinación completa
📁 pages/
  └── edit_profile_page.dart         # Pantalla principal
```

### ResponsiveUtils Helper

```dart
ResponsiveUtils.isMobile(context)
ResponsiveUtils.isTablet(context)
ResponsiveUtils.isDesktop(context)
ResponsiveUtils.isWeb(context)
ResponsiveUtils.getAdaptivePadding(context)
ResponsiveUtils.getMaxContentWidth(context)
ResponsiveUtils.getAdaptiveSpacing(context)
```

### Archivos Modificados

- `edit_profile_page.dart` - Pantalla principal responsiva
- `profile_editor_organism.dart` - Organismo adaptativo
- `responsive_utils.dart` - Helper para responsive design

---

## Sistema de Feedback

### Guardado Exitoso

- Detecta automáticamente qué campos se modificaron
- Mensaje específico según los cambios:
  - `"Se actualizó: nombre"` (un campo)
  - `"Se actualizaron: nombre, email, teléfono"` (múltiples campos)
  - `"Tu perfil ha sido actualizado exitosamente"` (mensaje general)

```dart
✅ Éxito
Se actualizaron: nombre, email, foto de perfil
```

- Snackbar verde con borde
- Ícono de check
- Duración: 3 segundos
- Posición: TOP
- Se muestra DESPUÉS de la navegación (300ms delay)

### Errores de Validación

- **Nombre vacío**: "El nombre es obligatorio"
- **Email vacío**: "El email es obligatorio"
- **Email inválido**: "El formato del email no es válido"
- **Teléfono vacío**: "El teléfono es obligatorio"
- **Errores de API**: "Error al actualizar el perfil: [detalle]"

```dart
❌ Error
El formato del email no es válido
```

- Snackbar rojo con borde
- Ícono de error
- Duración: 4 segundos (más tiempo para errores)
- Posición: TOP

### Estados de Carga

- Botones deshabilitados durante carga: `controller.isLoading ? null : action`
- `CircularProgressIndicator` en botón
- Texto del botón: "Guardando..." durante la carga
- Prevención de doble envío

#### En AppBar (Mobile)

```dart
controller.isLoading
  ? CircularProgressIndicator(strokeWidth: 2)
  : Text('Guardar')
```

### Diseño de Snackbar

```dart
backgroundColor: Colors.green[50],  // Fondo suave
borderColor: Colors.green[300],    // Borde visible
borderWidth: 1,                    // Definición clara
margin: EdgeInsets.all(16),        // Espaciado
borderRadius: 8,                   // Esquinas redondeadas
```

### Flujo Completo

1. Usuario edita campos → Validación en tiempo real
2. Presiona "Guardar" → Botón muestra loading
3. Validación exitosa → API call
4. Datos actualizados → DinningController sincronizado
5. Navegación automática → `Get.back()`
6. Feedback visual → Snackbar específico (300ms delay)

### Archivos Modificados

- `edit_profile_controller.dart` - Feedback y validaciones mejoradas
- `edit_profile_page.dart` - Estados de loading en UI

---

## Referencias Cruzadas

- [[auth-architecture]]
- [[BUSINESS_SELECTION_IMPLEMENTATION]]
