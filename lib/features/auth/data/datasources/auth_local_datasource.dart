import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Implementación del datasource local usando SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'authenticated_user';
  static const String _tokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';

  final SharedPreferences sharedPreferences;

  const AuthLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<void> saveAuthenticatedUser(AuthenticatedUser user) async {
    try {
      // Guardar datos completos del usuario
      final userJson = json.encode(user.toMap());
      await sharedPreferences.setString(_userKey, userJson);

      // Guardar token por separado para acceso rápido
      await sharedPreferences.setString(_tokenKey, user.accessToken);

      // Guardar tiempo de expiración estimado (24 horas por defecto)
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await sharedPreferences.setInt(_tokenExpiryKey, expiryTime.millisecondsSinceEpoch);

      debugPrint('Usuario guardado localmente: ${user.email}');
    } catch (e) {
      throw AuthException('Error al guardar datos del usuario localmente: $e');
    }
  }

  @override
  Future<AuthenticatedUser?> getAuthenticatedUser() async {
    try {
      final userJsonString = sharedPreferences.getString(_userKey);

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
      final token = sharedPreferences.getString(_tokenKey);
      if (token == null || token.isEmpty) {
        return false;
      }

      // Verificar si el token ha expirado
      if (await isTokenExpired()) {
        return false;
      }

      // Verificar si existen datos del usuario
      final userJsonString = sharedPreferences.getString(_userKey);
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
      return sharedPreferences.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error al obtener token de acceso: $e');
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await sharedPreferences.setString(_tokenKey, token);

      // Actualizar tiempo de expiración
      final expiryTime = DateTime.now().add(const Duration(hours: 24));
      await sharedPreferences.setInt(_tokenExpiryKey, expiryTime.millisecondsSinceEpoch);

      debugPrint('Token de acceso guardado localmente');
    } catch (e) {
      throw AuthException('Error al guardar token de acceso: $e');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        sharedPreferences.remove(_userKey),
        sharedPreferences.remove(_tokenKey),
        sharedPreferences.remove(_tokenExpiryKey),
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
      final expiryTimestamp = sharedPreferences.getInt(_tokenExpiryKey);

      if (expiryTimestamp == null) {
        // Si no hay tiempo de expiración guardado, asumir que no ha expirado
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
    final sharedPreferences = await SharedPreferences.getInstance();
    return AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  }

  static AuthLocalDataSource createWithPreferences(SharedPreferences prefs) {
    return AuthLocalDataSourceImpl(sharedPreferences: prefs);
  }
}
