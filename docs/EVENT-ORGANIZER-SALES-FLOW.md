# Flujo de Venta del Organizador de Eventos - Menucom Dashboard

## Visión General

Este documento describe el flujo completo de venta de tickets desde la perspectiva del **Organizador de Eventos** en el ecosistema Menucom, abarcando tanto el backend (`menu_dart_api`) como la interacción con el cliente final a través del catálogo (`menucom_catalog`).

El sistema permite a un organizador:
1. Crear y gestionar eventos
2. Configurar tipos de tickets con precios y disponibilidad
3. Compartir su catálogo público para que clientes compren tickets
4. Validar entradas en la puerta del evento

---

## Arquitectura del Sistema de Eventos

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MENU DART API (Backend)                             │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        EVENTS MODULE                                │   │
│  │                                                                     │   │
│  │  Domain Layer                    Data Layer                         │   │
│  │  ┌─────────────┐                ┌─────────────┐   ┌─────────────┐  │   │
│  │  │  Models     │                │ Repositories│   │  Use Cases  │  │   │
│  │  │             │◄───────────────│ (Interfaces)│   │             │  │   │
│  │  │ - Event     │                │             │   │ - Create    │  │   │
│  │  │ - Venue     │                │ - EventRepo │   │ - List      │  │   │
│  │  │ - TicketType│                │ - VenueRepo │   │ - Update    │  │   │
│  │  │ - Ticket    │                │ - TicketType│   │ - Delete    │  │   │
│  │  │ - Params    │                │ - TicketRepo│   │ - Purchase  │  │   │
│  │  │ - Responses │                │             │   │ - Validate  │  │   │
│  │  └─────────────┘                └─────────────┘   └─────────────┘  │   │
│  │         ▲                                │                          │   │
│  │         └────────────────────────────────┘                          │   │
│  │                      Provider Layer                                 │   │
│  │              ┌─────────────────────────┐                            │   │
│  │              │  HTTP Providers         │                            │   │
│  │              │  - EventProvider        │                            │   │
│  │              │  - VenueProvider        │                            │   │
│  │              │  - TicketTypeProvider   │                            │   │
│  │              │  - TicketProvider       │                            │   │
│  │              └─────────────────────────┘                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
           ┌──────────────────────────┼──────────────────────────┐
           │                          │                          │
           ▼                          ▼                          ▼
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   DASHBOARD WEB     │  │   MENUCOM CATALOG   │  │    MERCADO PAGO     │
│   (Organizador)     │  │   (Cliente Final)   │  │    (Pagos)          │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

---

## Fase 1: Configuración del Evento (Organizador)

### 1.1 Creación del Evento

**Usecase**: `CreateEventUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/create_event_usecase.dart`

```dart
final event = await createEventUseCase.execute(CreateEventParams(
  name: 'Concierto de Rock',
  description: 'Gran concierto en vivo',
  startDate: DateTime(2025, 6, 15, 20, 0),
  endDate: DateTime(2025, 6, 15, 23, 0),
  venueId: 'venue-123',
));
```

**Modelo**: `EventModel`
- `id`: Identificador único
- `name`: Nombre del evento
- `description`: Descripción (opcional)
- `startDate` / `endDate`: Fechas del evento
- `venueId`: Lugar donde se realiza
- `status`: `draft`, `published`, `cancelled`
- `ticketTypes`: Lista de tipos de tickets asociados

**Validaciones** (`CreateEventParams.validate()`):
- Nombre: 3-100 caracteres
- Fecha de inicio debe ser futura
- Fecha de fin debe ser posterior a fecha de inicio
- `venueId` es requerido

---

### 1.2 Gestión de Venues (Lugares)

**Use Cases**:
- `CreateVenueUseCase` - Crear lugar
- `ListVenuesUseCase` - Listar lugares
- `GetVenueByIdUseCase` - Obtener lugar específico
- `DeleteVenueUseCase` - Eliminar lugar

**Archivo**: `lib/by_feature/events/data/usecase/`

Cada evento debe estar asociado a un venue que define la ubicación física.

---

### 1.3 Creación de Tipos de Tickets

**Usecase**: `CreateTicketTypeUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/create_ticket_type_usecase.dart`

```dart
final ticketType = await createTicketTypeUseCase.execute(CreateTicketTypeParams(
  eventId: 'event-123',
  name: 'General Admission',
  price: 100.0,
  totalQuantity: 500,
  saleStartDate: DateTime.now(),
  saleEndDate: DateTime(2025, 6, 14, 23, 59),
  maxPerUser: 5,
));
```

**Modelo**: `TicketTypeModel`
- `id`: Identificador único
- `eventId`: Evento al que pertenece
- `name`: Nombre (ej: "General", "VIP", "Early Bird")
- `price`: Precio por ticket
- `totalQuantity`: Cantidad total disponible
- `soldQuantity`: Cantidad ya vendida
- `saleStartDate` / `saleEndDate`: Período de venta
- `maxPerUser`: Máximo por comprador
- `status`: `active`, `sold_out`, `inactive`

**Validaciones** (`CreateTicketTypeParams.validate()`):
- Nombre: 2-50 caracteres
- Precio >= 0
- Cantidad total > 0
- Máximo por usuario > 0 y <= cantidad total
- Fecha de fin venta > fecha de inicio venta

**Propiedades calculadas**:
- `remainingQuantity`: `totalQuantity - soldQuantity`
- `isSoldOut`: `remainingQuantity <= 0`
- `isOnSale`: Verifica fechas, stock y estado activo
- `soldPercentage`: Porcentaje de tickets vendidos

---

### 1.4 Listado y Gestión de Tickets

**Use Cases**:
- `ListTicketTypesByEventUseCase` - Listar tipos de tickets por evento
- `UpdateTicketTypeUseCase` - Actualizar tipo de ticket
- `DeleteTicketTypeUseCase` - Eliminar tipo de ticket

**Archivos**: `lib/by_feature/events/data/usecase/`

---

## Fase 2: Venta de Tickets (Cliente Final)

### 2.1 El Cliente Accede al Catálogo

El organizador comparte su link de catálogo público:
```
https://menucom.com/{commerceId}
```

El cliente final abre el `menucom_catalog` y ve los items disponibles (en el contexto de eventos, estos serían los tipos de tickets).

---

### 2.2 Checkout - Creación de Preferencia de Pago

**Usecase**: `CreateCheckoutPreferenceUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/create_checkout_preference_usecase.dart`
**Provider**: `lib/by_feature/events/data/provider/ticket_provider.dart`

Cuando el cliente confirma su compra en el catálogo:

```dart
final response = await createCheckoutPreferenceUseCase.execute(CheckoutParams(
  ticketTypeId: 'tt-123',
  quantity: 2,
  customerName: 'Juan Pérez',
  customerEmail: 'juan@example.com',
  tenantId: 'organizer-uuid',
));
```

**Parámetros** (`CheckoutParams`):
- `ticketTypeId`: ID del tipo de ticket (requerido)
- `quantity`: Cantidad a comprar (requerido, > 0)
- `customerName`: Nombre del comprador (requerido, 2-100 caracteres)
- `customerEmail`: Email del comprador (requerido, formato válido)
- `tenantId`: ID del organizador/comercio (requerido)

**Endpoint**: `POST /tickets/checkout`

**Respuesta** (`CheckoutResponse`):
```dart
CheckoutResponse(
  preferenceId: 'pref-abc123',
  paymentUrl: 'https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=pref-abc123',
  totalAmount: 200.0,
  currency: 'ARS',
  expirationDate: DateTime(...),
);
```

---

### 2.3 Redirección a MercadoPago

El catálogo redirige al cliente a `paymentUrl` usando `url_launcher`:

- **Web**: `launchUrl(uri, webOnlyWindowName: '_self')`
- **Mobile**: `launchUrl(uri, mode: LaunchMode.externalApplication)`

El cliente completa el pago en la interfaz de MercadoPago.

---

### 2.4 Confirmación de Compra

**Usecase**: `PurchaseTicketUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/purchase_ticket_usecase.dart`

Tras la confirmación del pago (vía webhook o return URL):

```dart
final ticket = await purchaseTicketUseCase.execute(PurchaseTicketParams(
  ticketTypeId: 'tt-123',
  quantity: 2,
  customerName: 'Juan Pérez',
  customerEmail: 'juan@example.com',
));
```

**Parámetros** (`PurchaseTicketParams`):
- `ticketTypeId`: ID del tipo de ticket
- `quantity`: Cantidad comprada
- `customerName`: Nombre del asistente
- `customerEmail`: Email para envío de tickets

**Endpoint**: `POST /tickets/purchase`

**Resultado** (`TicketModel`):
```dart
TicketModel(
  id: 'ticket-456',
  ticketTypeId: 'tt-123',
  eventId: 'event-123',
  customerName: 'Juan Pérez',
  customerEmail: 'juan@example.com',
  quantity: 2,
  totalAmount: 200.0,
  status: 'paid',
  qrCode: 'encrypted-qr-data',
  validationToken: 'token-xyz',
  purchasedAt: DateTime(...),
);
```

---

### 2.5 Entrega de Tickets al Cliente

**Use Cases**:
- `DownloadTicketPdfUseCase` - Descargar ticket en PDF
- `GetTicketQrDataUseCase` - Obtener datos del QR

```dart
// Descargar PDF
final pdfData = await downloadTicketPdfUseCase.execute('ticket-456');

// Obtener datos del QR
final qrData = await getTicketQrDataUseCase.execute('ticket-456');
// qrData.qrCode, qrData.eventName, qrData.ticketTypeName, etc.
```

**Endpoints**:
- `GET /tickets/:id/pdf`
- `GET /tickets/:id/qr-data`

---

## Fase 3: Validación de Entradas (Día del Evento)

### 3.1 Validación por QR

**Usecase**: `ValidateQrCodeUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/validate_qr_code_usecase.dart`

El staff del evento escanea el QR del ticket del cliente:

```dart
final ticket = await validateQrCodeUseCase.execute('qr-code-data');
```

**Endpoint**: `POST /tickets/validate/:code`

**Resultados posibles**:
- ✅ Ticket válido: Se marca como `validated`
- ❌ QR inválido: Error 404/400
- ⚠️ Ticket ya usado: Error si ya está `validated`

---

### 3.2 Validación Manual

**Usecase**: `ValidateTicketUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/validate_ticket_usecase.dart`

Fallback cuando el escaneo QR falla:

```dart
final ticket = await validateTicketUseCase.execute(ValidateTicketParams(
  ticketId: 'ticket-456',
  validationToken: 'token-xyz',
));
```

**Endpoint**: `POST /tickets/validate`

---

### 3.3 Verificación de Estado (Pre-validación)

**Usecase**: `CheckTicketStatusUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/check_ticket_status_usecase.dart`

Verificar estado sin marcar como usado:

```dart
final status = await checkTicketStatusUseCase.execute(CheckTicketParams(
  qrCode: 'qr-data',
));

if (status.canBeUsed) {
  // Permitir entrada
} else if (status.isUsed) {
  // Mostrar alerta: ya fue usado
}
```

**Endpoint**: `POST /tickets/check`

---

### 3.4 Validación Offline

**Usecase**: `ValidateOfflineTokenUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/validate_offline_token_usecase.dart`

Para eventos sin conexión a internet:

```dart
final result = await validateOfflineTokenUseCase.execute(ValidateOfflineParams(
  token: 'offline-token',
  eventId: 'event-123',
));
```

**Endpoint**: `POST /tickets/validate-offline`

---

### 3.5 Regeneración de QR

**Usecase**: `RegenerateQrCodeUseCase`
**Archivo**: `lib/by_feature/events/data/usecase/regenerate_qr_code_usecase.dart`

En caso de que el cliente pierda su ticket o el QR sea comprometido:

```dart
final ticket = await regenerateQrCodeUseCase.execute('ticket-456');
// Genera un nuevo QR code
```

**Endpoint**: `POST /tickets/:id/regenerate-qr`

---

## Modelos de Datos Principales

### EventModel
```dart
class EventModel {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final String venueId;
  final String status; // 'draft', 'published', 'cancelled'
  final List<TicketTypeModel> ticketTypes;
}
```

### TicketTypeModel
```dart
class TicketTypeModel {
  final String id;
  final String eventId;
  final String name;
  final double price;
  final int totalQuantity;
  final int soldQuantity;
  final DateTime saleStartDate;
  final DateTime saleEndDate;
  final int maxPerUser;
  final String status; // 'active', 'sold_out', 'inactive'
}
```

### TicketModel
```dart
class TicketModel {
  final String id;
  final String ticketTypeId;
  final String eventId;
  final String customerName;
  final String customerEmail;
  final int quantity;
  final double totalAmount;
  final String status; // 'pending', 'paid', 'validated', 'cancelled'
  final String? qrCode;
  final String? validationToken;
  final String? paymentUrl;
  final String? preferenceId;
  final DateTime? purchasedAt;
}
```

---

## Catálogo de Use Cases del Módulo de Eventos

### Gestión de Eventos
| Use Case | Archivo | Descripción |
|----------|---------|-------------|
| `CreateEventUseCase` | `data/usecase/create_event_usecase.dart` | Crear nuevo evento |
| `ListEventsUseCase` | `data/usecase/list_events_usecase.dart` | Listar todos los eventos |
| `GetEventByIdUseCase` | `data/usecase/get_event_by_id_usecase.dart` | Obtener evento por ID |
| `UpdateEventUseCase` | `data/usecase/update_event_usecase.dart` | Actualizar evento |
| `DeleteEventUseCase` | `data/usecase/delete_event_usecase.dart` | Eliminar evento |

### Gestión de Venues
| Use Case | Archivo | Descripción |
|----------|---------|-------------|
| `CreateVenueUseCase` | `data/usecase/create_venue_usecase.dart` | Crear venue |
| `ListVenuesUseCase` | `data/usecase/list_venues_usecase.dart` | Listar venues |
| `GetVenueByIdUseCase` | `data/usecase/get_venue_by_id_usecase.dart` | Obtener venue |
| `DeleteVenueUseCase` | `data/usecase/delete_venue_usecase.dart` | Eliminar venue |

### Gestión de Tipos de Tickets
| Use Case | Archivo | Descripción |
|----------|---------|-------------|
| `CreateTicketTypeUseCase` | `data/usecase/create_ticket_type_usecase.dart` | Crear tipo de ticket |
| `ListTicketTypesByEventUseCase` | `data/usecase/list_ticket_types_by_event_usecase.dart` | Listar por evento |
| `UpdateTicketTypeUseCase` | `data/usecase/update_ticket_type_usecase.dart` | Actualizar tipo |
| `DeleteTicketTypeUseCase` | `data/usecase/delete_ticket_type_usecase.dart` | Eliminar tipo |

### Venta y Compra
| Use Case | Archivo | Descripción |
|----------|---------|-------------|
| `CreateCheckoutPreferenceUseCase` | `data/usecase/create_checkout_preference_usecase.dart` | Crear preferencia MP |
| `PurchaseTicketUseCase` | `data/usecase/purchase_ticket_usecase.dart` | Confirmar compra |
| `DownloadTicketPdfUseCase` | `data/usecase/download_ticket_pdf_usecase.dart` | Descargar PDF |

### Validación
| Use Case | Archivo | Descripción |
|----------|---------|-------------|
| `ValidateQrCodeUseCase` | `data/usecase/validate_qr_code_usecase.dart` | Validar por QR |
| `ValidateTicketUseCase` | `data/usecase/validate_ticket_usecase.dart` | Validación manual |
| `ValidateOfflineTokenUseCase` | `data/usecase/validate_offline_token_usecase.dart` | Validación offline |
| `CheckTicketStatusUseCase` | `data/usecase/check_ticket_status_usecase.dart` | Verificar estado |
| `GetTicketQrDataUseCase` | `data/usecase/get_ticket_qr_data_usecase.dart` | Obtener datos QR |
| `RegenerateQrCodeUseCase` | `data/usecase/regenerate_qr_code_usecase.dart` | Regenerar QR |

---

## Repositorios (Interfaces)

### TicketRepository
**Archivo**: `lib/by_feature/events/data/repository/ticket_repository.dart`

```dart
abstract class TicketRepository {
  Future<TicketModel> purchase(PurchaseTicketParams params);
  Future<CheckoutResponse> checkout(CheckoutParams params);
  Future<String> downloadPdf(String ticketId);
  Future<TicketModel> validateQrCode(String code);
  Future<TicketModel> validateTicket(ValidateTicketParams params);
  Future<OfflineValidationResult> validateOffline(ValidateOfflineParams params);
  Future<TicketQrData> getQrData(String ticketId);
  Future<TicketModel> regenerateQr(String ticketId);
  Future<TicketStatus> checkStatus(CheckTicketParams params);
}
```

---

## Flujo Completo de Venta

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FLUJO DE VENTA COMPLETO                             │
└─────────────────────────────────────────────────────────────────────────────┘

FASE 1: CONFIGURACIÓN (Organizador en Dashboard)
═══════════════════════════════════════════════════════════════

  ┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
  │ Crear Venue │────►│ Crear Evento│────►│ Crear TicketType│
  │  (opcional) │     │             │     │   (1 o más)     │
  └─────────────┘     └─────────────┘     └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Publicar Evento │
                                        │  (status: active)│
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │ Compartir Link  │
                                        │  del Catálogo   │
                                        └─────────────────┘


FASE 2: COMPRA (Cliente Final en Catálogo)
═══════════════════════════════════════════════════════════════

  ┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
  │ Abrir Link  │────►│ Seleccionar │────►│   Ver Carrito   │
  │  Catálogo   │     │   Tickets   │     │                 │
  └─────────────┘     └─────────────┘     └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Confirmar Orden │
                                        │ (nombre + email) │
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │ Crear Checkout  │
                                        │  Preference MP  │
                                        │   (Backend API) │
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Redirigir a    │
                                        │  MercadoPago    │
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Cliente Paga   │
                                        │   en MP         │
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Webhook/Return │
                                        │    URL          │
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │ PurchaseTicket  │
                                        │  (Backend API)  │
                                        │  Genera QR      │
                                        └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Mostrar Tickets│
                                        │  Descargar PDF  │
                                        │  Enviar Email   │
                                        └─────────────────┘


FASE 3: VALIDACIÓN (Día del Evento)
═══════════════════════════════════════════════════════════════

  ┌─────────────┐     ┌─────────────┐     ┌─────────────────┐
  │  Abrir      │────►│ Escanear QR │────►│  Validar Ticket │
  │ Validador   │     │  del Cliente│     │   (Backend API) │
  └─────────────┘     └─────────────┘     └─────────────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │  Ticket Válido? │
                                        └─────────────────┘
                                                 │
                                    ┌────────────┼────────────┐
                                    ▼            ▼            ▼
                              ┌─────────┐  ┌─────────┐  ┌─────────┐
                              │   SÍ    │  │   NO    │  │YA USADO │
                              │Permitir │  │Rechazar │  │ Alerta  │
                              │ Entrada │  │         │  │         │
                              └─────────┘  └─────────┘  └─────────┘

```

---

## Estados del Ticket

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   PENDING   │───►│    PAID     │───►│  VALIDATED  │    │  CANCELLED  │
│  (Pendiente)│    │   (Pagado)  │    │  (Validado) │    │(Cancelado)  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                  │                  │
       │                  │                  │
       ▼                  ▼                  ▼
  Compra iniciada    Listo para usar   Entrada al evento
  Esperando pago     Puede descargar   Ticket usado
                     PDF/QR             (una sola vez)
```

---

## Endpoints HTTP del Módulo de Tickets

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| POST | `/tickets/checkout` | Crear preferencia MP | No |
| POST | `/tickets/purchase` | Comprar ticket | No |
| GET | `/tickets/:id/pdf` | Descargar PDF | Sí |
| GET | `/tickets/:id/qr-data` | Obtener QR data | Sí |
| POST | `/tickets/validate/:code` | Validar QR | Sí |
| POST | `/tickets/validate` | Validar manual | Sí |
| POST | `/tickets/validate-offline` | Validar offline | No |
| POST | `/tickets/:id/regenerate-qr` | Regenerar QR | Sí |
| POST | `/tickets/check` | Verificar estado | Sí |

---

## Integración con MercadoPago

### Creación de Preferencia

El `TicketProvider.checkout()` envía al backend:
```json
{
  "ticketTypeId": "tt-123",
  "quantity": 2,
  "customerName": "Juan Pérez",
  "customerEmail": "juan@example.com",
  "tenantId": "organizer-uuid"
}
```

El backend crea una preferencia en MercadoPago y retorna:
```json
{
  "preferenceId": "pref-abc123",
  "paymentUrl": "https://www.mercadopago.com.ar/checkout/v1/redirect?pref_id=pref-abc123",
  "totalAmount": 200.0,
  "currency": "ARS"
}
```

### Webhook/Return URL

MercadoPago redirige a:
```
/checkout/status?preference_id=pref-abc123&status=approved&payment_id=123...
```

Parámetros recibidos:
- `preference_id`: ID de preferencia MP
- `status`: `approved`, `pending`, `failure`
- `payment_id`: ID del pago
- `collection_id`: ID de colección
- `merchant_order_id`: ID de orden

---

## Consideraciones de Seguridad

1. **Autenticación**: Los endpoints de validación requieren token Bearer (`API.loginAccessToken`)
2. **Validación de params**: Todos los params implementan `ValidatableParams` con validaciones estrictas
3. **Rate limiting**: Considerar implementar límite de requests en `/tickets/checkout`
4. **Idempotencia**: Las compras deberían ser idempotentes para evitar duplicados
5. **QR único**: Cada ticket tiene un QR criptográficamente único

---

## Archivos Clave del Proyecto

### Backend (menu_dart_api)

| Archivo | Descripción |
|---------|-------------|
| `lib/by_feature/events/events.dart` | Barrel export del módulo |
| `lib/by_feature/events/models/event_model.dart` | Modelo de evento |
| `lib/by_feature/events/models/ticket_type_model.dart` | Modelo de tipo de ticket |
| `lib/by_feature/events/models/ticket_model.dart` | Modelo de ticket |
| `lib/by_feature/events/models/checkout_params.dart` | Parámetros de checkout |
| `lib/by_feature/events/models/purchase_ticket_params.dart` | Parámetros de compra |
| `lib/by_feature/events/models/checkout_response.dart` | Respuesta de checkout |
| `lib/by_feature/events/data/repository/ticket_repository.dart` | Interfaz de tickets |
| `lib/by_feature/events/data/provider/ticket_provider.dart` | Implementación HTTP |
| `lib/by_feature/events/data/usecase/create_event_usecase.dart` | Crear evento |
| `lib/by_feature/events/data/usecase/create_ticket_type_usecase.dart` | Crear ticket type |
| `lib/by_feature/events/data/usecase/create_checkout_preference_usecase.dart` | Checkout MP |
| `lib/by_feature/events/data/usecase/purchase_ticket_usecase.dart` | Comprar ticket |
| `lib/by_feature/events/data/usecase/validate_qr_code_usecase.dart` | Validar QR |
| `lib/by_feature/events/data/usecase/validate_ticket_usecase.dart` | Validar manual |
| `lib/by_feature/events/data/usecase/check_ticket_status_usecase.dart` | Verificar estado |
| `lib/by_feature/events/data/usecase/get_ticket_qr_data_usecase.dart` | Obtener QR |
| `lib/by_feature/events/data/usecase/regenerate_qr_code_usecase.dart` | Regenerar QR |

### Catálogo (menucom_catalog)

| Archivo | Descripción |
|---------|-------------|
| `lib/main.dart` | Punto de entrada |
| `lib/routes/routes.dart` | Rutas de la app |
| `lib/features/home/controllers/home_controller.dart` | Controlador del catálogo |
| `lib/features/my_cart/getx/order_controller.dart` | Controlador de checkout |
| `lib/features/my_cart/presentation/pages/checkout_status_page.dart` | Estado del pago |

---

## Próximos Pasos / Mejoras Sugeridas

1. **Integración nativa de Eventos en el Catálogo**: Adaptar el carrito para que reconozca items de tipo `ticket` y aplique validaciones específicas (`maxPerUser`, `remainingQuantity`)
2. **Sistema de espera (Waitlist)**: Cuando un ticket type se agota, permitir a clientes unirse a lista de espera
3. **Descuentos y promociones**: Soporte para códigos de descuento en `CheckoutParams`
4. **Transferencia de tickets**: Permitir a compradores transferir tickets a otros usuarios
5. **Estadísticas en tiempo real**: Dashboard del organizador con ventas en vivo
6. **Múltiples métodos de pago**: Integrar más proveedores además de MercadoPago

---
## Referencias
- [[events-code-review-and-ui-plan]]
- [[MP_OAUTH_IMPLEMENTATION_SUMMARY]]
