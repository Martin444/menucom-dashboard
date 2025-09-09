# Configuración de Google Sign-In para MenuCom Dashboard

## Problema Actual
El error que estás viendo indica que falta configurar correctamente el Google Sign-In Client ID:

```
ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag, or pass clientId when initializing GoogleSignIn
```

## Solución: Obtener Google Client IDs

### 1. Acceder a Google Cloud Console
1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto: `menucom-ff087`
3. Ve a **APIs & Services** > **Credentials**

### 2. Crear OAuth 2.0 Client IDs
Necesitas crear Client IDs para cada plataforma:

#### Para Web:
1. Click en **+ CREATE CREDENTIALS** > **OAuth client ID**
2. Selecciona **Web application**
3. Nombre: `MenuCom Dashboard Web`
4. **Authorized JavaScript origins**:
   - `http://localhost:3000` (desarrollo)
   - `https://your-domain.com` (producción)
5. **Authorized redirect URIs**:
   - `http://localhost:3000` (desarrollo)
   - `https://your-domain.com` (producción)
6. Guarda el **Client ID** generado

#### Para iOS:
1. Click en **+ CREATE CREDENTIALS** > **OAuth client ID**
2. Selecciona **iOS**
3. Nombre: `MenuCom Dashboard iOS`
4. **Bundle ID**: `com.pickmeup.menucomdashboard`
5. Guarda el **Client ID** generado

#### Para Android:
1. Click en **+ CREATE CREDENTIALS** > **OAuth client ID**
2. Selecciona **Android**
3. Nombre: `MenuCom Dashboard Android`
4. **Package name**: `com.pickmeup.menucomdashboard`
5. **SHA-1 certificate fingerprint**: (obtén esto ejecutando `flutter doctor -v`)
6. Guarda el **Client ID** generado

### 3. Actualizar Variables de Entorno

Actualiza tu archivo `.env` con los Client IDs reales:

```env
# Google Sign-In Client IDs reales
GOOGLE_SIGN_IN_WEB_CLIENT_ID=1053737382833-xxxxxxxxx.apps.googleusercontent.com
GOOGLE_SIGN_IN_IOS_CLIENT_ID=1053737382833-yyyyyyyyy.apps.googleusercontent.com
GOOGLE_SIGN_IN_ANDROID_CLIENT_ID=1053737382833-zzzzzzzzz.apps.googleusercontent.com
```

### 4. Configuración Web Adicional

Agrega el siguiente meta tag en `web/index.html`:

```html
<!-- En la sección <head> -->
<meta name="google-signin-client_id" content="1053737382833-xxxxxxxxx.apps.googleusercontent.com" />
```

### 5. Verificar Configuración

Después de actualizar los Client IDs:

1. Reinicia tu aplicación Flutter
2. Prueba el login con Google
3. Verifica que no aparezca el error de "ClientID not set"

## Archivos Actualizados

Los siguientes archivos ya están configurados para usar las variables de entorno:

- ✅ `lib/features/auth/config/firebase_config.dart`
- ✅ `lib/features/auth/data/datasources/auth_firebase_datasource.dart`
- ✅ `lib/features/login/controllers/login_controller.dart`
- ✅ `.vscode/launch.json`
- ✅ `.env` y `.env.example`

## Próximos Pasos

1. **Obtener Client IDs reales** de Google Cloud Console
2. **Actualizar archivo `.env`** con los valores reales
3. **Agregar meta tag** en `web/index.html`
4. **Reiniciar la aplicación**
5. **Probar Google Sign-In**

## Comandos Útiles

```bash
# Verificar configuración de Firebase
flutter analyze lib/features/auth/

# Ejecutar en modo desarrollo
flutter run -d chrome --dart-define-from-file=.env

# Verificar que las variables se están pasando correctamente
flutter run --dart-define=GOOGLE_SIGN_IN_WEB_CLIENT_ID=test
```

## Notas Importantes

- Los Client IDs son diferentes para cada plataforma (Web, iOS, Android)
- Los Client IDs deben coincidir exactamente con la configuración en Google Cloud Console
- Para producción, asegúrate de agregar los dominios correctos en las "Authorized origins"
- Mantén los Client IDs seguros y no los commits en el repositorio público
