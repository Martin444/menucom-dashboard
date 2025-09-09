import '../entities/authenticated_user.dart';
import '../repositories/auth_repository.dart';
import 'login_with_credentials_usecase.dart';

/// Caso de uso para obtener el usuario autenticado actual.
///
/// Este caso de uso maneja la recuperación del usuario actual,
/// incluyendo validación de tokens y refresco automático si es necesario.
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  const GetCurrentUserUseCase(this._authRepository);

  /// Obtiene el usuario autenticado actual.
  ///
  /// Este método verifica si hay un usuario autenticado válido
  /// y retorna sus datos. Si el token ha expirado, intenta
  /// refrescarlo automáticamente.
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si hay una sesión válida
  /// - null si no hay usuario autenticado
  ///
  /// Excepciones:
  /// - [AuthException] si hay problemas con la sesión
  Future<AuthenticatedUser?> execute() async {
    try {
      // Verificar si hay usuario autenticado
      final isAuthenticated = await _authRepository.isUserAuthenticated();

      if (!isAuthenticated) {
        print('No hay usuario autenticado actualmente');
        return null;
      }

      // Obtener usuario actual
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        print('Usuario actual obtenido: ${user.email}');
        return user;
      } else {
        print('No se encontró usuario en almacenamiento local');
        return null;
      }
    } catch (e) {
      if (e is AuthException) {
        // Si hay error de autenticación, el usuario probablemente no está autenticado
        print('Error de autenticación al obtener usuario actual: ${e.message}');
        return null;
      } else {
        throw AuthException('Error inesperado al obtener usuario actual');
      }
    }
  }

  /// Obtiene el usuario actual con refresco automático de token.
  ///
  /// Similar a [execute] pero intenta refrescar el token
  /// automáticamente si está próximo a expirar o ha expirado.
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con token actualizado si es exitoso
  /// - null si no hay usuario autenticado o no se puede refrescar
  ///
  /// Excepciones:
  /// - [AuthException] si hay problemas durante el refresco
  Future<AuthenticatedUser?> executeWithRefresh() async {
    try {
      // Primero intentar obtener usuario normal
      final user = await execute();

      if (user == null) {
        return null;
      }

      // Intentar refrescar token si es necesario
      try {
        final refreshedUser = await _authRepository.refreshToken();
        print('Token refrescado para usuario: ${refreshedUser.email}');
        return refreshedUser;
      } catch (refreshError) {
        // Si no se puede refrescar, retornar el usuario original
        // (el token aún puede ser válido)
        print('No se pudo refrescar el token, usando token actual');
        return user;
      }
    } catch (e) {
      if (e is AuthException) {
        return null;
      } else {
        throw AuthException('Error al obtener usuario con refresco de token');
      }
    }
  }

  /// Verifica si hay un usuario autenticado sin obtener sus datos.
  ///
  /// Método más liviano que solo verifica el estado de autenticación
  /// sin cargar todos los datos del usuario.
  ///
  /// Retorna:
  /// - true si hay una sesión válida
  /// - false si no hay sesión o ha expirado
  Future<bool> isUserAuthenticated() async {
    try {
      return await _authRepository.isUserAuthenticated();
    } catch (e) {
      // En caso de error, asumir que no está autenticado
      print('Error al verificar autenticación: $e');
      return false;
    }
  }
}
