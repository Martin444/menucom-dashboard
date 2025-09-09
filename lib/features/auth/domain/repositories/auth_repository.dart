import '../entities/authenticated_user.dart';
import '../entities/auth_params.dart';

/// Interfaz que define los contratos para la autenticación de usuarios.
///
/// Esta interfaz sigue el patrón Repository y define los métodos necesarios
/// para manejar todos los tipos de autenticación: tradicional, social y Firebase.
///
/// Implementaciones concretas deberán manejar la comunicación con:
/// - Firebase Authentication para autenticación social
/// - API backend para validación de tokens y gestión de usuarios
/// - Almacenamiento local para persistencia de sesiones
abstract class AuthRepository {
  /// Autentica un usuario con credenciales tradicionales (email/password).
  ///
  /// Parámetros:
  /// - [credentials]: Email y contraseña del usuario
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si la autenticación es exitosa
  ///
  /// Excepciones:
  /// - [AuthException] si las credenciales son inválidas
  /// - [NetworkException] si hay problemas de conectividad
  Future<AuthenticatedUser> loginWithCredentials(LoginCredentials credentials);

  /// Autentica un usuario usando tokens de Firebase/Google.
  ///
  /// Este método maneja el flujo completo de autenticación social:
  /// 1. Valida el token con Firebase Admin SDK
  /// 2. Busca o crea el usuario en el backend
  /// 3. Genera un JWT para el sistema
  ///
  /// Parámetros:
  /// - [params]: Token de ID de Firebase y datos adicionales opcionales
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con información del usuario autenticado
  ///
  /// Excepciones:
  /// - [AuthException] si el token es inválido
  /// - [NetworkException] si hay problemas de conectividad
  Future<AuthenticatedUser> loginWithSocial(SocialAuthParams params);

  /// Registra un nuevo usuario con datos tradicionales.
  ///
  /// Parámetros:
  /// - [params]: Datos del usuario a registrar
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con los datos del usuario registrado
  ///
  /// Excepciones:
  /// - [AuthException] si el email ya está registrado
  /// - [ValidationException] si los datos son inválidos
  Future<AuthenticatedUser> registerUser(RegistrationParams params);

  /// Registra un usuario usando autenticación social con datos adicionales.
  ///
  /// Parámetros:
  /// - [params]: Token de Firebase y datos adicionales del usuario
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con los datos del usuario registrado
  ///
  /// Excepciones:
  /// - [AuthException] si hay problemas con el token o registro
  Future<AuthenticatedUser> registerWithSocial(SocialAuthParams params);

  /// Autentica con Google Sign-In y obtiene el token de Firebase.
  ///
  /// Este método maneja el flujo completo de Google Sign-In:
  /// 1. Inicia el flujo de Google Sign-In
  /// 2. Obtiene las credenciales de Google
  /// 3. Autentica con Firebase
  /// 4. Retorna el token de ID para usar con el backend
  ///
  /// Retorna:
  /// - String con el token de ID de Firebase
  ///
  /// Excepciones:
  /// - [AuthException] si el usuario cancela o hay errores
  /// - [PlatformException] si hay problemas específicos de la plataforma
  Future<String> signInWithGoogle();

  /// Autentica con Apple Sign-In y obtiene el token de Firebase.
  ///
  /// Similar a Google Sign-In pero para dispositivos Apple.
  /// Solo disponible en iOS, macOS y web.
  ///
  /// Retorna:
  /// - String con el token de ID de Firebase
  ///
  /// Excepciones:
  /// - [AuthException] si el usuario cancela o hay errores
  /// - [PlatformException] si no está disponible en la plataforma
  Future<String> signInWithApple();

  /// Cierra la sesión del usuario actual.
  ///
  /// Este método:
  /// 1. Cierra sesión en Firebase
  /// 2. Limpia el almacenamiento local
  /// 3. Revoca tokens si es necesario
  ///
  /// Excepciones:
  /// - [AuthException] si hay problemas al cerrar sesión
  Future<void> signOut();

  /// Obtiene el usuario autenticado actual desde el almacenamiento local.
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si hay una sesión activa
  /// - null si no hay usuario autenticado
  Future<AuthenticatedUser?> getCurrentUser();

  /// Verifica si hay un usuario autenticado actualmente.
  ///
  /// Retorna:
  /// - true si hay una sesión activa válida
  /// - false si no hay sesión o ha expirado
  Future<bool> isUserAuthenticated();

  /// Refresca el token de autenticación del usuario actual.
  ///
  /// Útil para mantener la sesión activa sin requerir re-autenticación.
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con el token actualizado
  ///
  /// Excepciones:
  /// - [AuthException] si no se puede refrescar el token
  Future<AuthenticatedUser> refreshToken();

  /// Elimina todos los datos de autenticación almacenados localmente.
  ///
  /// Útil para limpiar completamente la sesión del usuario.
  Future<void> clearAuthData();
}
