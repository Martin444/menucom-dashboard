import '../entities/authenticated_user.dart';
import '../entities/auth_params.dart';
import '../repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'login_with_credentials_usecase.dart';

/// Caso de uso para el registro de nuevos usuarios.
///
/// Este caso de uso maneja tanto el registro tradicional como el registro
/// social, incluyendo validaciones de datos y creación de cuentas.
class RegisterUserUseCase {
  final AuthRepository _authRepository;

  const RegisterUserUseCase(this._authRepository);

  /// Ejecuta el registro tradicional con email y contraseña.
  ///
  /// Parámetros:
  /// - [params]: Datos del usuario a registrar
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con los datos del usuario registrado
  ///
  /// Validaciones:
  /// - Email debe tener formato válido y no estar registrado
  /// - Nombre no debe estar vacío
  /// - Contraseña debe cumplir requisitos de seguridad
  /// - Teléfono debe tener formato válido (si se proporciona)
  ///
  /// Excepciones:
  /// - [ValidationException] si los datos son inválidos
  /// - [AuthException] si el email ya está registrado
  /// - [NetworkException] si hay problemas de conectividad
  Future<AuthenticatedUser> execute(RegistrationParams params) async {
    // Validar datos de entrada
    _validateRegistrationParams(params);

    try {
      // Ejecutar registro
      final user = await _authRepository.registerUser(params);

      debugPrint('Usuario registrado exitosamente: ${user.email}');

      return user;
    } catch (e) {
      if (e is AuthException) {
        // Manejar errores específicos de registro
        if (e.code == 'email_already_exists') {
          throw const AuthException('Este email ya está registrado en el sistema');
        }
        rethrow;
      } else if (e is NetworkException) {
        throw NetworkException('Error de red durante el registro: ${e.message}');
      } else {
        throw const AuthException('Error inesperado durante el registro');
      }
    }
  }

  /// Ejecuta el registro social con Google.
  ///
  /// Este método maneja el flujo completo:
  /// 1. Inicia Google Sign-In
  /// 2. Obtiene datos del usuario de Google
  /// 3. Crea la cuenta en el backend
  /// 4. Retorna el usuario autenticado
  ///
  /// Parámetros:
  /// - [additionalData]: Datos adicionales opcionales del usuario
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con los datos del usuario registrado
  ///
  /// Excepciones:
  /// - [AuthException] si el proceso falla o se cancela
  /// - [NetworkException] si hay problemas de conectividad
  Future<AuthenticatedUser> executeWithGoogle({
    RegistrationParams? additionalData,
  }) async {
    try {
      // Obtener token de Google/Firebase
      final idToken = await _authRepository.signInWithGoogle();

      // Crear parámetros de registro social
      final socialParams = SocialAuthParams(
        idToken: idToken,
        additionalData: additionalData,
      );

      // Registrar con el backend
      final user = await _authRepository.registerWithSocial(socialParams);

      debugPrint('Usuario registrado con Google exitosamente: ${user.email}');

      return user;
    } catch (e) {
      if (e is AuthException) {
        if (e.code == 'sign_in_canceled') {
          throw const AuthException('El usuario canceló el proceso de registro');
        }
        rethrow;
      } else {
        throw const AuthException('Error durante el registro con Google');
      }
    }
  }

  /// Ejecuta el registro social con Apple.
  ///
  /// Similar al registro con Google pero específico para Apple.
  /// Solo disponible en plataformas Apple.
  ///
  /// Parámetros:
  /// - [additionalData]: Datos adicionales opcionales del usuario
  ///
  /// Retorna:
  /// - [AuthenticatedUser] con los datos del usuario registrado
  ///
  /// Excepciones:
  /// - [AuthException] si no está disponible o hay errores
  /// - [PlatformException] si la plataforma no es compatible
  Future<AuthenticatedUser> executeWithApple({
    RegistrationParams? additionalData,
  }) async {
    try {
      // Obtener token de Apple/Firebase
      final idToken = await _authRepository.signInWithApple();

      // Crear parámetros de registro social
      final socialParams = SocialAuthParams(
        idToken: idToken,
        additionalData: additionalData,
      );

      // Registrar con el backend
      final user = await _authRepository.registerWithSocial(socialParams);

      debugPrint('Usuario registrado con Apple exitosamente: ${user.email}');

      return user;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      } else {
        throw const AuthException('Error durante el registro con Apple');
      }
    }
  }

  /// Valida los parámetros de registro.
  void _validateRegistrationParams(RegistrationParams params) {
    // Validar email
    if (!_isValidEmail(params.email)) {
      throw const ValidationException('El formato del email no es válido');
    }

    // Validar nombre
    if (params.name.trim().isEmpty) {
      throw const ValidationException('El nombre no puede estar vacío');
    }

    if (params.name.trim().length < 2) {
      throw const ValidationException('El nombre debe tener al menos 2 caracteres');
    }

    // Validar contraseña (si es registro tradicional)
    if (params.password != null) {
      if (params.password!.isEmpty) {
        throw const ValidationException('La contraseña no puede estar vacía');
      }

      if (params.password!.length < 6) {
        throw const ValidationException('La contraseña debe tener al menos 6 caracteres');
      }

      if (!_isStrongPassword(params.password!)) {
        throw const ValidationException(
            'La contraseña debe contener al menos una mayúscula, una minúscula y un número');
      }
    }

    // Validar teléfono (si se proporciona)
    if (params.phone != null && params.phone!.isNotEmpty) {
      if (!_isValidPhone(params.phone!)) {
        throw const ValidationException('El formato del teléfono no es válido');
      }
    }

    // Validar rol
    if (!_isValidRole(params.role)) {
      throw const ValidationException('El rol especificado no es válido');
    }
  }

  /// Valida el formato del email.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Valida que la contraseña sea fuerte.
  bool _isStrongPassword(String password) {
    // Al menos una mayúscula, una minúscula y un número
    final strongPasswordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
    );
    return strongPasswordRegex.hasMatch(password);
  }

  /// Valida el formato del teléfono.
  bool _isValidPhone(String phone) {
    // Formato internacional básico
    final phoneRegex = RegExp(
      r'^\+?[1-9]\d{1,14}$',
    );
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  /// Valida que el rol sea uno de los permitidos.
  bool _isValidRole(String role) {
    const validRoles = ['customer', 'admin', 'pro', 'operador'];
    return validRoles.contains(role.toLowerCase());
  }
}
