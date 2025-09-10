import '../entities/authenticated_user.dart';
import '../entities/auth_params.dart';
import '../repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

/// Caso de uso para la autenticación tradicional con email y contraseña.
///
/// Este caso de uso encapsula la lógica de negocio para el login tradicional,
/// incluyendo validaciones y manejo de errores específicos.
class LoginWithCredentialsUseCase {
  final AuthRepository _authRepository;

  const LoginWithCredentialsUseCase(this._authRepository);

  /// Ejecuta el caso de uso de login tradicional.
  ///
  /// Parámetros:
  /// - [credentials]: Email y contraseña del usuario
  ///
  /// Retorna:
  /// - [AuthenticatedUser] si la autenticación es exitosa
  ///
  /// Validaciones:
  /// - Email debe tener formato válido
  /// - Password no debe estar vacío
  /// - Credenciales deben ser válidas en el backend
  ///
  /// Excepciones:
  /// - [ValidationException] si los datos de entrada son inválidos
  /// - [AuthException] si las credenciales son incorrectas
  /// - [NetworkException] si hay problemas de conectividad
  Future<AuthenticatedUser> execute(LoginCredentials credentials) async {
    // Validar email
    if (!_isValidEmail(credentials.email)) {
      throw const ValidationException('El formato del email no es válido');
    }

    // Validar password
    if (credentials.password.isEmpty) {
      throw const ValidationException('La contraseña no puede estar vacía');
    }

    if (credentials.password.length < 6) {
      throw const ValidationException('La contraseña debe tener al menos 6 caracteres');
    }

    try {
      // Ejecutar autenticación
      final user = await _authRepository.loginWithCredentials(credentials);

      // Log exitoso (sin mostrar credenciales sensibles)
      debugPrint('Login exitoso para usuario: ${user.email}');

      return user;
    } catch (e) {
      // Re-lanzar la excepción con contexto adicional si es necesario
      if (e is AuthException) {
        throw AuthException('Error de autenticación: ${e.message}');
      } else if (e is NetworkException) {
        throw NetworkException('Error de red durante el login: ${e.message}');
      } else {
        throw const AuthException('Error inesperado durante el login');
      }
    }
  }

  /// Valida el formato del email usando una expresión regular.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// Excepción específica para errores de validación de datos de entrada.
class ValidationException implements Exception {
  final String message;

  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Excepción específica para errores de autenticación.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Excepción específica para errores de red.
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
