import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, debugPrint;
import '../../domain/usecases/login_with_credentials_usecase.dart';
import '../../config/firebase_config.dart';

/// Contrato para el datasource de Firebase
abstract class AuthFirebaseDataSource {
  /// Inicia sesión con Google y retorna el token de ID
  Future<String> signInWithGoogle();

  /// Inicia sesión con Apple y retorna el token de ID
  Future<String> signInWithApple();

  /// Cierra sesión de Firebase
  Future<void> signOut();

  /// Obtiene el token de ID del usuario actual
  Future<String?> getCurrentUserIdToken();

  /// Verifica si hay un usuario autenticado en Firebase
  bool isUserSignedIn();

  /// Obtiene los datos básicos del usuario de Firebase
  User? getCurrentFirebaseUser();

  /// Refresca el token de ID actual
  Future<String?> refreshIdToken();
}

/// Implementación del datasource de Firebase
class AuthFirebaseDataSourceImpl implements AuthFirebaseDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthFirebaseDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: kIsWeb
                  ? '1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com'
                  : FirebaseConfig.googleSignInClientId,
            ) {
    // Debug: Verificar que el clientId se esté pasando correctamente
    if (kDebugMode) {
      debugPrint('=== GoogleSignIn Debug ===');
      debugPrint('Platform: ${kIsWeb ? 'Web' : 'Native'}');
      debugPrint('Client ID from config: ${FirebaseConfig.googleSignInClientId}');
      debugPrint('GoogleSignIn clientId: ${_googleSignIn.clientId}');
      debugPrint('Firebase app: ${_firebaseAuth.app.name}');
      debugPrint('Firebase project: ${_firebaseAuth.app.options.projectId}');
      debugPrint('========================');
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      debugPrint('=== Iniciando Google Sign-In Debug ===');
      debugPrint('Firebase Auth inicializado: ${_firebaseAuth.app.name}');
      debugPrint('GoogleSignIn clientId: ${_googleSignIn.clientId}');
      debugPrint('kIsWeb: $kIsWeb');

      // Verificar si Google Sign-In está disponible
      if (!await _googleSignIn.isSignedIn()) {
        debugPrint('Usuario no está autenticado con Google, iniciando flujo...');
      }

      // Iniciar el flujo de autenticación con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // El usuario canceló el proceso
        throw const AuthException('El usuario canceló la autenticación', code: 'sign_in_canceled');
      }

      debugPrint('Usuario de Google obtenido: ${googleUser.email}');

      // Obtener los detalles de autenticación de la solicitud
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw const AuthException('No se pudieron obtener las credenciales de Google');
      }

      debugPrint(
          'Tokens obtenidos - AccessToken: ${googleAuth.accessToken != null}, IdToken: ${googleAuth.idToken != null}');

      // Crear credenciales de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Credenciales de Firebase creadas, intentando autenticación...');

      // Autenticar con Firebase usando las credenciales de Google
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('No se pudo autenticar con Firebase');
      }

      debugPrint('Autenticación exitosa con Firebase para: ${userCredential.user!.email}');

      // Obtener el token de ID de Firebase
      final idToken = await userCredential.user!.getIdToken(true);

      if (idToken == null) {
        throw const AuthException('No se pudo obtener el token de autenticación');
      }

      debugPrint('Token de Firebase obtenido exitosamente');
      debugPrint('=== Google Sign-In Completado ===');

      return idToken;
    } on FirebaseAuthException catch (e) {
      debugPrint('=== Error de Firebase Auth ===');
      debugPrint('Código de error: ${e.code}');
      debugPrint('Mensaje: ${e.message}');
      debugPrint('Plugin: ${e.plugin}');
      debugPrint('Stack trace: ${e.stackTrace}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw const AuthException('Ya existe una cuenta con este email usando un método de autenticación diferente');
        case 'invalid-credential':
          throw const AuthException('Las credenciales de Google no son válidas');
        case 'operation-not-allowed':
          throw const AuthException('Google Sign-In no está habilitado en este proyecto');
        case 'user-disabled':
          throw const AuthException('Esta cuenta ha sido deshabilitada');
        case 'user-not-found':
          throw const AuthException('No se encontró una cuenta con estas credenciales');
        case 'wrong-password':
          throw const AuthException('Credenciales incorrectas');
        case 'configuration-not-found':
          throw const AuthException(
              'Configuración de Firebase no encontrada. Verifica la configuración del proyecto Firebase y los Client IDs de Google Sign-In.');
        case 'network-request-failed':
          throw const AuthException('Error de red. Verifica tu conexión a internet.');
        case 'too-many-requests':
          throw const AuthException('Demasiados intentos de autenticación. Intenta más tarde.');
        default:
          throw AuthException('Error de autenticación Firebase: ${e.message} (código: ${e.code})', code: e.code);
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      debugPrint('Error inesperado durante Google Sign-In: $e');
      debugPrint('Tipo de error: ${e.runtimeType}');
      throw const AuthException('Error inesperado durante la autenticación con Google');
    }
  }

  @override
  Future<String> signInWithApple() async {
    try {
      debugPrint('Iniciando Apple Sign-In...');

      // Verificar disponibilidad de Apple Sign-In
      if (!kIsWeb && !Platform.isIOS && !Platform.isMacOS) {
        throw const AuthException('Apple Sign-In no está disponible en esta plataforma');
      }

      // Verificar disponibilidad específica
      if (!await SignInWithApple.isAvailable()) {
        throw const AuthException('Apple Sign-In no está disponible en este dispositivo');
      }

      // Solicitar credenciales de Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: kIsWeb
            ? WebAuthenticationOptions(
                clientId: 'your-apple-service-id', // Configurar en producción
                redirectUri: Uri.parse('https://your-domain.com/auth/apple'), // Configurar
              )
            : null,
      );

      debugPrint('Credenciales de Apple obtenidas para: ${appleCredential.email ?? 'email no disponible'}');

      // Crear credenciales de Firebase para Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Autenticar con Firebase usando las credenciales de Apple
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw const AuthException('No se pudo autenticar con Firebase usando Apple');
      }

      // Obtener el token de ID de Firebase
      final idToken = await userCredential.user!.getIdToken(true);

      if (idToken == null) {
        throw const AuthException('No se pudo obtener el token de autenticación de Apple');
      }

      debugPrint('Apple Sign-In exitoso para: ${userCredential.user!.email ?? 'email no disponible'}');

      return idToken;
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('Error de Apple Sign-In: ${e.code} - ${e.message}');

      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw const AuthException('El usuario canceló la autenticación', code: 'sign_in_canceled');
        case AuthorizationErrorCode.failed:
          throw const AuthException('Error durante la autenticación con Apple');
        case AuthorizationErrorCode.invalidResponse:
          throw const AuthException('Respuesta inválida de Apple Sign-In');
        case AuthorizationErrorCode.notHandled:
          throw const AuthException('Apple Sign-In no pudo ser procesado');
        case AuthorizationErrorCode.unknown:
          throw const AuthException('Error desconocido durante Apple Sign-In');
        default:
          throw AuthException('Error de Apple Sign-In: ${e.message}');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Error de Firebase Auth con Apple: ${e.code} - ${e.message}');
      throw AuthException('Error de autenticación con Firebase: ${e.message}', code: e.code);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      debugPrint('Error inesperado durante Apple Sign-In: $e');
      throw const AuthException('Error inesperado durante la autenticación con Apple');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Cerrar sesión en Firebase
      await _firebaseAuth.signOut();

      // Cerrar sesión en Google si está autenticado
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      debugPrint('Sesión cerrada en Firebase y servicios asociados');
    } catch (e) {
      debugPrint('Error durante signOut: $e');
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<String?> getCurrentUserIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      return await user.getIdToken(false);
    } catch (e) {
      debugPrint('Error al obtener token ID actual: $e');
      return null;
    }
  }

  @override
  bool isUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  @override
  User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<String?> refreshIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // Forzar actualización del token
      return await user.getIdToken(true);
    } catch (e) {
      debugPrint('Error al refrescar token ID: $e');
      throw AuthException('Error al refrescar token de Firebase: $e');
    }
  }
}

/// Factory para crear instancias del datasource de Firebase
class AuthFirebaseDataSourceFactory {
  static AuthFirebaseDataSource create() {
    return AuthFirebaseDataSourceImpl();
  }

  static AuthFirebaseDataSource createWithInstances({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) {
    return AuthFirebaseDataSourceImpl(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
    );
  }
}
