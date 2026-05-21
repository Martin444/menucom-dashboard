# Code Review: Events Feature Flow

## 📋 Resumen General

El flujo de eventos implementa una arquitectura limpia (Clean Architecture) con separación de responsabilidades bien definida. El módulo gestiona:

- **Eventos**: Creación, edición, listado y eliminación de eventos
- **Venues/Lugares**: Gestión de ubicaciones para eventos
- **Tipos de Tickets**: Configuración de precios, cantidades y disponibilidad
- **Tickets/Ventas**: Compra, validación y gestión de entradas

---

## 📁 Estructura del Proyecto

```
lib/by_feature/events/
├── events.dart                          # Barrel export (49 líneas)
├── models/                              # 14 modelos
│   ├── event_model.dart
│   ├── venue_model.dart
│   ├── ticket_type_model.dart
│   ├── ticket_model.dart
│   ├── create_event_params.dart
│   ├── update_event_params.dart
│   ├── create_venue_params.dart
│   ├── create_ticket_type_params.dart
│   ├── update_ticket_type_params.dart
│   ├── purchase_ticket_params.dart
│   ├── checkout_params.dart
│   ├── validate_ticket_params.dart
│   ├── validate_offline_params.dart
│   └── check_ticket_params.dart
├── data/
│   ├── repository/                      # 4 interfaces abstractas
│   │   ├── event_repository.dart
│   │   ├── venue_repository.dart
│   │   ├── ticket_type_repository.dart
│   │   └── ticket_repository.dart
│   ├── provider/                        # 4 providers (HTTP implementations)
│   │   ├── event_provider.dart
│   │   ├── venue_provider.dart
│   │   ├── ticket_type_provider.dart
│   │   └── ticket_provider.dart
│   └── usecase/                         # 22 use cases
│       ├── create_event_usecase.dart
│       ├── list_events_usecase.dart
│       ├── get_event_by_id_usecase.dart
│       ├── update_event_usecase.dart
│       ├── delete_event_usecase.dart
│       ├── create_venue_usecase.dart
│       ├── list_venues_usecase.dart
│       ├── get_venue_by_id_usecase.dart
│       ├── delete_venue_usecase.dart
│       ├── create_ticket_type_usecase.dart
│       ├── list_ticket_types_by_event_usecase.dart
│       ├── update_ticket_type_usecase.dart
│       ├── delete_ticket_type_usecase.dart
│       ├── purchase_ticket_usecase.dart
│       ├── create_checkout_preference_usecase.dart
│       ├── download_ticket_pdf_usecase.dart
│       ├── validate_qr_code_usecase.dart
│       ├── validate_ticket_usecase.dart
│       ├── validate_offline_token_usecase.dart
│       ├── get_ticket_qr_data_usecase.dart
│       ├── regenerate_qr_code_usecase.dart
│       └── check_ticket_status_usecase.dart
```

---

## ✅ Puntos Positivos

### 1. Arquitectura Limpia Bien Implementada
- ✅ Separación clara entre Repository (interfaces), Provider (implementación HTTP) y UseCase (lógica de negocio)
- ✅ Cada capa tiene responsabilidades únicas y bien definidas
- ✅ Fácil de testear y mantener

### 2. Barrel Export Completo
- ✅ El archivo `events.dart` exporta todo lo necesario para usar el módulo
- ✅ Facilita los imports en el resto de la aplicación

### 3. Modelos Bien Estructurados
- ✅ Todos los modelos tienen `fromJson` y `toJson`
- ✅ Uso de tipos nullable (`?`) para campos opcionales
- ✅ Manejo seguro de parseo de fechas con `DateTime.tryParse`
- ✅ Uso de `removeWhere` para limpiar nulos en `toJson`

### 4. Manejo de Errores Consistente
- ✅ Uso de `ApiException` para errores HTTP
- ✅ Try-catch en todos los métodos de provider
- ✅ Rethrow de `ApiException` para no perder información del error

### 5. Inmutabilidad en Modelos
- ✅ Todos los campos son `final`
- ✅ No hay setters, solo constructores

### 6. Uso Correcto de HTTP Methods
- ✅ POST para crear recursos
- ✅ GET para obtener datos
- ✅ PUT para actualizar
- ✅ DELETE para eliminar

---

## ⚠️ Problemas Identificados

### 1. CRÍTICO: Hardcoded Dependencies en UseCases

**Problema**: Los UseCases instancian directamente los Providers:

```dart
class CreateEventUseCase {
  final EventProvider _provider = EventProvider();  // ❌ Hardcoded
  
  Future<EventModel> execute(CreateEventParams params) async {
    return await _provider.create(params);
  }
}
```

**Impacto**:
- Imposible hacer mocking para tests unitarios
- Violación del Principio de Inversión de Dependencias (DIP)
- Acoplamiento fuerte entre capas

**Solución**: Usar inyección de dependencias via constructor:

```dart
class CreateEventUseCase {
  final EventRepository _repository;  // ✅ Depende de la abstracción
  
  CreateEventUseCase(this._repository);
  
  Future<EventModel> execute(CreateEventParams params) async {
    return await _repository.create(params);
  }
}
```

### 2. ALTO: Tipado Débil en Respuestas del API

**Problema**: Uso excesivo de `Map<String, dynamic>` en lugar de modelos tipados:

```dart
// En ticket_repository.dart
Future<Map<String, dynamic>> checkout(CheckoutParams params);  // ❌
Future<Map<String, dynamic>> validateOffline(ValidateOfflineParams params);  // ❌
Future<Map<String, dynamic>> getQrData(String ticketId);  // ❌
Future<Map<String, dynamic>> checkStatus(CheckTicketParams params);  // ❌
```

**Impacto**:
- No hay autocompletado ni type safety
- Fácil cometer errores al acceder a campos
- Difícil de mantener y refactorizar

**Solución**: Crear modelos específicos:

```dart
class CheckoutResponse {
  final String preferenceId;
  final String paymentUrl;
  final double totalAmount;
  
  CheckoutResponse({
    required this.preferenceId,
    required this.paymentUrl,
    required this.totalAmount,
  });
  
  factory CheckoutResponse.fromJson(Map<String, dynamic> json) => ...
}
```

### 3. ALTO: Modelos con Todos los Campos Nullable

**Problema**: Todos los campos en modelos son nullable (`?`):

```dart
class EventModel {
  final String? id;        // ❌ ¿Por qué nullable?
  final String? name;      // ❌ ¿Por qué nullable?
  final DateTime? startDate;  // ❌
  // ...
}
```

**Impacto**:
- Requiere null checks constantes en la UI
- Posibles runtime errors por acceso a null
- Modelos no reflejan el dominio real

**Solución**: Hacer campos requeridos no-nullable:

```dart
class EventModel {
  final String id;              // ✅ Siempre existe en DB
  final String name;            // ✅ Requerido para crear
  final String? description;    // ✅ Opcional es nullable
  final DateTime startDate;     // ✅ Requerido
  // ...
}
```

### 4. MEDIO: Falta de Validación en Params

**Problema**: Los params no validan datos antes de enviarlos:

```dart
class CreateEventParams {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  // ...
  
  Map<String, dynamic> toJson() {
    // ❌ No valida que endDate > startDate
    // ❌ No valida que name no esté vacío
    // ...
  }
}
```

**Solución**: Agregar validación:

```dart
class CreateEventParams {
  // ...
  
  void validate() {
    if (name.trim().isEmpty) {
      throw ValidationException('Name cannot be empty');
    }
    if (endDate.isBefore(startDate)) {
      throw ValidationException('End date must be after start date');
    }
  }
}
```

### 5. MEDIO: Download PDF Retorna String en Lugar de Bytes

**Problema**:

```dart
Future<String> downloadPdf(String ticketId);  // ❌ Retorna String
```

Un PDF debería retornar `List<int>` o `Uint8List` para poder guardarlo correctamente.

**Solución**:

```dart
Future<List<int>> downloadPdf(String ticketId);  // ✅
```

### 6. BAJO: Falta de Paginación en Listados

**Problema**: Los métodos de listado no tienen paginación:

```dart
Future<List<EventModel>> list();  // ❌ Sin paginación
Future<List<VenueModel>> list();  // ❌ Sin paginación
```

**Solución**:

```dart
Future<PaginatedResult<EventModel>> list({
  int page = 1,
  int limit = 20,
  String? search,
  String? sortBy,
});
```

### 7. BAJO: Código Repetitivo en Providers

**Problema**: Cada método de provider tiene el mismo patrón try-catch repetido:

```dart
try {
  // ...
} catch (e) {
  if (e is ApiException) rethrow;
  throw ApiException(500, e.toString());
}
```

**Solución**: Crear un wrapper o interceptor HTTP para manejar errores centralizadamente.

### 8. BAJO: No Hay Caché

**Problema**: No hay implementación de caché para datos que no cambian frecuentemente (como venues o tipos de tickets).

**Solución**: Considerar agregar caché local con `shared_preferences` o `hive`.

### 9. BAJO: Falta de Documentación

**Problema**: No hay comentarios ni documentación en clases ni métodos.

**Solución**: Agregar documentación DartDoc:

```dart
/// Creates a new event in the system.
/// 
/// [params] Contains all required information to create the event.
/// 
/// Returns the created [EventModel] with generated ID.
/// 
/// Throws [ApiException] if the server returns an error.
/// Throws [ValidationException] if the params are invalid.
Future<EventModel> create(CreateEventParams params);
```

### 10. BAJO: UpdateTicketTypeParams Falta

**Problema**: No pude leer este archivo pero está referenciado en el barrel.

---

## 🔧 Recomendaciones de Mejora

### Prioridad Alta

1. **Implementar Inyección de Dependencias**
   - Usar `get_it`, `injectable` o provider pattern
   - Permitir mocking para tests

2. **Crear Modelos Tipados para Respuestas**
   - Reemplazar `Map<String, dynamic>` con clases tipadas
   - Mejorar developer experience

3. **Refinar Modelos Domain**
   - Hacer campos requeridos no-nullable
   - Agregar métodos `copyWith` para inmutabilidad

### Prioridad Media

4. **Agregar Validación en Params**
   - Validar fechas, rangos, campos obligatorios
   - Fallar rápido (fail fast)

5. **Implementar Paginación**
   - Agregar parámetros a métodos de listado
   - Crear modelo `PaginatedResult<T>`

6. **Corregir Download PDF**
   - Cambiar retorno a `List<int>`

### Prioridad Baja

7. **Agregar Caché Local**
   - Para venues, tipos de tickets
   - Reducir llamadas al servidor

8. **Crear Interceptor HTTP**
   - Manejar errores centralizadamente
   - Agregar logging

9. **Agregar Tests Unitarios**
   - Test para cada UseCase
   - Test para Providers (con mocking)
   - Test para Modelos (serialización)

10. **Documentar Todo**
    - Comentarios DartDoc
    - README del módulo

---

## 📊 Métricas

| Aspecto | Calificación | Notas |
|---------|-------------|-------|
| Arquitectura | ⭐⭐⭐⭐☆ | Buena separación de capas |
| Type Safety | ⭐⭐⭐☆☆ | Muchos nullables, Maps sin tipar |
| Testabilidad | ⭐⭐☆☆☆ | Hardcoded dependencies |
| Mantenibilidad | ⭐⭐⭐☆☆ | Código repetitivo, falta documentación |
| Developer Experience | ⭐⭐⭐☆☆ | Falta autocompletado en respuestas |

**Calificación General: 6.5/10**

---

# 📱 Plan de UI para Events Feature

## 🎯 Objetivo

Diseñar una interfaz de usuario completa para la gestión de eventos, integrando los 22 use cases disponibles en flujos coherentes y user-friendly.

---

## 📐 Estructura de Navegación

```
Dashboard (Eventos)
├── Listado de Eventos
│   ├── Crear Nuevo Evento (Wizard)
│   └── Ver Detalle de Evento
│       ├── Editar Evento
│       ├── Eliminar Evento
│       ├── Tipos de Tickets
│       │   ├── Crear Tipo
│       │   ├── Editar Tipo
│       │   └── Eliminar Tipo
│       └── Ver Tickets Vendidos
├── Venues/Lugares
│   ├── Listado de Venues
│   ├── Crear Venue
│   ├── Ver Detalle
│   └── Eliminar Venue
└── Validación de Tickets
    ├── Escanear QR
    ├── Validación Manual
    └── Validación Offline
```

---

## 🎨 Pantallas Detalladas

### 1. Dashboard de Eventos

**Ruta**: `/events`

**Descripción**: Vista principal con resumen de eventos activos, próximos y pasados.

**Componentes**:
- **Header**: Título "Gestión de Eventos" + Botón "Crear Evento"
- **Tabs**: Activos | Próximos | Pasados | Todos
- **Grid/Lista**: Tarjetas de eventos con imagen, nombre, fecha, estado
- **Stats Cards**: 
  - Total eventos este mes
  - Tickets vendidos hoy
  - Ingresos del mes
  - Eventos próximos a agotarse

**Use Cases Involucrados**:
- `ListEventsUseCase` - Cargar eventos
- `GetEventByIdUseCase` - Ver detalle (navegación)

**Datos Mostrados**:
- Imagen del evento
- Nombre
- Fecha inicio/fin
- Lugar (venue name)
- Estado (activo/pausado/finalizado)
- Tickets vendidos / capacidad

**Acciones**:
- Crear nuevo evento
- Editar evento
- Eliminar evento (con confirmación)
- Ver detalle completo

---

### 2. Wizard: Crear/Editar Evento (3 Pasos)

**Ruta**: `/events/create` | `/events/:id/edit`

**Descripción**: Formulario wizard para crear/editar eventos en 3 pasos.

#### Paso 1: Información Básica

**Campos**:
- Nombre del evento* (text input)
- Descripción (textarea)
- Imagen (upload/image picker)
- Fecha de inicio* (datetime picker)
- Fecha de fin* (datetime picker)

**Validaciones**:
- Nombre requerido, mínimo 3 caracteres
- Fecha fin > fecha inicio
- Fecha inicio > ahora

**Use Cases**:
- Crear: `CreateEventUseCase`
- Editar: `UpdateEventUseCase`

#### Paso 2: Seleccionar Venue

**Opciones**:
- **Usar venue existente**: Dropdown con `ListVenuesUseCase`
- **Crear nuevo venue**: Botón que abre modal

**Modal Crear Venue**:
- Nombre* (text)
- Dirección (text)
- Capacidad (number)
- Ubicación (map picker para lat/long)

**Use Cases**:
- `ListVenuesUseCase`
- `CreateVenueUseCase` (si crea nuevo)
- `GetVenueByIdUseCase` (para mostrar detalle)

#### Paso 3: Tipos de Tickets

**Descripción**: Configurar al menos un tipo de ticket.

**Tabla de Tipos**:
| Nombre | Precio | Cantidad | Disponible | Acciones |
|--------|--------|----------|------------|----------|
| General | $100 | 500 | 300 restantes | Editar/Eliminar |
| VIP | $250 | 100 | 50 restantes | Editar/Eliminar |

**Formulario Tipo de Ticket**:
- Nombre* (ej: "General", "VIP")
- Precio* (number, > 0)
- Cantidad total* (number, > 0)
- Máximo por usuario (number, default: 10)
- Fecha inicio venta (datetime)
- Fecha fin venta (datetime)

**Use Cases**:
- `CreateTicketTypeUseCase`
- `UpdateTicketTypeUseCase`
- `DeleteTicketTypeUseCase`
- `ListTicketTypesByEventUseCase`

**Flujo**:
1. Crear tipos de tickets (puede crear varios)
2. Validar que haya al menos uno
3. Publicar evento

---

### 3. Detalle de Evento

**Ruta**: `/events/:id`

**Descripción**: Vista completa de un evento específico.

**Tabs**:

#### Tab 1: Información General
- Imagen principal
- Nombre y descripción
- Fechas (inicio/fin)
- Venue (mapa + dirección)
- Estado (badge)
- Acciones rápidas: Editar, Duplicar, Eliminar

#### Tab 2: Tipos de Tickets (Management)
**Tabla completa con**:
- Nombre
- Precio
- Cantidad total
- Vendidos
- Restantes (calculado)
- Ingresos generados
- Período de venta
- Estado (activo/inactivo/agotado)
- Acciones: Editar, Eliminar

**Botón**: "Agregar Tipo de Ticket"

#### Tab 3: Ventas/Tickets
**Filtros**:
- Por tipo de ticket
- Por estado (pendiente/pagado/validado)
- Por fecha

**Tabla**:
| ID | Cliente | Email | Tipo | Cantidad | Total | Estado | Acciones |
|----|---------|-------|------|----------|-------|--------|----------|
| #123 | Juan P. | juan@... | General | 2 | $200 | Pagado | Ver PDF |

**Acciones por ticket**:
- Descargar PDF: `DownloadTicketPdfUseCase`
- Ver QR: `GetTicketQrDataUseCase`
- Regenerar QR: `RegenerateQrCodeUseCase`
- Validar: `ValidateTicketUseCase`

**Estadísticas**:
- Total tickets vendidos
- Ingresos totales
- Tickets por tipo (gráfico pie)
- Ventas por día (gráfico line)

#### Tab 4: Validación (Modo Organizador)

**Modo QR Scanner**:
- Cámara para escanear códigos QR
- Input manual como fallback
- Resultado inmediato: ✅ Válido | ❌ Inválido | ⚠️ Ya usado

**Acciones**:
- `ValidateQrCodeUseCase` - Escanear y validar
- `CheckTicketStatusUseCase` - Verificar estado antes de validar
- `ValidateTicketUseCase` - Validación manual con datos

---

### 4. Venta de Tickets (Público/Cliente)

**Ruta**: `/events/:id/purchase`

**Descripción**: Flujo de compra para clientes.

#### Paso 1: Seleccionar Tickets

**Lista de tipos disponibles**:
- General - $100 (300 disponibles)
- VIP - $250 (50 disponibles) [Agotado]

**Selector de cantidad** (con validación de maxPerUser)

**Resumen**:
- Subtotal
- Comisión (si aplica)
- Total

#### Paso 2: Datos del Comprador

**Campos**:
- Nombre completo*
- Email* (validar formato)
- Confirmar email*
- Teléfono (opcional)

#### Paso 3: Checkout/Pago

**Flujo MercadoPago**:
1. `CreateCheckoutPreferenceUseCase` - Crear preferencia
2. Redirigir a MercadoPago con `paymentUrl`
3. Webhook/Return URL para confirmar
4. `PurchaseTicketUseCase` - Confirmar compra

**Pantalla de Éxito**:
- Número de orden
- Tickets comprados
- Botón: Descargar tickets (PDF)
- Botón: Compartir (enviar por email)

**Use Cases**:
- `PurchaseTicketUseCase`
- `CreateCheckoutPreferenceUseCase`
- `DownloadTicketPdfUseCase`

---

### 5. Validador de Tickets (Mobile/Desktop App)

**Ruta**: `/validator` o app nativa

**Descripción**: Aplicación para staff del evento validar entradas.

#### Modo 1: Escanear QR
- Pantalla completa con cámara
- Overlay de frame para QR
- Sonido/vibración al escanear
- Resultado visual inmediato:
  - 🟢 Verde: Ticket válido - mostrar datos del comprador
  - 🔴 Rojo: Inválido - mostrar error
  - 🟡 Amarillo: Ya usado - mostrar fecha/hora de uso previo

**Use Cases**:
- `ValidateQrCodeUseCase`
- `CheckTicketStatusUseCase`

#### Modo 2: Validación Manual
- Input para ingresar código manualmente
- Botón "Validar"
- Mismo resultado visual que modo QR

#### Modo 3: Validación Offline
**Para eventos sin internet**:
- `ValidateOfflineTokenUseCase` - Validar con token local
- Sincronización previa de tickets válidos
- Cola de validaciones pendientes para sync posterior

**Use Cases**:
- `ValidateOfflineTokenUseCase`

#### Modo 4: Lista de Tickets
- Búsqueda por nombre/email/código
- Lista de tickets del evento
- Filtros por estado (pendiente/validado)
- Contador de escaneados vs total

---

### 6. Gestión de Venues

**Ruta**: `/venues`

**Descripción**: CRUD completo de venues.

**Listado**:
- Card por venue con mini-mapa
- Nombre, dirección, capacidad
- Eventos asociados (count)
- Acciones: Ver, Editar, Eliminar

**Crear/Editar**:
- Formulario completo
- Mapa interactivo para seleccionar ubicación
- Preview de dirección

**Eliminar**:
- Validar que no tenga eventos activos
- Confirmación con typing del nombre

**Use Cases**:
- `ListVenuesUseCase`
- `CreateVenueUseCase`
- `GetVenueByIdUseCase`
- `DeleteVenueUseCase`

---

## 🔄 Flujos de Usuario

### Flujo 1: Crear Evento Completo (Organizador)

```
Dashboard → Click "Crear Evento" 
→ Wizard Paso 1 (Info) 
→ Wizard Paso 2 (Seleccionar/Crear Venue)
→ Wizard Paso 3 (Tipos de Tickets)
→ Publicar Evento
→ Detalle del Evento Creado
```

**Use Cases**: CreateEvent, CreateVenue (opcional), CreateTicketType

### Flujo 2: Comprar Ticket (Cliente)

```
Listado de Eventos → Click Evento
→ Ver Detalle Público
→ Click "Comprar Tickets"
→ Seleccionar Cantidad
→ Datos Personales
→ Checkout MercadoPago
→ Éxito + Descargar Tickets
```

**Use Cases**: GetEventById, CreateCheckoutPreference, PurchaseTicket, DownloadTicketPdf

### Flujo 3: Validar Entrada (Staff)

```
Abrir Validador → Escanear QR
→ Mostrar Resultado
→ Si válido: Marcar como usado + Mostrar datos
→ Si inválido: Mostrar error
→ Si ya usado: Mostrar alerta con detalle
```

**Use Cases**: ValidateQrCode, CheckTicketStatus, ValidateTicket

---

### Flujo 4: Registro y Onboarding (NUEVO - v2.0 Backend)

```
Pantalla de Registro → Seleccionar tipo de cuenta
→ Registro con businessType
→ Onboarding opcional
→ Dashboard correspondiente
```

#### Paso 1: Selección de Tipo de Cuenta (UI)

**Pantalla**: `/register` o modal post-registro

**Opciones para el usuario:**
> **¿Cómo vas a usar Menucom?**
> - 🎟️ **Quiero asistir a eventos** (Soy cliente)
> - 🎤 **Quiero organizar eventos** (Soy organizador)

**Comportamiento UI:**

| Opción seleccionada | Campo enviado al backend | Roles resultantes |
|---------------------|--------------------------|-------------------|
| Asistir a eventos | `businessType: "general"` (o omitido) | `CUSTOMER` en `GENERAL` |
| Organizar eventos | `businessType: "events"` | `OWNER` en `EVENTS` + `CUSTOMER` en `GENERAL` |

#### Paso 2: Registro con businessType

**Registro Email/Password:**
```dart
// Request enviado al backend
{
  "email": emailController.text,
  "name": nameController.text,
  "password": passwordController.text,
  "businessType": selectedBusinessType, // "events" | "general"
}
```

**Registro Social (Google/Firebase):**
```dart
// Después del login social, enviar businessType
POST /auth/social/login
Header: Authorization: Bearer <Firebase ID Token>
Body: {
  "businessType": "events" // (Cuando el usuario lo seleccione desde el formulario de regitro)
}
```

#### Paso 3: Redirección Post-Registro

**Lógica del Frontend después del registro/login:**

```dart
// 1. Obtener roles del usuario
final roles = await userRoleService.getMyRoles();

// 2. Determinar a dónde redirigir
final hasEventOwnerRole = roles.any((r) => 
  r.role == 'owner' && r.context == 'events'
);

if (hasEventOwnerRole) {
  // Organizador: ir a Dashboard de Eventos
  Get.offAllNamed(PURoutes.EVENTS);
} else {
  // Cliente: ir a Home / Listado de Eventos Públicos
  Get.offAllNamed(PURoutes.HOME);
}
```

#### Paso 4: Switch de Modo (Dual Role)

Como el organizador también tiene rol `CUSTOMER`, la UI debe permitir "cambiar de modo":

**UI Sugerida:**
- **Modo Organizador**: Dashboard de gestión (`/events`)
  - Crear/editar eventos
  - Ver ventas
  - Validar tickets
- **Modo Cliente**: Explorar eventos (`/home` o `/explore`)
  - Ver eventos públicos
  - Comprar tickets
  - Ver mis tickets

**Switch en el AppBar/Drawer:**
```dart
// Selector de modo (solo visible si tiene OWNER en EVENTS)
PUDropdownButton<String>(
  value: currentMode, // 'organizer' | 'customer'
  items: [
    DropdownMenuItem(value: 'organizer', child: Text('🎤 Modo Organizador')),
    DropdownMenuItem(value: 'customer', child: Text('🎟️ Modo Cliente')),
  ],
  onChanged: (mode) {
    if (mode == 'organizer') {
      Get.offAllNamed(PURoutes.EVENTS);
    } else {
      Get.offAllNamed(PURoutes.HOME);
    }
  },
)
```

#### Consideraciones de UX

1. **No obligar a elegir en el registro**: Permitir que el usuario se registre como cliente y, desde el perfil, "activar modo organizador" llamando a `POST /user-roles/assign` (si el backend lo permite sin admin).

2. **Onboarding para organizadores**: Al detectar que es un OWNER en EVENTS nuevo, mostrar un onboarding:
   - Paso 1: Bienvenida a organizadores
   - Paso 2: Crear tu primer evento (CTA)
   - Paso 3: Configurar tipos de tickets

3. **Validación de permisos en cada pantalla**: No confiar solo en la navegación. Cada pantalla de gestión debe verificar:
   ```dart
   @override
   void onInit() {
     super.onInit();
     if (!authController.canCreateEvents) {
       // Redirigir o mostrar pantalla de upgrade
       Get.offAllNamed(PURoutes.HOME);
     }
   }
   ```

---

## 🎨 Componentes UI Reutilizables (en pu_material)

**⚠️ IMPORTANTE**: Todos los componentes deben estar en el submódulo `pu_material`, NO en el dashboard.

### Ubicación en pu_material
```
pu_material/lib/
├── atoms/
│   ├── event_status_badge.dart
│   ├── ticket_counter.dart
│   ├── price_tag.dart
│   └── date_range_display.dart
├── molecules/
│   ├── event_card.dart
│   ├── ticket_type_card.dart
│   ├── venue_card.dart
│   └── ticket_row.dart
├── organisms/
│   ├── event_form_organism.dart
│   ├── ticket_type_form_organism.dart
│   ├── event_list_organism.dart
│   └── ticket_validator_organism.dart
└── templates/
    ├── events_dashboard_template.dart
    ├── event_create_template.dart
    ├── event_detail_template.dart
    └── ticket_purchase_template.dart
```

### Atoms (pu_material)
- `EventStatusBadge` - Badge de estado (activo/pagado/etc)
- `TicketCounter` - Contador de tickets
- `PriceTag` - Etiqueta de precio
- `DateRangeDisplay` - Display de rango de fechas

### Molecules (pu_material)
- `EventCard` - Tarjeta de evento
- `TicketTypeCard` - Tarjeta de tipo de ticket
- `VenueCard` - Tarjeta de venue
- `TicketRow` - Fila de ticket vendido

### Organisms (pu_material)
- `EventFormOrganism` - Formulario completo de evento
- `TicketTypeFormOrganism` - Formulario de tipo de ticket
- `EventListOrganism` - Lista con filtros
- `TicketValidatorOrganism` - Validador QR y manual

### Templates (pu_material) - Los que usa el Dashboard
- `EventsDashboardTemplate` - Template del listado de eventos
- `EventCreateTemplate` - Template del wizard de creación
- `EventDetailTemplate` - Template del detalle con tabs
- `TicketPurchaseTemplate` - Template del flujo de compra

**Reglas**:
- Los templates reciben callbacks (`VoidCallback`, `Function(T)`) y datos
- Los templates **NO** reciben controllers de GetX
- El dashboard usa `GetBuilder` y pasa los valores al template

---

## 📱 Responsive Design

### Desktop (>1024px)
- Dashboard: Grid de 3-4 eventos por fila
- Detalle: Sidebar con info + Tabs principales
- Validador: Split view (scanner | resultados)

### Tablet (768px - 1024px)
- Dashboard: Grid de 2 eventos por fila
- Detalle: Tabs verticales
- Validador: Full screen scanner

### Mobile (<768px)
- Dashboard: Lista vertical
- Detalle: Tabs horizontales scrollables
- Validador: Solo modo cámara full screen
- Wizard: Un paso por pantalla con navegación bottom

---

## 🔄 Estados y Manejo de Errores

### Estados de Carga
- Skeleton loaders para listados
- Spinners para acciones
- Shimmer effect para imágenes

### Estados Vacíos
- Empty state para listados sin datos
- Ilustraciones + mensajes amigables
- CTA para crear primer elemento

### Estados de Error
- Toast notifications para errores
- Retry buttons para errores de red
- Fallback a offline mode si es posible
- Form validation inline

### Estados de Éxito
- Toast/Notification de éxito
- Animaciones de celebración (confetti en compra)
- Auto-redirect después de acciones exitosas

---

## 🔐 Sistema de Roles y Contextos (v2.0 Backend)

> **Actualizado según `EVENT-FLOW-COMPLETE.md` v2.0**  
> El backend ahora usa un sistema dual de contextos. El rol `EVENT_ORGANIZER` quedó **DEPRECATED**; el nuevo estándar es `OWNER` en contexto `EVENTS`.

### Concepto de Contexto

Un **contexto** es un dominio de negocio aislado donde un usuario puede tener diferentes capacidades:

| Contexto | Descripción |
|----------|-------------|
| `GENERAL` | Sistema completo (cliente/comprador) |
| `EVENTS` | Gestión de eventos y tickets |
| `RESTAURANT` | Negocios de comida |
| `MARKETPLACE` | Tiendas/Marketplaces |

### Jerarquía de Roles (Nuevo Sistema)

| Rol | Contexto | Permisos |
|-----|----------|----------|
| **OWNER** | **EVENTS** | ✅ Crear/editar/eliminar eventos<br>✅ Gestionar tickets<br>✅ Validar entradas<br>✅ Ver analytics<br>✅ Gestionar pagos |
| EVENT_ORGANIZER | EVENTS | ✅ Mismos permisos (legacy, aún funciona pero está deprecated) |
| ADMIN | EVENTS | ✅ Todos los permisos + gestionar otros usuarios |
| CUSTOMER | GENERAL | ✅ Ver eventos públicos<br>✅ Comprar tickets<br>✅ Ver mis tickets |

### Registro con `businessType`

El backend ahora acepta un campo `businessType` en el registro para asignar roles automáticamente:

```json
// Registro como Organizador de Eventos
POST /auth/register
{
  "email": "organizador@eventos.com",
  "name": "Juan Pérez",
  "password": "password123",
  "businessType": "events"  // ← NUEVO CAMPO
}
```

**Roles asignados automáticamente:**

| Rol | Contexto | Propósito |
|-----|----------|-----------|
| `OWNER` | `EVENTS` | Crear y gestionar eventos |
| `CUSTOMER` | `GENERAL` | Comprar tickets de otros eventos |

> **Importante:** Un organizador tiene **DOS roles** al registrarse. Esto permite que pueda tanto crear sus propios eventos como comprar tickets en eventos de terceros sin necesidad de una segunda cuenta.

### Registro Social con `businessType`

```json
POST /auth/social/login
Header: Authorization: Bearer <Firebase ID Token>
Body: {
  "businessType": "events"  // Opcional
}
```

- Si se proporciona `businessType: "events"` → Asigna `OWNER` en `EVENTS` + `CUSTOMER` en `GENERAL`
- Si no se proporciona → Asigna solo `CUSTOMER` en `GENERAL` por defecto

### Roles en la UI del Dashboard

#### Organizador de Eventos (OWNER en EVENTS)
- ✅ Crear/editar/eliminar eventos
- ✅ Crear/editar/eliminar venues
- ✅ Ver todas las ventas de sus eventos
- ✅ Validar tickets (online y offline)
- ✅ Gestionar tipos de tickets
- ✅ Ver analytics y reportes
- ✅ Comprar tickets de otros eventos (por su rol CUSTOMER en GENERAL)

#### Staff (MANAGER u OPERATOR en EVENTS)
- ✅ Validar tickets
- ✅ Ver lista de tickets del evento
- ❌ Crear/editar eventos
- ❌ Ver datos financieros totales

#### Cliente (CUSTOMER en GENERAL)
- ✅ Ver eventos públicos
- ✅ Comprar tickets
- ✅ Ver mis tickets (QR, descargar PDF)
- ❌ Acceso a gestión de eventos

### Identificar un Organizador en el Frontend

```dart
// Verificar roles desde el backend
// GET /user-roles/my-roles
// GET /user-roles/my-permissions/events

// El backend determina si es organizador con:
const isOrganizer = await userRoleService.hasRole(
  userId,
  RoleType.OWNER,
  BusinessContext.EVENTS,
);
```

---

## 📊 Análisis de Uso de Use Cases

| Use Case | Pantalla | Frecuencia |
|----------|----------|------------|
| ListEvents | Dashboard | Alta |
| CreateEvent | Wizard | Media |
| GetEventById | Detalle | Alta |
| UpdateEvent | Editar | Media |
| DeleteEvent | Dashboard | Baja |
| ListVenues | Venues/Wizard | Media |
| CreateVenue | Modal Wizard | Media |
| GetVenueById | Detalle | Baja |
| DeleteVenue | Venues | Baja |
| CreateTicketType | Wizard | Media |
| ListTicketTypesByEvent | Detalle | Alta |
| UpdateTicketType | Detalle | Media |
| DeleteTicketType | Detalle | Baja |
| PurchaseTicket | Checkout | Alta |
| CreateCheckoutPreference | Checkout | Alta |
| DownloadTicketPdf | Detalle/Éxito | Media |
| ValidateQrCode | Validador | Alta |
| ValidateTicket | Validador | Media |
| ValidateOfflineToken | Validador Offline | Media |
| GetTicketQrData | Detalle | Media |
| RegenerateQrCode | Detalle | Baja |
| CheckTicketStatus | Validador | Alta |

---

## 🚀 Implementación Recomendada

### Fase 1: Core (MVP)
- [ ] Dashboard de eventos (listado básico)
- [ ] Crear evento (wizard simplificado)
- [ ] Detalle de evento (info básica)
- [ ] Validador QR básico

### Fase 2: Gestión Completa
- [ ] Gestión de venues
- [ ] Gestión de tipos de tickets
- [ ] Listado de ventas
- [ ] Descargar tickets

### Fase 3: Compras
- [ ] Flujo de compra público
- [ ] Integración MercadoPago
- [ ] Envío de tickets por email

### Fase 4: Avanzado
- [ ] Estadísticas y reportes
- [ ] Validación offline
- [ ] Multi-evento simultáneo
- [ ] App nativa validador

---

## 📋 Checklist de Implementación

### Estructura
- [ ] Crear carpetas: `presentation/`, `providers/`, `screens/`, `widgets/`
- [ ] Configurar rutas con go_router
- [ ] Crear providers de estado (Riverpod/Bloc)

### UI Components
- [ ] EventCard component
- [ ] EventForm component
- [ ] TicketTypeCard component
- [ ] QrScanner component
- [ ] ValidationResult component

### Screens
- [ ] EventsDashboardScreen
- [ ] EventCreateScreen (wizard)
- [ ] EventDetailScreen
- [ ] VenuesListScreen
- [ ] VenueCreateScreen
- [ ] TicketPurchaseScreen
- [ ] TicketValidatorScreen

### Integración API
- [ ] Crear service layer para events
- [ ] Crear service layer para tickets
- [ ] Manejo de errores global
- [ ] Loading states

### Testing
- [ ] Widget tests para componentes
- [ ] Integration tests para flujos
- [ ] Golden tests para UI

---

## 🚨 Errores e Inconsistencias Identificadas en el Plan de UI

Tras analizar la arquitectura actual del proyecto (`pickmeup_dashboard`), se detectaron los siguientes problemas e inconsistencias en el plan de UI propuesto:

### 1. CRÍTICO: Inconsistencia con la Arquitectura de Navegación

**Problema**: El plan propone usar `go_router` para la navegación:
```dart
// En el plan se propone:
// Configurar rutas con go_router
```

**Error**: El proyecto actual usa **GetX** para navegación y state management (como se ve en `pubspec.yaml` y `routes/routes.dart`).

**Impacto**:
- Conflicto con la arquitectura existente
- Duplicación de sistemas de navegación
- Inconsistencia en la gestión de estado entre pantallas
- Mayor complejidad de mantenimiento

**Solución Correcta**: Usar GetX para navegación y bindings:

```dart
// routes/routes.dart - Agregar rutas de eventos
class PURoutes {
  // ... rutas existentes ...
  
  // Events
  static String EVENTS = '/events';
  static String EVENT_CREATE = '/events/create';
  static String EVENT_DETAIL = '/events/:id';
  static String EVENT_EDIT = '/events/:id/edit';
  static String VENUES = '/venues';
  static String TICKET_VALIDATOR = '/ticket-validator';
  static String TICKET_PURCHASE = '/events/:id/purchase';
}

// routes/pages.dart - Configuración GetX
class EventPages {
  static List<GetPage> getPages() {
    return [
      GetPage(
        name: PURoutes.EVENTS,
        page: () => const EventsDashboardScreen(),
        binding: EventsBinding(),
        middlewares: [AuthMiddleware()],
      ),
      GetPage(
        name: PURoutes.EVENT_CREATE,
        page: () => const EventCreateScreen(),
        binding: EventCreateBinding(),
        middlewares: [AuthMiddleware()],
      ),
      GetPage(
        name: PURoutes.EVENT_DETAIL,
        page: () => const EventDetailScreen(),
        binding: EventDetailBinding(),
        middlewares: [AuthMiddleware()],
      ),
    ];
  }
}
```

---

### 2. CRÍTICO: Estructura de Carpetas Incorrecta - Data/Domain YA EXISTE en menu_dart_api

**Problema**: El plan propone crear toda la estructura incluyendo data/domain cuando **YA EXISTE** en el submódulo `menu_dart_api`.

**Estructura YA EXISTENTE en menu_dart_api (NO recrear)**:
```
menu_dart_api/lib/by_feature/events/  // ✅ YA EXISTE
├── models/
│   ├── event_model.dart
│   ├── venue_model.dart
│   ├── ticket_type_model.dart
│   └── ... (14 modelos en total)
├── data/
│   ├── repository/       # Interfaces
│   ├── provider/         # Implementaciones HTTP
│   └── usecase/          # 22 use cases
```

**Estructura Correcta en Dashboard (SOLO Presentation)**:
```
lib/features/events/  // ✅ Solo presentation layer
├── bindings/
│   ├── events_binding.dart              # Inyecta use cases del API
│   └── event_detail_binding.dart
├── controllers/
│   ├── events_controller.dart           # Usa use cases de menu_dart_api
│   └── event_detail_controller.dart
└── pages/
    ├── events_dashboard_page.dart       # Usa templates de pu_material
    ├── event_create_page.dart
    └── event_detail_page.dart
```

**⚠️ IMPORTANTE**: 
1. No crear `data/`, `domain/`, `models/`, `repositories/`, ni `usecases/` en el dashboard. Todo eso ya está en `menu_dart_api`.
2. No crear `widgets/` en presentation. Los widgets deben estar en `pu_material` (submódulo de UI).
3. Las pages del dashboard usan los **templates** de `pu_material` y les pasan los controllers.

---

### 3. CRÍTICO: Falta de Inyección de Dependencias con GetX Bindings

**Problema**: El plan no menciona cómo integrar con GetX Bindings para DI.

**Implementación Correcta** (los use cases vienen de `menu_dart_api`):

```dart
// lib/features/events/presentation/bindings/events_binding.dart
import 'package:menu_dart_api/by_feature/events/events.dart'; // Import del submódulo

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Los use cases YA ESTÁN definidos en menu_dart_api
    // Se importan directamente desde el paquete
    
    // Use Cases del submódulo menu_dart_api
    Get.lazyPut(() => ListEventsUseCase());  // Ya tiene el provider injectado internamente
    Get.lazyPut(() => GetEventByIdUseCase());
    Get.lazyPut(() => CreateEventUseCase());
    Get.lazyPut(() => UpdateEventUseCase());
    Get.lazyPut(() => DeleteEventUseCase());
    Get.lazyPut(() => ListVenuesUseCase());
    Get.lazyPut(() => CreateVenueUseCase());
    Get.lazyPut(() => CreateTicketTypeUseCase());
    Get.lazyPut(() => ListTicketTypesByEventUseCase());
    
    // Controllers del dashboard
    Get.lazyPut<EventsController>(
      () => EventsController(
        listEventsUseCase: Get.find<ListEventsUseCase>(),
        getEventByIdUseCase: Get.find<GetEventByIdUseCase>(),
      ),
    );
  }
}
```

**Nota**: Los use cases de `menu_dart_api` ya tienen los providers instanciados internamente (aunque esto es un problema de arquitectura que debería corregirse en el futuro para usar inyección de dependencias).

---

### 4. ALTO: Controladores GetX vs. Providers

**Problema**: El plan menciona "providers de estado (Riverpod/Bloc)" que no están en el proyecto.

**Solución**: Usar GetX Controllers como el resto de features:

```dart
// presentation/controllers/events_controller.dart
class EventsController extends GetxController {
  final ListEventsUseCase _listEventsUseCase;
  final GetEventByIdUseCase _getEventByIdUseCase;
  
  EventsController({
    required ListEventsUseCase listEventsUseCase,
    required GetEventByIdUseCase getEventByIdUseCase,
  })  : _listEventsUseCase = listEventsUseCase,
        _getEventByIdUseCase = getEventByIdUseCase;
  
  // State
  final RxList<Event> events = <Event>[].obs;
  final Rx<Event?> selectedEvent = Rx<Event?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }
  
  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final result = await _listEventsUseCase.execute();
      events.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Error al cargar eventos: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadEventDetail(String eventId) async {
    isLoading.value = true;
    
    try {
      final event = await _getEventByIdUseCase.execute(eventId);
      selectedEvent.value = event;
    } catch (e) {
      errorMessage.value = 'Error al cargar evento: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  void navigateToCreateEvent() {
    Get.toNamed(PURoutes.EVENT_CREATE);
  }
  
  void navigateToEventDetail(String eventId) {
    Get.toNamed('${PURoutes.EVENTS}/$eventId');
  }
}
```

---

### 5. ALTO: Los Modelos YA EXISTEN en menu_dart_api

**Problema**: El plan propone crear modelos cuando **YA EXISTEN** en el submódulo.

**Ubicación de Modelos Existentes**:
```
menu_dart_api/lib/by_feature/events/models/
├── event_model.dart          # ✅ YA EXISTE
├── venue_model.dart          # ✅ YA EXISTE
├── ticket_type_model.dart    # ✅ YA EXISTE
├── ticket_model.dart         # ✅ YA EXISTE
└── ... (otros 10 modelos)
```

**Importación Correcta en el Dashboard**:

```dart
// lib/features/events/presentation/controllers/events_controller.dart
import 'package:menu_dart_api/by_feature/events/events.dart';  # Importa todos los modelos

class EventsController extends GetxController {
  // Usar los modelos directamente del submódulo
  final RxList<EventModel> events = <EventModel>[].obs;
  final Rx<EventModel?> selectedEvent = Rx<EventModel?>(null);
  final Rx<VenueModel?> selectedVenue = Rx<VenueModel?>(null);
  final RxList<TicketTypeModel> ticketTypes = <TicketTypeModel>[].obs;
  
  // No crear modelos nuevos en el dashboard
}
```

**Extensiones Útiles** (opcional, en el dashboard):

```dart
// lib/features/events/presentation/extensions/event_extensions.dart
import 'package:menu_dart_api/by_feature/events/models/event_model.dart';

extension EventModelUI on EventModel {
  String get formattedDateRange {
    // Formatear fechas para mostrar en UI
    return '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}';
  }
  
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing => startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
}
```

---

### 6. MEDIO: Middleware de Autenticación No Mencionado

**Problema**: El plan no menciona que todas las rutas de eventos deben estar protegidas.

**Solución**: Usar el AuthMiddleware existente:

```dart
// Verificar en lib/features/auth/presentation/middlewares/auth_middleware.dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: PURoutes.LOGIN);
    }
    
    // Verificar permisos específicos para eventos
    if (route?.startsWith('/events') == true) {
      if (!authController.hasPermission('events.read')) {
        return const RouteSettings(name: PURoutes.HOME);
      }
    }
    
    return null;
  }
}
```

---

### 7. MEDIO: Inconsistencia en Manejo de Errores

**Problema**: El plan propone un manejo de errores genérico sin seguir el patrón del proyecto.

**Patrón Correcto (basado en auth)**:

```dart
// presentation/controllers/events_controller.dart
Future<void> createEvent(CreateEventParams params) async {
  isLoading.value = true;
  
  try {
    // Validar antes de enviar
    params.validate();
    
    final event = await _createEventUseCase.execute(params);
    events.add(event);
    
    // Mostrar éxito usando el sistema de diálogos del proyecto
    GlobalHandleDialogs.showSuccess('Evento creado exitosamente');
    
    Get.back(); // Volver a la lista
  } on ValidationException catch (e) {
    // Error de validación - mostrar en el formulario
    errorMessage.value = e.message;
  } on ApiException catch (e) {
    // Error de API
    GlobalHandleDialogs.showError(e.message);
  } catch (e) {
    // Error inesperado
    GlobalHandleDialogs.showError('Error inesperado al crear el evento');
  } finally {
    isLoading.value = false;
  }
}
```

---

### 8. MEDIO: Plan de Wizard No Considera Estado

**Problema**: El wizard de 3 pasos propuesto no especifica cómo mantener el estado entre pasos.

**Solución con GetX**:

```dart
// presentation/controllers/event_wizard_controller.dart
class EventWizardController extends GetxController {
  // Paso actual
  final RxInt currentStep = 0.obs;
  
  // Datos del evento (persisten entre pasos)
  final Rx<EventFormData> formData = EventFormData().obs;
  
  // Validadores por paso
  bool get canProceedToStep2 => 
      formData.value.name.isNotEmpty &&
      formData.value.startDate != null &&
      formData.value.endDate != null;
  
  bool get canProceedToStep3 => 
      formData.value.venueId != null;
  
  void nextStep() {
    if (currentStep.value < 2 && validateCurrentStep()) {
      currentStep.value++;
    }
  }
  
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }
  
  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        return canProceedToStep2;
      case 1:
        return canProceedToStep3;
      case 2:
        return formData.value.ticketTypes.isNotEmpty;
      default:
        return false;
    }
  }
  
  Future<void> submit() async {
    // Crear el evento completo
    final params = CreateEventParams(
      name: formData.value.name,
      description: formData.value.description,
      startDate: formData.value.startDate!,
      endDate: formData.value.endDate!,
      venueId: formData.value.venueId!,
      ticketTypes: formData.value.ticketTypes,
    );
    
    await createEvent(params);
  }
}
```

---

### 9. BAJO: Componentes UI deben estar en pu_material, no en presentation

**Problema**: El plan clasifica componentes como Atoms/Molecules/Organisms en `presentation/widgets/` cuando deben estar en `pu_material`.

**Estructura Correcta (en pu_material)**:

```
pu_material/lib/
├── atoms/
│   ├── event_status_badge.dart      # Sin dependencias a GetX
│   ├── ticket_counter.dart
│   └── price_tag.dart
├── molecules/
│   ├── event_card.dart              # Recibe callbacks
│   ├── ticket_type_card.dart
│   └── venue_card.dart
├── organisms/
│   ├── event_list_organism.dart     # Sin controllers
│   ├── event_form_organism.dart
│   └── ticket_purchase_organism.dart
└── templates/
    └── events_dashboard_template.dart  # Usado por el dashboard
```

**Ejemplo de componente atómico en pu_material**:

```dart
// pu_material/lib/atoms/event_status_badge.dart
// NO importa nada de pickmeup_dashboard

class EventStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  
  const EventStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });
  
  Color get _backgroundColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'finished':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
  
  String get _label {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'paused':
        return 'Pausado';
      case 'finished':
        return 'Finalizado';
      default:
        return status;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _backgroundColor),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _backgroundColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

**No hay widgets en presentation/**: El dashboard solo tiene:
- `bindings/` - Configuración GetX
- `controllers/` - Lógica de estado
- `pages/` - Páginas que usan templates de pu_material

---

### 10. CRÍTICO: Widgets deben estar en pu_material, NO en presentation

**Problema**: El plan propone crear widgets en `presentation/widgets/` cuando deben estar en `pu_material`.

**Arquitectura Correcta**:
- `pu_material`: Contiene todos los widgets (atoms, molecules, organisms, templates)
- `pu_material` **NO** debe tener dependencias a GetX/controllers
- Las **templates** reciben callbacks y datos, no controllers
- El dashboard (presentation) solo contiene pages que usan los templates

**Ejemplo de Template en pu_material**:
```dart
// pu_material/lib/templates/events_dashboard_template.dart
// NO tiene dependencias a GetX

class EventsDashboardTemplate extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<EventModel> events;
  final VoidCallback onRetry;
  final VoidCallback onCreateEvent;
  final Function(EventModel) onEventTap;
  
  const EventsDashboardTemplate({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.events,
    required this.onRetry,
    required this.onCreateEvent,
    required this.onEventTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return PUScaffold(
      appBar: PUAppBar(
        title: 'Gestión de Eventos',
        actions: [
          PUButton(
            text: 'Crear Evento',
            onPressed: onCreateEvent,
            type: ButtonType.primary,
          ),
        ],
      ),
      body: isLoading
          ? const PUShimmerLoading()
          : errorMessage != null
              ? PUErrorState(
                  message: errorMessage!,
                  onRetry: onRetry,
                )
              : PUGridView(
                  children: events.map((event) {
                    return EventCardMolecule(
                      event: event,
                      onTap: () => onEventTap(event),
                    );
                  }).toList(),
                ),
    );
  }
}
```

**Ejemplo de Page en Dashboard** (usa el template):
```dart
// lib/features/events/presentation/pages/events_dashboard_page.dart
import 'package:pu_material/pu_material.dart';  // Templates
import 'package:menu_dart_api/by_feature/events/events.dart';  // Models

class EventsDashboardPage extends StatelessWidget {
  const EventsDashboardPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventsController>(  // Controller solo en dashboard
      builder: (controller) {
        return EventsDashboardTemplate(
          isLoading: controller.isLoading.value,
          errorMessage: controller.errorMessage.value.isEmpty
              ? null
              : controller.errorMessage.value,
          events: controller.events,
          onRetry: controller.loadEvents,
          onCreateEvent: controller.navigateToCreateEvent,
          onEventTap: controller.navigateToEventDetail,
        );
      },
    );
  }
}
```

**⚠️ REGLAS IMPORTANTES**:
1. `pu_material` **NUNCA** importa de `pickmeup_dashboard`
2. `pu_material` **NUNCA** usa GetX, controllers, ni navegación
3. Los templates reciben `VoidCallback`, `Function(T)`, datos primitivos
4. El dashboard es el único que usa GetX y controllers

---

## 📋 Checklist de Implementación Corregida

### ⚠️ NOTA IMPORTANTE: Data/Domain YA EXISTE en menu_dart_api
Los modelos, repositories y use cases **YA ESTÁN** implementados en `menu_dart_api/lib/by_feature/events/`.  
**NO** crear data/ ni domain/ en el dashboard. Solo implementar la capa de **presentation**.

### Fase 1: Estructura Base (SOLO Presentation)

- [ ] Crear carpeta `lib/features/events/presentation/` (SOLO presentation)
- [ ] Crear rutas en `PURoutes` siguiendo la convención existente
- [ ] Crear GetX Bindings importando use cases de `menu_dart_api`
- [ ] Crear Controllers GetX para manejo de estado
- [ ] Configurar middleware de autenticación

### Fase 2: Integración con menu_dart_api

- [ ] Verificar que menu_dart_api tenga export en `events.dart` barrel
- [ ] Importar use cases desde `package:menu_dart_api/by_feature/events/events.dart`
- [ ] Importar modelos desde el submódulo
- [ ] Registrar use cases en Bindings
- [ ] Crear extensiones UI para modelos si es necesario

### Fase 3: UI Components (en pu_material - submódulo)

- [ ] Crear atoms en pu_material: EventStatusBadge, PriceTag, TicketCounter
- [ ] Crear molecules en pu_material: EventCard, TicketTypeCard, VenueCard
- [ ] Crear organisms en pu_material: EventListOrganism, EventFormOrganism, TicketPurchaseOrganism
- [ ] Crear templates en pu_material: EventsDashboardTemplate, EventCreateTemplate, EventDetailTemplate
- [ ] Crear pages en dashboard: EventsDashboardPage, EventCreatePage, EventDetailPage (usan templates)

**Nota**: Los widgets (atoms, molecules, organisms, templates) van en `pu_material`.  
Las pages del dashboard importan los templates y les pasan los controllers.

### Fase 4: Flujos Completos

- [ ] Wizard de creación con estado persistente
- [ ] Listado con paginación y filtros
- [ ] Detalle con tabs (info, tickets, ventas, validación)
- [ ] Validador QR con feedback visual
- [ ] Flujo de compra con MercadoPago

### Fase 5: Testing

- [ ] ~~Unit tests para use cases~~ (YA EXISTEN en menu_dart_api)
- [ ] Widget tests para componentes de presentation
- [ ] Integration tests para flujos completos
- [ ] Golden tests para UI screens

### Testing por Separado

**En menu_dart_api** (submódulo):
- Unit tests para use cases
- Unit tests para providers
- Unit tests para models (serialización)

**En pickmeup_dashboard** (este proyecto):
- Widget tests para componentes UI
- Integration tests para flujos de navegación
- Controller tests (con use cases mockeados)

---

## 🎯 Lecciones Aprendidas

1. **Siempre revisar la arquitectura existente** antes de proponer cambios
2. **Usar los patrones establecidos** del proyecto (GetX, Clean Architecture)
3. **Aprovechar las librerías existentes** (`pu_material` para componentes UI, `menu_dart_api` para data/domain)
4. **Mantener consistencia** en estructura de carpetas y naming
5. **Seguir la separación Domain/Data/Presentation** estrictamente
6. **Documentar las dependencias** correctamente en Bindings
7. **Reutilizar componentes** existentes cuando sea posible
8. **Implementar validación** en use cases, no solo en UI
9. **Manejar errores** siguiendo el patrón del proyecto
10. **Proteger rutas** con middleware de autenticación
11. **Separar UI de Lógica**: `pu_material` (UI pura) vs Dashboard (controllers)
12. **Templates reciben callbacks**, no controllers - mantiene desacoplada la UI

---

## 🔄 Actualizaciones Posteriores Recomendadas

### Mejoras para Agregar al Plan

1. **Agregar sección de Analytics**
   - Métricas de ventas en tiempo real
   - Gráficos de asistencia
   - Reportes exportables (PDF/Excel)

2. **Mejorar Validación Offline**
   - Especificar algoritmo de sincronización
   - Definir estrategia de resolución de conflictos
   - Documentar requisitos de almacenamiento local

3. **Agregar Gestión de Staff**
   - Invitar staff por email
   - Asignar permisos granulares
   - Tracking de acciones por staff

4. **Especificar Responsive Design en Detalle**
   - Breakpoints específicos
   - Componentes adaptativos
   - Testing en dispositivos reales

5. **Documentar Integración MercadoPago**
   - Flujo de webhooks
   - Manejo de estados de pago
   - Reembolsos y cancelaciones

---

**Documento creado**: 2026-05-11
**Versión**: 1.4 (Revisado - Sistema de Roles v2.0 del Backend)
**Autor**: AI Assistant
**Nota de revisión v1.1**: Se identificaron y corrigieron múltiples inconsistencias con la arquitectura actual del proyecto (GetX, Clean Architecture, pu_material). El documento original propuso usar go_router y Riverpod/Bloc que no están en uso en el proyecto.
**Nota de revisión v1.2**: Se corrigió la estructura de carpetas eliminando data/domain (ya existen en menu_dart_api). El dashboard solo debe implementar la capa de presentation.
**Nota de revisión v1.3**: Se corrigió la ubicación de widgets - deben estar en `pu_material` (submódulo de UI), no en el dashboard. `pu_material` no debe tener dependencias a controllers.
**Nota de revisión v1.4**: Se actualizó el sistema de roles y permisos según `EVENT-FLOW-COMPLETE.md` v2.0 del backend. El rol `EVENT_ORGANIZER` quedó deprecated; ahora se usa `OWNER` en contexto `EVENTS`. Se agregó soporte para `businessType` en el registro y el concepto de dual role (OWNER en EVENTS + CUSTOMER en GENERAL).

**Cambios realizados en v1.1**:
- ✅ Agregadas 10 secciones de errores identificados
- ✅ Documentadas soluciones con código correcto
- ✅ Agregado checklist corregido de implementación
- ✅ Documentadas lecciones aprendidas
- ✅ Agregadas recomendaciones para futuras actualizaciones

**Cambios realizados en v1.2**:
- ✅ Corregida estructura de carpetas: eliminada data/domain (YA EXISTEN en menu_dart_api)
- ✅ Actualizado checklist para reflejar SOLO presentation layer
- ✅ Documentado que use cases y models vienen de menu_dart_api
- ✅ Agregada nota sobre testing por separado (submódulo vs dashboard)

**Cambios realizados en v1.3**:
- ✅ Eliminada carpeta `presentation/widgets/` del dashboard
- ✅ Documentado que widgets deben estar en `pu_material` (submódulo de UI)
- ✅ Especificado que templates reciben callbacks, NO controllers
- ✅ Agregada separación clara: pu_material (UI) vs dashboard (controllers/pages)

**Cambios realizados en v1.4** (Basado en backend `EVENT-FLOW-COMPLETE.md` v2.0):
- ✅ Actualizada sección **Permisos y Roles** al nuevo sistema de contextos (`OWNER` en `EVENTS`, `CUSTOMER` en `GENERAL`)
- ✅ Documentado que `EVENT_ORGANIZER` está **DEPRECATED** (backward compat pero no usar en nuevos flujos)
- ✅ Agregado campo `businessType` al registro (email y social)
- ✅ Documentado el **dual role**: al registrarse como `events`, el usuario recibe `OWNER` en `EVENTS` + `CUSTOMER` en `GENERAL`
- ✅ Agregado **Flujo 4**: Registro y Onboarding con selector de tipo de cuenta
- ✅ Agregado concepto de **Switch de Modo** (Organizador ↔ Cliente) en la UI
- ✅ Documentada redirección post-registro según roles obtenidos
- ✅ Agregadas consideraciones de UX para onboarding de organizadores