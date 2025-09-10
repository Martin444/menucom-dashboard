# Configuración de Firebase - MenuCom Dashboard

## Variables de Entorno

Este proyecto usa variables de entorno para configurar Firebase de manera segura. La configuración se pasa a través de `--dart-define` en VS Code.

### Configuración en VS Code

Las variables de entorno están configuradas en `.vscode/launch.json` para cada ambiente:

- **menucom_dev**: Desarrollo local
- **qa_menucom**: Ambiente de QA
- **menucom_beta**: Ambiente de beta

### Variables de Firebase Configuradas

```bash
FIREBASE_API_KEY=AIzaSyAEWpBCNon00zwt1eWfqSDiYMhH0xxLMwk
FIREBASE_AUTH_DOMAIN=menucom-ff087.firebaseapp.com
FIREBASE_PROJECT_ID=menucom-ff087
FIREBASE_STORAGE_BUCKET=menucom-ff087.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=1053737382833
FIREBASE_APP_ID_WEB=1:1053737382833:web:d4173f40d6b88a52900390
FIREBASE_MEASUREMENT_ID=G-D5ZC2VB6GR
```

### Cómo Usar

1. **En VS Code**: Selecciona la configuración deseada (`menucom_dev`, `qa_menucom`, o `menucom_beta`) en el panel de Run and Debug.

2. **Desde línea de comandos**:
```bash
flutter run -d chrome --dart-define=FIREBASE_API_KEY=your_api_key --dart-define=FIREBASE_PROJECT_ID=your_project_id --dart-define=FIREBASE_AUTH_DOMAIN=your_domain.firebaseapp.com
```

3. **Para build de producción**:
```bash
flutter build web --dart-define=FIREBASE_API_KEY=your_api_key --dart-define=FIREBASE_PROJECT_ID=your_project_id
```

### Seguridad

- ✅ Las variables de entorno están configuradas en `launch.json` para desarrollo
- ✅ El archivo `.env` está en `.gitignore` para evitar subir credenciales
- ✅ Se usan valores por defecto seguros en `firebase_config.dart`

### Servicios de Firebase Habilitados

- **Authentication**: Google Sign-In, Apple Sign-In, Email/Password
- **Analytics**: Métricas y eventos de usuario
- **Storage**: Almacenamiento de archivos (configurado)

### Próximos Pasos

1. Configurar Google Sign-In Client IDs para cada plataforma
2. Configurar Apple Sign-In Service ID para web
3. Agregar archivos de configuración nativos:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)
   - `macos/Runner/GoogleService-Info.plist` (macOS)

### Troubleshooting

Si encuentras errores de configuración:

1. Verifica que las variables estén definidas en `launch.json`
2. Confirma que el proyecto de Firebase existe y está activo
3. Asegúrate de que Authentication esté habilitado en Firebase Console
4. Verifica que Google Sign-In esté configurado en Firebase Console
