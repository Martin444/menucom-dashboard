# Reglas del Proyecto

## Comportamiento del Asistente Local
- Eres un agente autónomo de programación que se comunica con el sistema mediante herramientas integradas.
- CRÍTICO: Nunca imprimas texto estructurado en formato JSON `{"name": "...", "arguments": ...}` en tus respuestas de chat para el usuario.
- Si necesitas usar una herramienta como `task`, `write`, `edit` o `read`, utilízalas llamando a la función nativa del sistema, no redactes el JSON manualmente en la pantalla.
- Responde siempre al usuario usando texto plano fluido y amigable en español.

## Estilo y Diseño
- Todos los iconos deben usar `FluentIcons` del paquete `fluentui_system_icons`. No usar iconos de Material Design (`Icons.*`).
- **Prohibido** usar métodos privados que retornen Widgets (`_buildSeccion()`). Cada sección de UI debe ser un widget público independiente, preferiblemente en `pu_material` siguiendo Atomic Design:
  - `atoms/` → bloques básicos (botón, texto, ícono, input)
  - `molecules/` → combinación de atoms (tarjeta, header simple, badge)
  - `organisms/` → sección funcional compleja (grid, tabla, formulario, sidebar)
  - `widgets/` → wrappers técnicos (responsive builder, network image)
  - `features/` → templates y páginas completas por dominio
- Si un componente depende de tipos del feature (`CatalogModel`, `CatalogsController`, `GetX`), vive en `lib/features/<feature>/presentation/widgets/` como widget público.
- Si un componente es puramente visual (sin dependencias de feature), vive en `pu_material`.

## Control de Calidad
- Antes de cualquier cambio importante de UI o lógica, ejecutar `flutter analyze` y corregir todos los errores y warnings antes de finalizar.

## Reglas de GetX (aprendidas del refactor de home)

### Registrar controladores
- Usar `Get.lazyPut(() => MiController(), fenix: true)` para controladores que deben sobrevivir a `Get.offAllNamed()` (navegación que destruye y recrea rutas).
- NO usar `GetBuilder(init: Get.find<T>())` — el parámetro `init:` con `assignId: true` puede re-disparar `onInit()` en GetX 5.x. Preferir `GetBuilder(builder: ...)` sin `init:` cuando el controller ya está registrado vía binding.
- NO hacer `Get.find<T>()` en `initState` si un `GetBuilder<T>` en el `build` ya lo va a resolver.

### No duplicar controladores
- Antes de crear un controlador nuevo, verificar si ya existe uno en el proyecto con la misma responsabilidad (ej: `CatalogsController` en `lib/features/catalogs/getx/`).
- Un controlador duplicado que carga los mismos datos que uno existente causa bugs de sincronización: la UI lee de un controller, la lógica escribe en otro.

### Orquestador + sub-controladores
- Al extraer lógica de un God Object a sub-controladores, mantener el controlador original como fachada con getters delegados para retrocompatibilidad.
- Usar `ever(subController.rxValue, (_) => update())` en el orquestador para propagar cambios reactivos a `GetBuilder`/`GetView`.
- No cargar datos desde el orquestador que las vistas ya cargan por sí mismas (ej: catálogos desde `menu_home_view.initState`).

### Flutter web + GetX
- `WidgetsBinding.instance.addPostFrameCallback` se comporta igual en web que en native.
- El guard `_isLoadingInternal` en métodos async debe siempre liberarse en `catch` y `finally` para evitar deadlocks.

### Mapeo businessType → context en creación de comercio
- `context` (requerido) debe ser un valor del enum `BusinessContext`: `restaurant`, `wardrobe`, `marketplace`, `general`, `events`.
- `businessType` (opcional) es un string libre como `food`, `clothes`, etc.
- **Nunca** usar `type.roleType.name` como `context`. Usar siempre `RolesFuncionts.toBusinessContext(type.roleType).value`.
- El mapeo completo está en `menu_dart_api/lib/by_feature/user/get_me_profile/model/roles_users.dart:69-94`.

### Bindings que se comparten entre rutas
- Si un `Binding` se aplica en múltiples rutas (ej: `CatalogsBinding` en crear/editar catálogo), usar `Get.put` con `permanent: true` + guard `isRegistered` para no reemplazar la instancia existente al navegar.
- `Get.put` sin `permanent` destruye el controller al hacer pop de la ruta; si otra ruta aún lo necesita, los datos se pierden.

---

## Alineación con la Misión: Profesionalización del Emprendedor

> Misión global: **Convertir a los Emprendedores en profesionales**

### Rol del Dashboard en la Misión

El dashboard es la **herramienta de gestión profesional** del emprendedor. Es donde opera su negocio: crea productos, recibe pedidos, analiza resultados. Si el dashboard es limitado, el emprendedor opera informalmente.

### Lo que ya aportamos a la misión
- ✅ Gestión de productos y catálogos con fotos, precios, atributos
- ✅ Recepción y gestión de órdenes con desglose financiero
- ✅ Métricas básicas de órdenes (ingresos, cantidades)
- ✅ Perfil de negocio básico (nombre, logo, descripción)
- ✅ Membresía con planes y billing
- ✅ Vincular MercadoPago para cobrar
- ✅ Compartir link y QR del catálogo
- ✅ Soporte multi-rol (food, clothes, service, events, admin)
- ✅ Notificaciones push (FCM)

### Lo que falta (gaps del dashboard)

| Gap | Impacto en misión | Estado actual | Prioridad |
|-----|-------------------|--------------|-----------|
| **BusinessProfile editor** | Un profesional completa su perfil: horarios, redes, certificaciones | No existe | 🔴 Alta |
| **CRM / Clientes** | Un profesional conoce a sus clientes | Menú "Clientes" = "Próximamente" | 🔴 Alta |
| **Facturación / Comprobantes** | Un profesional factura | No existe | 🔴 Alta |
| **Analytics / BI** | Un profesional decide con datos | Solo métricas básicas de órdenes | 🔴 Alta |
| **Onboarding Wizard** | Un profesional se configura guiadamente | No existe | 🔴 Alta |
| **Promociones / Descuentos** | Un profesional promociona | No existe | 🟡 Media |
| **Inventario** | Un profesional gestiona stock | Solo campo quantity | 🟡 Media |
| **Reseñas (moderar/responder)** | Un profesional gestiona su reputación | No existe | 🟡 Media |
| **Agenda / Turnos** | Un profesional de servicios agenda | No existe | 🟡 Media |
| **Equipo / Empleados** | Un profesional con equipo lo gestiona | No existe | 🟡 Media |

### Reglas para nuevas features en el dashboard

```dart
// CHECKLIST: ¿Esta feature profesionaliza al emprendedor?
// 1. ¿Le da control sobre su negocio?
// 2. ¿Le aporta datos para mejorar?
// 3. ¿Le permite atender mejor a sus clientes?
// 4. ¿Cumple con requisitos legales/fiscales?
// 5. ¿Le permite delegar/automatizar?
```

### Impacto Cross-Project
| Feature | API | Catalog PWA | Dashboard | Landing |
|---------|-----|------------|-----------|---------|
| BusinessProfile | CRUD | Display | Editor | — |
| Reseñas | CRUD | Formulario | Moderar | Widget |
| CRM | Endpoints | — | Lista clientes | — |
| BI | Endpoints | — | Widgets/charts | — |
| Onboarding | Endpoint | — | Wizard UI | — |

### Documentos relacionados
- `docs/MISSION-ALIGNMENT.md` — Análisis completo de misión (cross-project)
