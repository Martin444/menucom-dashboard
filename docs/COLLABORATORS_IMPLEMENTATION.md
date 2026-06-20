# Colaboradores — Feature Tracking

> **Misión:** Un profesional delega y gestiona su equipo. Esta feature permite al dueño de un comercio invitar, gestionar roles y remover colaboradores.

---

## Estado: En progreso

**API:** `GetMyTeamUseCase`, `AssignRoleUseCase`, `RevokeRoleUseCase`, `UpdateRoleUseCase`
**Roles:** `owner`, `manager`, `staff` (a futuro: roles personalizados con permisos)

---

## Arquitectura

```
lib/features/collaborators/
└── presentation/
    ├── collaborators.dart                   ← barrel
    ├── bindings/
    │   └── collaborators_binding.dart       ← DI: UseCases → Controller
    ├── controllers/
    │   └── collaborators_controller.dart    ← GetX, 4 métodos principales
    ├── pages/
    │   └── collaborators_page.dart          ← responsive mobile/desktop
    └── widgets/
        ├── widgets.dart                     ← barrel
        ├── atoms/
        │   ├── collaborator_role_badge_atom.dart
        │   └── collaborator_empty_state_atom.dart
        ├── molecules/
        │   ├── collaborator_card_molecule.dart
        │   └── assign_role_dialog_molecule.dart
        └── organisms/
            ├── collaborator_table_organism.dart
            └── collaborator_kpi_organism.dart
```

---

## Checklist de Implementación

### Integración base
- [x] `lib/routes/routes.dart` — Ruta `COLLABORATORS = '/colaboradores'`
- [x] `lib/routes/pages.dart` — `GetPage` con `CollaboratorsBinding`, `MenuNavigationBinding`, `DinningBinding`
- [x] `lib/core/navigation/menu_navigation_items.dart` — Item `collaborators` en enum, config con `FluentIcons.people_team_24_regular`, visible para roles commerce

### Átomos
- [x] `collaborator_role_badge_atom.dart` — Badge color por rol (owner=amber, manager=blue, staff=green)
- [x] `collaborator_empty_state_atom.dart` — Empty state con icono y mensaje

### Moléculas
- [x] `collaborator_card_molecule.dart` — Card mobile con avatar, info, badges y acciones
- [x] `assign_role_dialog_molecule.dart` — Dialog con email + dropdown rol + botones

### Organismos
- [x] `collaborator_table_organism.dart` — AdminDataTableMolecule con TeamUser[]
- [x] `collaborator_kpi_organism.dart` — Wrap con 4 AdminKpiMolecule

### Controller y Binding
- [x] `collaborators_controller.dart` — loadTeam, assignRole, changeRole, removeCollaborator
- [x] `collaborators_binding.dart` — DI providers + use cases + controller

### Página
- [x] `collaborators_page.dart` — Responsive (desktop Row+sidebar / mobile Scaffold+drawer)

### QA
- [ ] `flutter analyze` — sin errores ni warnings

---

## Flujos

| Acción | Trigger | UX | API |
|--------|---------|----|-----|
| **Agregar** | Tap "+" en header | Dialog: email + dropdown rol → confirmar | `AssignRoleUseCase(userId, role, context: commerceId)` |
| **Cambiar rol** | Tap edit en fila | Dialog precargado → seleccionar nuevo rol | `RevokeRoleUseCase(old)` + `AssignRoleUseCase(new)` |
| **Desactivar/activar** | Toggle Switch | Cambio inmediato | `UpdateRoleUseCase(roleId, isActive: !current)` |
| **Remover** | Tap delete | Confirm dialog → remover | `RevokeRoleUseCase(userId, role, context)` |

---

## Pendientes futuros

- [ ] Roles personalizados con permisos configurables por el owner
- [ ] Búsqueda de usuarios por email en el backend (actualmente input manual)
- [ ] Paginación server-side cuando el equipo crezca
