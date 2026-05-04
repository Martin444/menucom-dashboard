# Informe de Revisión: Manejo de Errores en Formularios

**Fecha:** 2026-05-03  
**Alcance:** Login, Registro, Recuperación de Contraseña, y otros formularios

---

## 1. Estado Actual y Problemas Encontrados

### 1.1 Login (login_page.dart / auth_controller.dart)

**Problema original:**
- Cuando la API devolvía 404 ("No se encontró un usuario con este email"), el mensaje se mostraba como "Error de internet" en un snackbar genérico.
- El error 404 se asignaba a `errorTextPassword` en lugar de `errorTextEmail`.
- La excepción `AuthException` tenía un `toString()` que agregaba el prefijo "Error de autenticación:".
- En `login_with_credentials_usecase.dart`, las excepciones se envolvían con prefijos adicionales.

**Comportamiento anterior:**
```
Error en login con email/password: AuthException: Error de autenticación: No se encontró un usuario con este email
```
(mostraba snackbar con "Error de internet")

**Comportamiento actual (corregido):**
- Error 401 (unauthorized) → Se muestra en `errorTextPassword` con el mensaje real de la API.
- Error 404 (not_found) → Se muestra en `errorTextEmail` con el mensaje real de la API.
- No se muestra snackbar para errores de campos (solo para errores de red).

---

### 1.2 Registro de Comercio (auth_controller.dart - registerCommerce)

**Estado actual:**
```dart
catch (e) {
  isRegistering.value = false;
  debugPrint('Error en registro: $e');
  Get.snackbar(
    'Error en registro',
    'No se pudo completar el registro. Inténtalo de nuevo.',
    backgroundColor: Colors.red,
    colorText: Colors.white,
  );
}
```

**Problemas:**
1. **Mensaje genérico:** No usa el mensaje real de la API (ej. "Ya existe una cuenta con este email" para error 409).
2. **No distingue tipos de error:** Todos los errores muestran el mismo snackbar genérico.
3. **No asigna errores a campos específicos:** `errorTextName`, `errorTextPhone`, etc. no se usan en el catch.

**Recomendación:** Implementar manejo similar al login:
- Error 409 (conflict) → `errorTextEmail` = mensaje de la API.
- Error 400 (validation) → Asignar a campos correspondientes.
- Solo mostrar snackbar para errores de red.

---

### 1.3 Recuperación de Contraseña (auth_controller.dart)

**Estado actual:**

**verifyEmailUser():**
```dart
catch (e) {
  if (e is ApiException) {
    if (e.statusCode == 404) {
      errorEmailRecovery.value = 'Este usuario no se encuentra registrado';
    }
  }
}
```
✅ **Correcto:** El error 404 se muestra en el campo de email.

**validateCodeOtp():**
```dart
catch (e) {
  if (e is ApiException) {
    if (e.statusCode == 409) {
      errorCodeRecovery.value = 'Código inválido';
    }
  }
}
```
✅ **Correcto:** El error 409 se muestra en el campo de código.

---

### 1.4 Login con Google/Apple (auth_controller.dart)

**Estado actual:**
```dart
catch (e) {
  debugPrint('Error en login con Google: $e');
  Get.snackbar(
    'Error',
    'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.red,
    colorText: Colors.white,
  );
}
```

**Problemas:**
1. **Mensaje genérico:** No usa el mensaje real de la API.
2. **Siempre muestra snackbar:** Incluso para errores que deberían manejarse de otra forma.

---

### 1.5 Cambio de Contraseña (auth_controller.dart - changePassword)

**Estado actual:**
```dart
catch (e) {
  debugPrint('Error al cambiar contraseña: $e');
  rethrow;
}
```

**Problema:** No hay manejo de errores específicos en el UI. El `rethrow` delega el manejo a quien llame el método.

---

## 2. Correcciones Aplicadas

### 2.1 auth_remote_datasource.dart
- ✅ Agregado `on AuthException { rethrow; }` y `on ValidationException { rethrow; }` para no convertir errores de la API en errores de red.

### 2.2 login_with_credentials_usecase.dart
- ✅ Cambiado el `throw AuthException('Error de autenticación: ${e.message}')` por `rethrow` para preservar el mensaje original.
- ✅ Corregido `toString()` de `AuthException` para no agregar prefijo: `'AuthException: $message...'` → `'$message...'`.

### 2.3 auth_controller.dart - loginWithEmailAndPassword()
- ✅ Error 404 (not_found) → `errorTextEmail` (campo de email).
- ✅ Error 401 (unauthorized) → `errorTextPassword` (campo de contraseña).
- ✅ Errores de validación → Campos correspondientes.
- ✅ **No se muestra snackbar** para errores de campos (solo para errores de red).

---

## 3. Pendientes y Recomendaciones

### 3.1 Registro de Comercio (registerCommerce)
- [ ] Usar mensajes reales de la API (error 409 → "Ya existe una cuenta con este email").
- [ ] Asignar errores a campos específicos (`errorTextName`, `errorTextPhone`, `errorTextEmail`).
- [ ] Solo mostrar snackbar para errores de red.

### 3.2 Login Social (Google/Apple)
- [ ] Usar mensajes reales de la API en lugar de genéricos.
- [ ] Manejar errores específicos (ej. cuenta ya existe, error de permisos).

### 3.3 Cambio de Contraseña (changePassword)
- [ ] Agregar manejo de errores en el UI (ej. contraseña inválida, token expirado).

### 3.4 Otros Formularios
Revisar y aplicar el mismo patrón en:
- `users_controller.dart` (según grep, tiene múltiples snackbars).
- `billing_details_dialog.dart` (snackbars genéricos).
- `user_dialog_handlers.dart` (snackbars genéricos).

---

## 4. Patrón Recomendado para Formularios

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

## 5. Resumen de Archivos Modificados

| Archivo | Cambios |
|--------|---------|
| `lib/features/auth/data/datasources/auth_remote_datasource.dart` | `rethrow` para AuthException/ValidationException |
| `lib/features/auth/domain/usecases/login_with_credentials_usecase.dart` | `rethrow` en lugar de envolver excepción |
| `lib/features/auth/presentation/controllers/auth_controller.dart` | Manejo de errores por campos, sin snackbar para errores de UI |

---

## 6. Próximos Pasos

1. Aplicar el patrón corregido al registro de comercio.
2. Aplicar el patrón a login social (Google/Apple).
3. Revisar `users_controller.dart` y otros controladores con snackbars genéricos.
4. Hacer una prueba end-to-end para verificar que los mensajes de la API se muestren correctamente en los campos correspondientes.
