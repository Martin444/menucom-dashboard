import '../entities/authenticated_user.dart';
import '../entities/auth_params.dart';
import '../repositories/auth_repository.dart';
import 'login_with_credentials_usecase.dart';

/// Caso de uso para la autenticación social con Firebase/Google.
///
/// Este caso de uso maneja el flujo completo de autenticación social,
/// incluyendo la obtención del token de Firebase y la validación en el backend.
class LoginWithSocialUseCase {
  final AuthRepository _authRepository;

  const LoginWithSocialUseCase(this._authRepository);

  /// Ejecuta el login social con Google Sign-In.
  ///
  /// Este método maneja el flujo completo:
  /// 1. Inicia Google Sign-In
  /// 2. Obtiene el token de Firebase
  /// 3. Autentica con el backend
  /// 4. Retorna el usuario autenticado
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si la autenticación es exitosa
  ///
  /// Excepciones:
  /// - [AuthException] si el usuario cancela o hay errores
  /// - [NetworkException] si hay problemas de conectividad
  Future<AuthenticatedUser> executeWithGoogle() async {
    try {
      // Obtener token de Google/Firebase
      final idToken = await _authRepository.signInWithGoogle();

      // Crear parámetros de autenticación social
      final socialParams = SocialAuthParams(idToken: idToken);

      // Autenticar con el backend
      final user = await _authRepository.loginWithSocial(socialParams);

      print('Login social exitoso para usuario: ${user.email}');

      return user;
    } catch (e) {
      if (e is AuthException) {
        // Si es cancelación del usuario, re-lanzar con mensaje más claro
        if (e.code == 'sign_in_canceled') {
          throw AuthException('El usuario canceló el proceso de autenticación');
        }
        rethrow;
      } else {
        throw AuthException('Error durante la autenticación con Google');
      }
    }
  }

  /// Ejecuta el login social con Apple Sign-In.
  ///
  /// Similar al login con Google pero específico para Apple.
  /// Solo disponible en plataformas Apple.
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si la autenticación es exitosa
  ///
  /// Excepciones:
  /// - [AuthException] si no está disponible o hay errores
  /// - [PlatformException] si la plataforma no es compatible
  Future<AuthenticatedUser> executeWithApple() async {
    try {
      // Obtener token de Apple/Firebase
      final idToken = await _authRepository.signInWithApple();

      // Crear parámetros de autenticación social
      final socialParams = SocialAuthParams(idToken: idToken);

      // Autenticar con el backend
      final user = await _authRepository.loginWithSocial(socialParams);

      print('Login social con Apple exitoso para usuario: ${user.email}');

      return user;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      } else {
        throw AuthException('Error durante la autenticación con Apple');
      }
    }
  }

  /// Ejecuta el login social con un token de Firebase existente.
  ///
  /// Útil cuando ya se tiene un token válido de Firebase y solo
  /// se necesita validar con el backend.
  ///
  /// Parámetros:
  /// - [idToken]: Token de ID de Firebase válido
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si la autenticación es exitosa
  ///
  /// Validaciones:
  /// - El token no debe estar vacío
  /// - El token debe ser válido en Firebase
  ///
  /// Excepciones:
  /// - [ValidationException] si el token es inválido
  /// - [AuthException] si la validación falla
  Future<AuthenticatedUser> executeWithToken(String idToken) async {
    // Validar token
    if (idToken.isEmpty) {
      throw ValidationException('El token de Firebase no puede estar vacío');
    }

    try {
      // Crear parámetros de autenticación social
      final socialParams = SocialAuthParams(idToken: idToken);

      // Autenticar con el backend
      final user = await _authRepository.loginWithSocial(socialParams);

      print('Login social con token exitoso para usuario: ${user.email}');

      return user;
    } catch (e) {
      if (e is AuthException) {
        throw AuthException('Token de Firebase inválido o expirado: ${e.message}');
      } else {
        throw AuthException('Error durante la validación del token');
      }
    }
  }
}
