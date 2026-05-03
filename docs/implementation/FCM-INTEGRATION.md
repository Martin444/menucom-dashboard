# Integración de Firebase Cloud Messaging (FCM)

Esta documentación describe cómo se gestiona la sincronización de los tokens de FCM entre el cliente (Dashboard) y el backend.

## Arquitectura

La integración se divide en tres partes:
1.  **Submódulo API (`menu_dart_api`)**: Provee el caso de uso y el proveedor para realizar la petición al backend.
2.  **Utilidad de FCM (`lib/core/fcm_util.dart`)**: Encapsula la lógica de Firebase Messaging, permisos y manejo de tokens.
3.  **Controladores y Main**: Orquestan la llamada a la sincronización cuando el usuario está autenticado.

## Flujo de Datos

### 1. Obtención del Token
Se utiliza la clase `FirebaseMessaging` para solicitar permisos y obtener el token único del dispositivo.

### 2. Sincronización con el Backend
Se utiliza el endpoint `PATCH /user/fcm-token`.

**Request Body:**
```json
{
  "fcmToken": "string"
}
```

### 3. Puntos de Sincronización
El token se sincroniza en los siguientes escenarios:
-   **Inicio de la aplicación**: Si existe una sesión activa (`access_token` en secure storage), se dispara la sincronización.
-   **Login exitoso**: Ya sea por email/password o social login (Google/Apple), el `AuthController` dispara la sincronización.
-   **Refresco de token**: Si Firebase genera un nuevo token mientras la app está en uso, se captura mediante `onTokenRefresh` y se envía al backend.

## Implementación Técnica

### Submódulo API
El proveedor utiliza `dio` para realizar un `PATCH` al endpoint correspondiente, incluyendo el token de acceso en la cabecera `Authorization`.

```dart
final response = await dio.Dio().patch(
  '${API.defaulBaseUrl}/user/fcm-token',
  data: { 'fcmToken': fcmToken },
  options: Options(headers: { 'Authorization': 'Bearer ${API.loginAccessToken}' }),
);
```

### Utilidad de FCM
La función `setupFCM` en `lib/core/fcm_util.dart` maneja la inicialización. Utiliza un flag interno `_fcmInitialized` para asegurar que los listeners de mensajes y refresco de token se registren una sola vez, evitando fugas de memoria o ejecuciones duplicadas.

### AuthController
En `AuthController`, el método `_syncFcmToken` se encarga de llamar a `setupFCM` pasando un callback que ejecuta el `UpdateFcmTokenUseCase`.

```dart
void _syncFcmToken() {
  setupFCM(
    onTokenReceived: (fcmToken) async {
      final updateUseCase = UpdateFcmTokenUseCase(UpdateFcmTokenProvider());
      await updateUseCase.execute(fcmToken: fcmToken);
    },
  );
}
```

## Consideraciones de Seguridad
- El token de FCM solo se envía si existe un `access_token` válido.
- Se utiliza `flutter_secure_storage` para persistir la sesión, lo que garantiza que el token de acceso esté disponible para la sincronización tras un reinicio de la app.
