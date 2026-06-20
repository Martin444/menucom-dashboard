---
tags:
  - domain/auth
  - repo/dashboard
  - type/architecture
  - status/completed
aliases:
  - Auth Architecture Dashboard
  - Arquitectura de Autenticación
  - Auth Unificación
  - Login Flow Review
  - Error Handling Auth
  - UX Login Registro
---

# Arquitectura de Autenticación — Documentación Consolidada

**Estado:** ✅ Sistema Seguro y Estabilizado (Mayo 2026)

---

## 1. Arquitectura de Seguridad

### 1.1 Almacenamiento Seguro de Tokens

- Se reemplazó `SharedPreferences` por `flutter_secure_storage` para el token de acceso.
- Variable global mutable `ACCESS_TOKEN` en `config.dart` eliminada.
- Clave de almacenamiento unificada: `'access_token'` en todos los controladores y datasources.
- `AuthController` es la única fuente de verdad para el estado de sesión.

### 1.2 Middleware Inteligente

- `AuthMiddleware` y `GuestMiddleware` sincronizados con `authController.isAuthenticated`.
- Utilizan `PURoutes` para redirecciones consistentes (constantes, no strings hardcoded).
- Validación activa contra el backend durante inicialización.

| Middleware | Condición | Destino | Estado |
|------------|-----------|---------|--------|
| `AuthMiddleware` | No autenticado | `PURoutes.LOGIN` | ✅ |
| `GuestMiddleware` | Ya autenticado | `PURoutes.HOME` | ✅ |
| `AuthController.logout()` | Siempre | `PURoutes.LOGIN` | ✅ |
| `ChangePasswordPage` | Éxito | `PURoutes.LOGIN` | ✅ |

### 1.3 Sincronización FCM

- Token de Firebase Cloud Messaging sincronizado automáticamente con el backend (`PATCH /user/fcm-token`).
- Gestiona refresco de tokens al iniciar la app y al realizar login exitoso.

### 1.4 Archivos Clave

- `lib/features/auth/presentation/controllers/auth_controller.dart`
- `lib/features/auth/presentation/middlewares/auth_middleware.dart`
- `lib/features/auth/data/datasources/auth_local_datasource.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/domain/usecases/login_with_credentials_usecase.dart`
- `lib/routes/routes.dart`

---

## 2. Flujo de Login — Seguridad y Control de Errores

### 2.1 Login Robusto

- Integra casos de uso del dominio de forma segura.
- Persiste token en almacenamiento encriptado.
- Maneja errores con mensajes genéricos para el usuario mientras loguea detalles técnicos internamente.

### 2.2 Login con Google y Social

- Integra Firebase Authentication de forma unificada.
- Preparado para sincronizar con el backend mediante `SocialLoginUseCase`.
- Realiza logout de Firebase correctamente.

### 2.3 Correcciones de Seguridad Aplicadas

| Aspecto | Estado Anterior | Estado Actual |
|---------|-----------------|---------------|
| Storage | SharedPreferences (inseguro) | SecureStorage (encriptado) ✅ |
| Variables globales | `ACCESS_TOKEN` mutable | Estado encapsulado en `AuthController` ✅ |
| Rutas | Hardcoded (`/login`, `/dashboard`) | Constantes (`PURoutes.LOGIN`, `PURoutes.HOME`) ✅ |
| Componentes | Ad-hoc (`BotonSecundary`, etc.) | Estandarizados en `pu_material` ✅ |
| Análisis estático | >300 errores críticos | 0 errores críticos ✅ |

---

## 3. Manejo de Errores en Formularios

### 3.1 Login (Corregido ✅)

| Código HTTP | Campo destino | Mensaje |
|-------------|---------------|---------|
| 401 (unauthorized) | `errorTextPassword` | Mensaje real de la API |
| 404 (not_found) | `errorTextEmail` | Mensaje real de la API |

- Snackbar solo para errores de red, no para errores de campos.

### 3.2 Correcciones en Datasource y UseCase

- **`auth_remote_datasource.dart`**: `on AuthException { rethrow; }` y `on ValidationException { rethrow; }` para no convertir errores de API en errores de red.
- **`login_with_credentials_usecase.dart`**: Cambiado `throw AuthException('Error de autenticación: ${e.message}')` por `rethrow`.
- **`AuthException.toString()`**: Corregido para no agregar prefijo `'AuthException: '`.

### 3.3 Recuperación de Contraseña (Correcto ✅)

- Error 404 → `errorEmailRecovery` = `'Este usuario no se encuentra registrado'`.
- Error 409 → `errorCodeRecovery` = `'Código inválido'`.

### 3.4 Pendientes

- [ ] **Registro de comercio (`registerCommerce`)**: Usar mensajes reales de API (error 409 → "Ya existe una cuenta con este email"), asignar a campos específicos.
- [ ] **Login social (Google/Apple)**: Mensajes reales de API, manejar errores específicos.
- [ ] **Cambio de contraseña (`changePassword`)**: Agregar manejo de errores en UI.
- [ ] **Revisar otros controladores**: `users_controller.dart`, `billing_details_dialog.dart`, `user_dialog_handlers.dart`.

### 3.5 Patrón Recomendado

```dart
Future<void> submitForm() async {
  try {
    isLoading.value = true;
    _clearError();

    // Validaciones locales
    if (emailController.text.isEmpty) {
      throw ValidationException('El email no puede estar vacío');
    }

    // Llamada a API
    final result = await _useCase.execute(params);

    // Éxito
    Get.offAllNamed(PURoutes.HOME);
  } catch (e) {
    isLoading.value = false;

    // Errores de campos - NO mostrar snackbar
    if (e is ValidationException) {
      if (e.message.contains('email')) {
        errorTextEmail.value = e.message;
      } else if (e.message.contains('password')) {
        errorTextPassword.value = e.message;
      }
      update();
      return;
    }

    if (e is AuthException) {
      if (e.code == 'unauthorized') {
        errorTextPassword.value = e.message.isNotEmpty ? e.message : 'Credenciales incorrectas';
        update();
        return;
      } else if (e.code == 'not_found') {
        errorTextEmail.value = e.message.isNotEmpty ? e.message : 'Usuario no encontrado';
        update();
        return;
      } else if (e.code == 'conflict') {
        errorTextEmail.value = e.message.isNotEmpty ? e.message : 'Ya existe una cuenta con este email';
        update();
        return;
      }
    }

    // Solo errores NO relacionados a campos - mostrar snackbar
    final errorMessage = _getErrorMessage(e);
    Get.snackbar(
      'Error',
      errorMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );

    update();
  }
}
```

---

## 4. Revisión UX/UI — Login y Registro

### 4.1 Login Page — Corregido (Sprint 1)

| # | Problema | Solución |
|---|----------|----------|
| 1 | `GetBuilder` rebuild completo | ✅ Cambiado a `Obx()` |
| 2 | Null safety inconsistente | ✅ `errorTextEmail` ahora `RxString` (no nullable) |
| 3 | `load` compartido entre botones | ✅ Agregado `isLoggingGoogle` separado |

### 4.2 Home Page — Corregido (Sprint 2)

| # | Problema | Solución |
|---|----------|----------|
| 1 | Variables NO reactivas | ✅ `isLoaginDataUser` y `everyListEmpty` ahora `RxBool` |
| 2 | `GetBuilder` sin `Obx` | ✅ Agregado `Obx()` para rebuilds mínimos |
| 3 | Múltiples `update()` innecesarios | ✅ Eliminados, `RxBool` ya notifica |

### 4.3 Pendientes UX

#### Login Page
- [ ] Spacing arbitrario (80, 30, 15, 10, 60) — crear constantes de spacing.
- [ ] `Hero` tag sin destino — usar o remover.
- [ ] Logo muy grande en móvil (90px) — hacer responsive.
- [ ] Agregar checkbox "Recordarme".
- [ ] Validación de email en tiempo real.
- [ ] Links a Términos y Condiciones.
- [ ] Toggle mostrar/ocultar contraseña (existe pero no se usa).

#### Home Page
- [ ] `debugPrint` en producción — remover o condicional.
- [ ] Skeleton loading en vez de spinner.
- [ ] Pull-to-refresh.
- [ ] Animaciones de transición entre roles.

#### Generales
- [ ] Aplicar spacing consistente.
- [ ] Unificar patrones de null safety.
- [ ] Crear variables de loading independientes.

### 4.4 Prioridades

1. **Sprint 1**: `GetBuilder` → `Obx`, loading states separados. ✅
2. **Sprint 2**: Error texts específicos por campo. ✅
3. **Sprint 3**: Mejoras UX (T&C, recordarme, etc.).

---

## 5. Deuda Técnica Resuelta

- **Inconsistencia de keys**: Se escribía en `secure_access_token` y se leía de `access_token`. Unificado.
- **Código huérfano**: Eliminados `injection_bindings.dart` y middlewares antiguos en `lib/core`.
- **Errores analíticos**: Corregidos cientos de errores (`PRoutes` → `PURoutes`, `ButtonSecondary`, `onSubmit` → `onSubmited`).

---

## 6. Resumen de Archivos Modificados

| Archivo | Cambios |
|---------|---------|
| `auth_remote_datasource.dart` | `rethrow` para AuthException/ValidationException |
| `login_with_credentials_usecase.dart` | `rethrow` en lugar de envolver excepción |
| `auth_controller.dart` | Manejo de errores por campos, sin snackbar para errores de UI |

---

## Referencias Cruzadas

- [[google-signin-setup]]
- [[MIGRATION_CATALOGS]]
- [[NETLIFY_VSCODE_SYNC]]
