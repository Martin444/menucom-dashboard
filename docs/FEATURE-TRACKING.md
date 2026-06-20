# Feature Tracking — Dashboard Menucom

> Plan de features alineado con la misión: **Convertir a los Emprendedores en profesionales**

---

## Fase 1: CRM / Clientes

**Prioridad:** Alta | **Estado:** Completado

**API:** `GetUsersByRolesUseCase`, `UserByRoleModel`, `UsersByRolesResponse`

**Archivos creados:**
- [x] `lib/routes/routes.dart` — Ruta `CLIENTS = '/clientes'`
- [x] `lib/routes/pages.dart` — `GetPage` registrado con `AuthMiddleware` + `ClientsBinding`
- [x] `lib/core/navigation/menu_navigation_items.dart` — `clients` activado, visible para food/clothes/retail/events/admin
- [x] `lib/core/navigation/menu_navigation_controller.dart` — Navegación a `/clientes`
- [x] `lib/features/clients/getx/clients_binding.dart`
- [x] `lib/features/clients/getx/clients_controller.dart`
- [x] `lib/features/clients/presentation/views/clients_view.dart` — Layouts mobile + desktop
- [x] `lib/features/clients/presentation/widgets/clients_data_table.dart`
- [x] `lib/features/clients/presentation/widgets/clients_filter_panel.dart`
- [x] `lib/features/clients/presentation/widgets/clients_kpi_panel.dart`
- [x] `lib/features/clients/presentation/widgets/client_detail_dialog.dart`
- [x] `lib/features/clients/presentation/widgets/clients_empty_state.dart`

---

## Fase 2: Business Profile Editor

**Prioridad:** Alta | **Estado:** Completado

**API:** `UpdateCommerceUseCase`, `GetMyCommercesUseCase`, `UploadFileUsesCase`

**Archivos creados:**
- [x] `lib/routes/routes.dart` — Ruta `BUSINESS_PROFILE = '/editar-negocio'`
- [x] `lib/routes/pages.dart` — `GetPage` registrado
- [x] `lib/features/profile/presentation/controllers/business_profile_controller.dart` — Manejo de formulario, imágenes, guardado
- [x] `lib/features/profile/presentation/views/business_profile_page.dart` — Editor con secciones:
  - Imágenes (logo + portada con picker y previsualización)
  - Información básica (nombre, slug, descripción)
  - Contacto (teléfono, dirección)
  - Redes sociales (Instagram, Facebook, web)
- [x] `lib/features/home/presentation/widget/head_dinning.dart` — Botón de edición en el header

**Acceso:** Botón de editar en el header del home (visible para dueños de negocio), ruta `/editar-negocio`

---

## Fase 3: Unificación de Auth + Nuevos Endpoints

**Prioridad:** Alta | **Estado:** Completado

### Unificación (3 usecases migrados)
| Dashboard (antes) | API (ahora) |
|---|---|
| `LoginWithCredentialsUseCase` + `AuthRepositoryImpl` | `LoginUserUseCase` + `GetDinningUseCase` |
| `LoginWithSocialUseCase` + `AuthRepositoryImpl` | `SocialLoginUseCase` + `AuthFirebaseDataSource` |
| `GetCurrentUserUseCase.executeWithRefresh()` | `RefreshTokenUseCase` |

### Archivos eliminados (10)
`auth_repository_impl.dart`, `auth_remote_datasource.dart`, `auth_request_model.dart`, `auth_response_model.dart`, `login_with_credentials_usecase.dart`, `login_with_social_usecase.dart`, `register_user_usecase.dart`, `get_current_user_usecase.dart`, `logout_usecase.dart`, `auth_repository.dart`

### Excepciones extraídas
`auth_exceptions.dart` — `ValidationException`, `AuthException`, `NetworkException`

### Nuevos endpoints integrados
- [x] `switch_context` + `my_contexts` — `context_switcher_molecule.dart` en el header del home
- [ ] `health` (FirebaseHealthUseCase) — baja prioridad, diagnóstico

**Prioridad:** Alta | **Estado:** Pendiente

**API:** `AppDataService`, `CreateCommerceUseCase`, `CreateCatalogUseCase`, `UploadFileUsesCase`  
**pu_material:** `EventCreateTemplate` (patrón wizard), `ButtonPrimary`, `ButtonSecundary`, `PUInput`, `PUInputDropDown`, `ContainerAtom`, `HeroSectionAtom`, `ProgressDot`

---

## Fase 5: Promociones / Descuentos

**Prioridad:** Media | **Estado:** Pendiente

---

## Fase 6: Inventario / Stock Management

**Prioridad:** Media | **Estado:** Pendiente

---

## Fase 7: Reseñas / Reputación

**Prioridad:** Media | **Estado:** Pendiente (requiere API backend)
