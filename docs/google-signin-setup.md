---
tags:
  - google-signin
  - authentication
  - firebase
  - oauth
aliases:
  - Google Sign-In
  - Configuración Google Sign-In
  - Google Auth Setup
---

# Configuración de Google Sign-In — MenuCom Dashboard

## Descripción General

Google Sign-In está **completamente integrado** en MenuCom Dashboard para la plataforma web. Este documento consolida toda la configuración necesaria: desde la obtención de Client IDs en Google Cloud Console hasta la implementación del flujo de autenticación social con el backend.

## Google Cloud Console — OAuth 2.0 Client IDs

### Acceder al Proyecto

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona el proyecto `menucom-ff087` (ID: `1053737382833`)

### Crear OAuth 2.0 Client IDs

#### Web
1. **APIs & Services** > **Credentials** > **+ CREATE CREDENTIALS** > **OAuth client ID**
2. Tipo: **Web application**
3. Nombre: `MenuCom Dashboard Web`
4. **Authorized JavaScript origins**:
   - `http://localhost:3000` (desarrollo)
   - `https://your-domain.com` (producción)
5. **Authorized redirect URIs**:
   - `http://localhost:3000` (desarrollo)
   - `https://your-domain.com` (producción)

#### iOS
1. Tipo: **iOS**
2. Nombre: `MenuCom Dashboard iOS`
3. **Bundle ID**: `com.pickmeup.menucomdashboard`

#### Android
1. Tipo: **Android**
2. Nombre: `MenuCom Dashboard Android`
3. **Package name**: `com.pickmeup.menucomdashboard`
4. **SHA-1 certificate fingerprint**: obtener con `flutter doctor -v`

### Client ID Real (Web)

```
1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com
```

## Variables de Entorno

### .env

```env
GOOGLE_SIGN_IN_WEB_CLIENT_ID=1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com
GOOGLE_SIGN_IN_IOS_CLIENT_ID=1053737382833-your-ios-client-id.apps.googleusercontent.com
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=1053737382833-your-android-client-id.apps.googleusercontent.com
FIREBASE_IOS_BUNDLE_ID=com.pickmeup.menucomdashboard
```

### Launch Configurations (.vscode/launch.json)

Todas las configuraciones (`dev`, `qa`, `beta`) incluyen:

```
--dart-define=GOOGLE_SIGN_IN_WEB_CLIENT_ID=...
--dart-define=GOOGLE_SIGN_IN_IOS_CLIENT_ID=...
--dart-define=GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=...
--dart-define=FIREBASE_IOS_BUNDLE_ID=...
```

### Comando de Ejecución

```bash
flutter run -d chrome --dart-define-from-file=.env
```

## Firebase Web Configuration (web/index.html)

### Meta Tag para Google Sign-In

```html
<meta name="google-signin-client_id" content="1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com">
```

### Firebase SDKs (v10.12.2)

```html
<script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore-compat.js"></script>
```

### Google APIs

```html
<script src="https://apis.google.com/js/api.js"></script>
```

### Firebase Configuration Object

```html
<script>
  const firebaseConfig = {
    apiKey: "AIzaSyAEWpBCNon00zwt1eWfqSDiYMhH0xxLMwk",
    authDomain: "menucom-ff087.firebaseapp.com",
    projectId: "menucom-ff087",
    storageBucket: "menucom-ff087.firebasestorage.app",
    messagingSenderId: "1053737382833",
    appId: "1:1053737382833:web:d4173f40d6b88a52900390",
    measurementId: "G-D5ZC2VB6GR"
  };
  firebase.initializeApp(firebaseConfig);
</script>
```

### Estructura Completa del index.html

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Administracion para Menu com">

  <!-- Google Sign-In Configuration -->
  <meta name="google-signin-client_id" content="1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com">

  <title>Menucom dashboard</title>
  <link rel="manifest" href="manifest.json">

  <!-- Firebase SDKs -->
  <script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-auth-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore-compat.js"></script>

  <!-- Google APIs -->
  <script src="https://apis.google.com/js/api.js"></script>

  <!-- Firebase Configuration -->
  <script>
    const firebaseConfig = { /* ... */ };
    firebase.initializeApp(firebaseConfig);
  </script>

  <script src="flutter.js" defer></script>
</head>
<body>
  <!-- Contenido de la aplicación -->
</body>
</html>
```

## People API

La **People API** debe estar habilitada para que Google Sign-In obtenga información del perfil del usuario (nombre, email, foto).

### Habilitar People API

1. Ve a **APIs & Services** > **Library** en Google Cloud Console
2. Busca "People API"
3. Click en **"ENABLE"**

**Enlace directo:**
https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=1053737382833

### APIs Requeridas

- Identity and Access Management (IAM) API
- Google Sign-In API
- People API

Después de habilitar, esperar 2-3 minutos para propagación.

## Implementación en Código

### Firebase Config (firebase_config.dart)

```dart
// Nuevas funciones agregadas
static String get googleSignInWebClientId
static String get googleSignInIosClientId
static String get googleSignInAndroidClientId
static String get iosBundleId
```

### Google Sign-In Initialization (auth_firebase_datasource.dart)

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: FirebaseConfig.googleSignInWebClientId,
);
```

### Google Sign-In Button Widget

**Archivo:** `lib/features/auth/presentation/widgets/google_signin_button.dart`

- Widget Material3 responsivo
- Integración con AuthController
- Manejo de estados (loading, success, error)
- Soporte completo para web platform

```dart
GoogleSignInButton(
  onPressed: () => controller.signInWithGoogle(),
)
```

### AuthController (login_controller.dart)

```dart
await loginWithSocialUsecase.execute(
  provider: SocialProvider.google,
);
```

## SocialLoginUseCase — Flujo de Autenticación

### Token Flow Completo

1. **Google Sign-In** → `googleAuth.idToken`
2. **Firebase Auth** → `user.getIdToken()` (Firebase ID Token)
3. **Backend Validation** → `socialLoginResponse.accessToken` (JWT del sistema)
4. **Storage** → `ACCESS_TOKEN` y `SharedPreferences`

### Implementación en LoginController

```dart
// Antes (implementación temporal con TODO)
ACCESS_TOKEN = firebaseToken;

// Después (integración completa con SocialLoginUseCase)
final socialLoginUseCase = SocialLoginUseCase();
final socialLoginResponse = await socialLoginUseCase.execute(
  firebaseIdToken: firebaseToken,
  additionalData: {
    'email': user.email,
    'name': user.displayName,
    'photoURL': user.photoURL,
    'provider': 'google',
  },
);
ACCESS_TOKEN = socialLoginResponse.accessToken;
```

### Manejo de Errores

```dart
try {
  final socialLoginResponse = await socialLoginUseCase.execute(/*...*/);
} catch (e) {
  String errorMessage = 'Error al autenticar con el servidor.';
  if (e is ApiException) {
    errorMessage = e.message;
  }
  Get.snackbar(/*...*/);
}
```

### Arquitectura

| Capa | Componente | Rol |
|------|-----------|-----|
| Frontend (Flutter) | `LoginController.loginWithGoogle()` | Inicia Google Sign-In, obtiene token Firebase |
| API Layer | `SocialLoginUseCase` | Lógica de negocio de autenticación social |
| API Layer | `SocialLoginProvider` | Petición HTTP al backend |
| API Layer | `SocialLoginRepository` | Contrato de comunicación |
| Backend | `POST /auth/social/login` | Valida token Firebase, devuelve JWT del sistema |

### Dependencias (pubspec.yaml)

```yaml
firebase_auth: ^4.19.4
google_sign_in: ^6.1.5
google_sign_in_web: ^0.12.1
```

### Debugging

```bash
flutter run --debug
# Buscar en consola: 🔐, ✅, ❌, 📧
```

## Testing

### Comandos de Verificación

```bash
flutter analyze lib/features/auth/
flutter analyze lib/features/login/controllers/
flutter run -d chrome --dart-define-from-file=.env
flutter run --dart-define=GOOGLE_SIGN_IN_WEB_CLIENT_ID=test
```

### Casos de Prueba

1. Login exitoso con Google
2. Cancelación del usuario en Google Sign-In
3. Error de red durante la autenticación
4. Token inválido del backend
5. Respuesta malformada del servidor

## Estado y Checklist de Verificación

- [x] Variables de entorno configuradas
- [x] Launch configurations actualizadas
- [x] Código actualizado para usar Client IDs dinámicos
- [x] Meta tag en web/index.html agregado
- [x] Google Client ID real configurado
- [x] Firebase SDKs cargados (v10.12.2)
- [x] Google APIs incluidas
- [x] Firebase config inicializado
- [x] GoogleSignIn inicializándose correctamente
- [x] Firebase Authentication funcionando
- [x] SocialLoginUseCase integrado correctamente
- [x] Manejo de errores implementado
- [x] Sin errores de compilación
- [x] Compatible con Clean Architecture + GetX
- [ ] Habilitar People API en Google Cloud Console
- [ ] Probar Google Sign-In funcionando completamente

## Errores Resueltos

| Error | Estado |
|-------|--------|
| `ClientID not set` | ✅ Resuelto — Client ID configurado |
| `[firebase_auth/configuration-not-found]` | ✅ Resuelto — Firebase inicializado |
| `gapi.client library is not loaded` | ✅ Resuelto — Google APIs cargadas |
| `People API has not been used` | ⏳ Pendiente — Habilitar People API |

## Notas Importantes

- Los Client IDs son diferentes para cada plataforma (Web, iOS, Android)
- Los Client IDs deben coincidir exactamente con la configuración en Google Cloud Console
- Para producción, agregar los dominios correctos en las "Authorized origins"
- Mantén los Client IDs seguros y no los commitees en repositorios públicos
- La configuración web usa datos reales del proyecto, no placeholders
- Los scripts de Firebase usan la versión compatible `-compat` para integración con Flutter

---

## Referencias Cruzadas

- [[auth-architecture]]
- [[FIREBASE_SETUP]]
- [[implementation/FCM-INTEGRATION]]
