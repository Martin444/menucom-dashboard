import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/usecases/login_with_credentials_usecase.dart';

/// Contrato para el datasource local de autenticación
abstract class AuthLocalDataSource {
  /// Guarda los datos del usuario autenticado
  Future<void> saveAuthenticatedUser(AuthenticatedUser user);

  /// Obtiene el usuario autenticado guardado
  Future<AuthenticatedUser?> getAuthenticatedUser();

  /// Verifica si hay un usuario autenticado
  Future<bool> isUserAuthenticated();

  /// Obtiene solo el token de acceso
  Future<String?> getAccessToken();

  /// Guarda solo el token de acceso
  Future<void> saveAccessToken(String token);

  /// Limpia todos los datos de autenticación
  Future<void> clearAuthData();

  /// Actualiza el token de acceso del usuario actual
  Future<void> updateAccessToken(String newToken);

  /// Verifica si el token ha expirado (si es posible determinarlo)
  Future<bool> isTokenExpired();
}

/// Implementación del datasource local usando FlutterSecureStorage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'authenticated_user';
  static const String _tokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  const AuthLocalDataSourceImpl();

  @override
  Future<void> saveAuthenticatedUser(AuthenticatedUser user) async {
    try {
      // Guardar datos completos del usuario
      final userJson = json.encode(user.toMap());
      await _secureStorage.write(key: _userKey, value: userJson);

      // Guardar token por separado para acceso rápido
      await _secureStorage.write(key: _tokenKey, value: user.accessToken);

      // Guardar tiempo de expiración estimado (24 horas por defecto)
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await _secureStorage.write(
          key: _tokenExpiryKey,
          value: expiryTime.millisecondsSinceEpoch.toString());

      debugPrint('Usuario guardado localmente: ${user.email}');
    } catch (e) {
      throw AuthException('Error al guardar datos del usuario localmente: $e');
    }
  }

  @override
  Future<AuthenticatedUser?> getAuthenticatedUser() async {
    try {
      final userJsonString = await _secureStorage.read(key: _userKey);

      if (userJsonString == null) {
        return null;
      }

      final userMap = json.decode(userJsonString) as Map<String, dynamic>;
      return AuthenticatedUser.fromMap(userMap);
    } catch (e) {
      debugPrint('Error al obtener usuario guardado: $e');
      // Si hay error, limpiar datos corruptos
      await clearAuthData();
      return null;
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      // Verificar si existe el token
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        return false;
      }

      // Verificar si el token ha expirado
      if (await isTokenExpired()) {
        return false;
      }

      // Verificar si existen datos del usuario
      final userJsonString = await _secureStorage.read(key: _userKey);
      if (userJsonString == null) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error al verificar autenticación: $e');
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('Error al obtener token de acceso: $e');
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);

      // Actualizar tiempo de expiración
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await _secureStorage.write(
          key: _tokenExpiryKey,
          value: expiryTime.millisecondsSinceEpoch.toString());

      debugPrint('Token de acceso guardado localmente');
    } catch (e) {
      throw AuthException('Error al guardar token de acceso: $e');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _userKey),
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _tokenExpiryKey),
      ]);

      debugPrint('Datos de autenticación limpiados localmente');
    } catch (e) {
      debugPrint('Error al limpiar datos de autenticación: $e');
      // No lanzar excepción aquí para evitar bloquear el logout
    }
  }

  @override
  Future<void> updateAccessToken(String newToken) async {
    try {
      // Obtener usuario actual
      final user = await getAuthenticatedUser();
      if (user == null) {
        throw const AuthException('No hay usuario autenticado para actualizar token');
      }

      // Crear usuario actualizado con nuevo token
      final updatedUser = user.copyWith(accessToken: newToken);

      // Guardar usuario actualizado
      await saveAuthenticatedUser(updatedUser);

      debugPrint('Token actualizado para usuario: ${user.email}');
    } catch (e) {
      throw AuthException('Error al actualizar token: $e');
    }
  }

  @override
  Future<bool> isTokenExpired() async {
    try {
      final expiryTimestampString = await _secureStorage.read(key: _tokenExpiryKey);

      if (expiryTimestampString == null) {
        // Si no hay tiempo de expiración guardado, asumir que no ha expirado
        return false;
      }

      final expiryTimestamp = int.tryParse(expiryTimestampString);
      if (expiryTimestamp == null) {
        return false;
      }

      final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      final now = DateTime.now();

      return now.isAfter(expiryTime);
    } catch (e) {
      debugPrint('Error al verificar expiración del token: $e');
      // En caso de error, asumir que no ha expirado
      return false;
    }
  }
}

/// Factory para crear instancias del datasource local
class AuthLocalDataSourceFactory {
  static Future<AuthLocalDataSource> create() async {
    return const AuthLocalDataSourceImpl();
  }

  static AuthLocalDataSource createWithPreferences() {
    return const AuthLocalDataSourceImpl();
  }
}
