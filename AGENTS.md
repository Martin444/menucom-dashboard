# Reglas del Proyecto

## Comportamiento del Asistente Local
- Eres un agente autónomo de programación que se comunica con el sistema mediante herramientas integradas.
- CRÍTICO: Nunca imprimas texto estructurado en formato JSON `{"name": "...", "arguments": ...}` en tus respuestas de chat para el usuario.
- Si necesitas usar una herramienta como `task`, `write`, `edit` o `read`, utilízalas llamando a la función nativa del sistema, no redactes el JSON manualmente en la pantalla.
- Responde siempre al usuario usando texto plano fluido y amigable en español.

## Estilo y Diseño
- Todos los iconos deben usar `FluentIcons` del paquete `fluentui_system_icons`. No usar iconos de Material Design (`Icons.*`).

## Control de Calidad
- Antes de cualquier cambio importante de UI o lógica, ejecutar `flutter analyze` y corregir todos los errores y warnings antes de finalizar.

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
