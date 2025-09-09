import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;

/// Configuración de Firebase para diferentes plataformas.
///
/// Esta clase centraliza toda la configuración de Firebase
/// para web, Android, iOS y otras plataformas usando variables de entorno.
class FirebaseConfig {
  // Obtener valores de variables de entorno con valores por defecto
  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyAEWpBCNon00zwt1eWfqSDiYMhH0xxLMwk',
  );

  static const String _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'menucom-ff087.firebaseapp.com',
  );

  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'menucom-ff087',
  );

  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'menucom-ff087.firebasestorage.app',
  );

  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1053737382833',
  );

  static const String _appIdWeb = String.fromEnvironment(
    'FIREBASE_APP_ID_WEB',
    defaultValue: '1:1053737382833:web:d4173f40d6b88a52900390',
  );

  static const String _measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-D5ZC2VB6GR',
  );

  static const String _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
    defaultValue: 'com.menucom.dashboard',
  );

  // Google Sign-In Client IDs
  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_WEB_CLIENT_ID',
    defaultValue:
        '1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com', // Web Client ID original del index.html
  );

  static const String _googleIosClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_IOS_CLIENT_ID',
    defaultValue: '1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com', // iOS Client ID
  );

  static const String _googleAndroidClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_ANDROID_CLIENT_ID',
    defaultValue: '1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com', // Android Client ID
  );

  /// Opciones de Firebase para la plataforma web
  static FirebaseOptions get web => const FirebaseOptions(
        apiKey: _apiKey,
        authDomain: _authDomain,
        projectId: _projectId,
        storageBucket: _storageBucket,
        messagingSenderId: _messagingSenderId,
        appId: _appIdWeb,
        measurementId: _measurementId,
      );

  /// Opciones de Firebase para Android
  static FirebaseOptions get android => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdWeb, // Para desarrollo usamos la misma app, en producción debería ser diferente
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  /// Opciones de Firebase para iOS
  static FirebaseOptions get ios => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdWeb, // Para desarrollo usamos la misma app, en producción debería ser diferente
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: _iosBundleId,
      );

  /// Opciones de Firebase para macOS
  static FirebaseOptions get macos => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdWeb, // Para desarrollo usamos la misma app, en producción debería ser diferente
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: _iosBundleId,
      );

  /// Obtiene las opciones correctas según la plataforma actual
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (Platform.operatingSystem) {
      case 'android':
        return android;
      case 'ios':
        return ios;
      case 'macos':
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ${Platform.operatingSystem} - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }
  }

  /// Configuración específica para Google Sign-In por plataforma
  static String? get googleSignInClientId {
    if (kIsWeb) {
      return _googleWebClientId.isNotEmpty ? _googleWebClientId : null;
    }

    switch (Platform.operatingSystem) {
      case 'android':
        return null; // Android usa el google-services.json
      case 'ios':
        return _googleIosClientId.isNotEmpty ? _googleIosClientId : null;
      case 'macos':
        return _googleIosClientId.isNotEmpty ? _googleIosClientId : null;
      default:
        return null;
    }
  }

  /// Configuración para Apple Sign-In
  static String? get appleSignInClientId {
    if (kIsWeb) {
      return 'com.menucom.dashboard.service'; // Service ID para web
    }
    return null; // iOS y macOS usan el bundle ID automáticamente
  }

  static String? get appleSignInRedirectUri {
    if (kIsWeb) {
      return 'https://your-domain.com/auth/apple/callback';
    }
    return null;
  }
}

/// Configuración de desarrollo para Firebase
///
/// IMPORTANTE: Estos valores son placeholders y deben ser reemplazados
/// con los valores reales de tu proyecto Firebase.
class FirebaseDevConfig {
  static const bool useEmulator = false; // Cambiar a true para usar emulators
  static const String emulatorHost = 'localhost';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;
  static const int functionsEmulatorPort = 5001;

  /// Configura los emuladores si están habilitados
  static void configureEmulators() {
    if (!useEmulator) return;

    // Configurar emulador de Authentication
    // FirebaseAuth.instance.useAuthEmulator(emulatorHost, authEmulatorPort);

    // Configurar otros emuladores según necesidad
    if (kDebugMode) {
      debugPrint('Emuladores de Firebase configurados en desarrollo');
    }
  }
}

/// Instrucciones para configurar Firebase:
/// 
/// 1. Ir a https://console.firebase.google.com/
/// 2. Crear un nuevo proyecto o seleccionar uno existente
/// 3. Agregar aplicaciones para cada plataforma (Web, Android, iOS)
/// 4. Habilitar Authentication con Google Sign-In y Apple Sign-In
/// 5. Copiar las configuraciones y reemplazar los valores en esta clase
/// 
/// Para obtener las configuraciones automáticamente:
/// 1. Instalar FlutterFire CLI: `dart pub global activate flutterfire_cli`
/// 2. Ejecutar: `flutterfire configure`
/// 3. Seguir las instrucciones para configurar el proyecto
/// 
/// Archivos de configuración adicionales necesarios:
/// - android/app/google-services.json (Android)
/// - ios/Runner/GoogleService-Info.plist (iOS)
/// - macos/Runner/GoogleService-Info.plist (macOS)
