import '../repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'login_with_credentials_usecase.dart';

/// Caso de uso para cerrar la sesión del usuario.
///
/// Este caso de uso maneja la limpieza completa de la sesión del usuario,
/// incluyendo Firebase, almacenamiento local y revocación de tokens.
class LogoutUseCase {
  final AuthRepository _authRepository;

  const LogoutUseCase(this._authRepository);

  /// Ejecuta el proceso de cierre de sesión.
  ///
  /// Este método realiza las siguientes acciones:
  /// 1. Cierra sesión en Firebase Authentication
  /// 2. Limpia el almacenamiento local de tokens y datos del usuario
  /// 3. Revoca tokens en el backend si es necesario
  /// 4. Limpia cualquier caché de sesión
  ///
  /// Excepciones:
  /// - [AuthException] si hay problemas durante el logout
  /// - [NetworkException] si hay problemas de conectividad
  Future<void> execute() async {
    try {
      // Obtener usuario actual antes del logout para logging
      final currentUser = await _authRepository.getCurrentUser();

      // Ejecutar logout
      await _authRepository.signOut();

      // Log exitoso
      if (currentUser != null) {
        debugPrint('Logout exitoso para usuario: ${currentUser.email}');
      } else {
        debugPrint('Logout ejecutado (no había usuario autenticado)');
      }
    } catch (e) {
      // Manejar errores de logout
      if (e is AuthException) {
        // Incluso si hay error, intentar limpiar datos locales
        try {
          await _authRepository.clearAuthData();
        } catch (_) {
          // Silenciar errores de limpieza local
        }

        throw AuthException('Error durante el cierre de sesión: ${e.message}');
      } else if (e is NetworkException) {
        // En caso de error de red, al menos limpiar datos locales
        try {
          await _authRepository.clearAuthData();
          debugPrint('Datos locales limpiados debido a error de red en logout');
        } catch (_) {
          // Silenciar errores de limpieza local
        }

        throw NetworkException('Error de red durante el logout: ${e.message}');
      } else {
        // Para cualquier otro error, intentar limpiar datos locales
        try {
          await _authRepository.clearAuthData();
        } catch (_) {
          // Silenciar errores de limpieza local
        }

        throw const AuthException('Error inesperado durante el logout');
      }
    }
  }

  /// Ejecuta un logout forzado limpiando solo datos locales.
  ///
  /// Útil cuando hay problemas de conectividad pero se necesita
  /// cerrar la sesión localmente. No intenta comunicarse con
  /// servicios externos.
  ///
  /// Este método siempre tendrá éxito, incluso si hay errores
  /// menores durante la limpieza.
  Future<void> executeForced() async {
    try {
      // Solo limpiar datos locales
      await _authRepository.clearAuthData();

      debugPrint('Logout forzado completado - datos locales limpiados');
    } catch (e) {
      // Silenciar errores en logout forzado
      debugPrint('Warning: Error durante logout forzado: $e');
    }
  }
}
