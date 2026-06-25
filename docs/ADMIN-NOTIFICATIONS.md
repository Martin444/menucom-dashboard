# Admin Notifications - Implementación

> **Tracking document** para la implementación de la UI de notificaciones push para admin.
> La capa API (`menu_dart_api/by_feature/notifications/`) ya está completa (8 use cases, 6 endpoints).

## Alcance (solo admin)

- CRUD de templates de notificación push
- Listado de usuarios con FCM tokens registrados
- Envío de notificaciones: directas y desde template
- Acceso exclusivo para rol `admin`

## Estructura de archivos creada

```
lib/features/notifications/
├── getx/
│   ├── notifications_controller.dart    # Controller principal (templates, envío, usuarios)
│   └── notifications_binding.dart       # GetX Binding
└── presentation/
    ├── pages/
    │   ├── notifications_page.dart      # Página principal con tabs (Templates | Enviar)
    │   ├── templates_page.dart          # Lista de templates (CRUD)
    │   ├── create_template_page.dart    # Formulario crear/editar template
    │   └── send_notification_page.dart  # Formulario de envío
    └── widgets/
        ├── template_card.dart           # Card de template en lista
        ├── user_selector.dart           # Selector de usuarios con búsqueda
        └── template_preview.dart        # Preview de template con placeholders
```

## Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `lib/routes/routes.dart` | +3 rutas: `ADMIN_NOTIFICATIONS`, `ADMIN_NOTIFICATIONS_TEMPLATE_CREATE`, `ADMIN_NOTIFICATIONS_SEND` |
| `lib/routes/pages.dart` | +3 `GetPage` entries con `AdminMiddleware` |
| `lib/core/navigation/menu_navigation_items.dart` | +`notifications` enum entry, incluido en `getItemsByRole` para admin |
| `lib/core/navigation/menu_navigation_controller.dart` | Manejo de navegación para notificaciones admin |
| `lib/core/fcm_util.dart` | Mostrar notificaciones foreground como snackbar |

## API endpoints usados

| Endpoint | Use Case | Método UI |
|----------|----------|-----------|
| `GET /notifications/admin/templates` | Listar templates | TemplatesPage |
| `POST /notifications/admin/templates` | Crear template | CreateTemplatePage |
| `GET /notifications/admin/templates/:id` | Obtener template | CreateTemplatePage (modo edición) |
| `PATCH /notifications/admin/templates/:id` | Actualizar template | CreateTemplatePage (modo edición) |
| `DELETE /notifications/admin/templates/:id` | Soft-delete template | TemplatesPage (acción) |
| `GET /notifications/admin/users-with-tokens` | Listar usuarios con FCM | SendNotificationPage (selector) |
| `POST /notifications/admin/send` | Enviar notificación directa | SendNotificationPage |
| `POST /notifications/admin/send-from-template/:id` | Enviar desde template | SendNotificationPage |

## Checklist de implementación

- [x] Crear documentación de seguimiento
- [ ] Agregar rutas en `routes.dart` y `pages.dart`
- [ ] Agregar entrada de menú `notifications` para admin
- [ ] Crear `NotificationsController`
- [ ] Crear `NotificationsBinding`
- [ ] Crear `NotificationsPage` (tabs)
- [ ] Crear `TemplatesPage` (lista)
- [ ] Crear `CreateTemplatePage` (formulario)
- [ ] Crear `SendNotificationPage` (formulario)
- [ ] Crear widgets: `TemplateCard`, `UserSelector`, `TemplatePreview`
- [ ] Actualizar `fcm_util.dart` para foreground notifications
- [ ] Ejecutar `flutter analyze`
