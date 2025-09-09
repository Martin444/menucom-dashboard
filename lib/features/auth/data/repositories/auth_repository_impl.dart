import 'package:flutter/foundation.dart';
import '../../domain/entities/authenticated_user.dart';
import '../../domain/entities/auth_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_credentials_usecase.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../models/auth_request_model.dart';

/// Implementación concreta del repositorio de autenticación.
///
/// Esta clase coordina las operaciones entre los diferentes datasources:
/// - Remote: API del backend para validación y gestión de usuarios
/// - Local: Almacenamiento local para persistencia de sesiones
/// - Firebase: Autenticación social y gestión de tokens
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final AuthFirebaseDataSource _firebaseDataSource;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required AuthFirebaseDataSource firebaseDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _firebaseDataSource = firebaseDataSource;

  @override
  Future<AuthenticatedUser> loginWithCredentials(LoginCredentials credentials) async {
    try {
      debugPrint('Iniciando login tradicional para: ${credentials.email}');

      // Convertir parámetros de dominio a modelo de request
      final request = LoginRequestModel.fromDomain(credentials);

      // Realizar petición a la API
      final response = await _remoteDataSource.loginWithCredentials(request);

      // Convertir respuesta a entidad de dominio
      final user = response.toDomain(
        userId: response.user?.id,
        email: response.user?.email ?? credentials.email,
        name: response.user?.name ?? '',
        photoURL: response.user?.photoURL,
        phone: response.user?.phone,
        role: response.user?.role ?? 'customer',
        socialToken: response.user?.socialToken,
        firebaseProvider: response.user?.firebaseProvider,
        isEmailVerified: response.user?.isEmailVerified ?? false,
        lastLoginAt: response.user?.lastLoginAt,
      );

      // Guardar usuario en almacenamiento local
      await _localDataSource.saveAuthenticatedUser(user);

      debugPrint('Login tradicional exitoso para: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('Error durante login tradicional: $e');
      rethrow;
    }
  }

  @override
  Future<AuthenticatedUser> loginWithSocial(SocialAuthParams params) async {
    try {
      debugPrint('Iniciando login social con token...');

      // Convertir parámetros de dominio a modelo de request
      final request = SocialAuthRequestModel.fromDomain(params);

      // Realizar petición a la API
      final response = await _remoteDataSource.loginWithSocial(request);

      // Convertir respuesta a entidad de dominio
      final user = response.toDomain(
        userId: response.user?.id,
        email: response.user?.email ?? '',
        name: response.user?.name ?? '',
        photoURL: response.user?.photoURL,
        phone: response.user?.phone,
        role: response.user?.role ?? 'customer',
        socialToken: response.user?.socialToken,
        firebaseProvider: response.user?.firebaseProvider,
        isEmailVerified: response.user?.isEmailVerified ?? true, // Social login generalmente verificado
        lastLoginAt: response.user?.lastLoginAt,
      );

      // Guardar usuario en almacenamiento local
      await _localDataSource.saveAuthenticatedUser(user);

      debugPrint('Login social exitoso para: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('Error durante login social: $e');
      rethrow;
    }
  }

  @override
  Future<AuthenticatedUser> registerUser(RegistrationParams params) async {
    try {
      debugPrint('Iniciando registro tradicional para: ${params.email}');

      // Convertir parámetros de dominio a modelo de request
      final request = RegisterRequestModel.fromDomain(params);

      // Realizar petición a la API
      final response = await _remoteDataSource.registerUser(request);

      // Convertir respuesta a entidad de dominio
      final user = response.toDomain(
        userId: response.user?.id,
        email: response.user?.email ?? params.email,
        name: response.user?.name ?? params.name,
        photoURL: response.user?.photoURL ?? params.photoURL,
        phone: response.user?.phone ?? params.phone,
        role: response.user?.role ?? params.role,
        socialToken: response.user?.socialToken,
        firebaseProvider: response.user?.firebaseProvider,
        isEmailVerified: response.user?.isEmailVerified ?? false,
        lastLoginAt: response.user?.lastLoginAt,
      );

      // Guardar usuario en almacenamiento local
      await _localDataSource.saveAuthenticatedUser(user);

      debugPrint('Registro tradicional exitoso para: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('Error durante registro tradicional: $e');
      rethrow;
    }
  }

  @override
  Future<AuthenticatedUser> registerWithSocial(SocialAuthParams params) async {
    try {
      debugPrint('Iniciando registro social...');

      // Convertir parámetros de dominio a modelo de request
      final request = SocialAuthRequestModel.fromDomain(params);

      // Realizar petición a la API
      final response = await _remoteDataSource.registerWithSocial(request);

      // Convertir respuesta a entidad de dominio
      final user = response.toDomain(
        userId: response.user?.id,
        email: response.user?.email ?? params.additionalData?.email ?? '',
        name: response.user?.name ?? params.additionalData?.name ?? '',
        photoURL: response.user?.photoURL ?? params.additionalData?.photoURL,
        phone: response.user?.phone ?? params.additionalData?.phone,
        role: response.user?.role ?? params.additionalData?.role ?? 'customer',
        socialToken: response.user?.socialToken,
        firebaseProvider: response.user?.firebaseProvider,
        isEmailVerified: response.user?.isEmailVerified ?? true, // Social generalmente verificado
        lastLoginAt: response.user?.lastLoginAt,
      );

      // Guardar usuario en almacenamiento local
      await _localDataSource.saveAuthenticatedUser(user);

      debugPrint('Registro social exitoso para: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('Error durante registro social: $e');
      rethrow;
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      debugPrint('Ejecutando Google Sign-In...');
      return await _firebaseDataSource.signInWithGoogle();
    } catch (e) {
      debugPrint('Error durante Google Sign-In: $e');
      rethrow;
    }
  }

  @override
  Future<String> signInWithApple() async {
    try {
      debugPrint('Ejecutando Apple Sign-In...');
      return await _firebaseDataSource.signInWithApple();
    } catch (e) {
      debugPrint('Error durante Apple Sign-In: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      debugPrint('Iniciando proceso de logout...');

      // Cerrar sesión en Firebase (si aplica)
      if (_firebaseDataSource.isUserSignedIn()) {
        await _firebaseDataSource.signOut();
        debugPrint('Sesión cerrada en Firebase');
      }

      // Limpiar datos locales
      await _localDataSource.clearAuthData();
      debugPrint('Datos locales limpiados');

      debugPrint('Logout completado exitosamente');
    } catch (e) {
      debugPrint('Error durante logout: $e');

      // Intentar limpiar datos locales aunque Firebase falle
      try {
        await _localDataSource.clearAuthData();
        debugPrint('Datos locales limpiados después de error en Firebase');
      } catch (localError) {
        debugPrint('Error al limpiar datos locales: $localError');
      }

      rethrow;
    }
  }

  @override
  Future<AuthenticatedUser?> getCurrentUser() async {
    try {
      return await _localDataSource.getAuthenticatedUser();
    } catch (e) {
      debugPrint('Error al obtener usuario actual: $e');
      return null;
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      return await _localDataSource.isUserAuthenticated();
    } catch (e) {
      debugPrint('Error al verificar autenticación: $e');
      return false;
    }
  }

  @override
  Future<AuthenticatedUser> refreshToken() async {
    try {
      debugPrint('Refrescando token de autenticación...');

      // Obtener token actual
      final currentToken = await _localDataSource.getAccessToken();
      if (currentToken == null) {
        throw const AuthException('No hay token disponible para refrescar');
      }

      // Intentar refrescar con la API
      final response = await _remoteDataSource.refreshToken(currentToken);

      // Obtener usuario actual para preservar datos
      final currentUser = await _localDataSource.getAuthenticatedUser();
      if (currentUser == null) {
        throw const AuthException('No hay usuario autenticado para actualizar');
      }

      // Crear usuario actualizado con nuevo token
      final updatedUser = currentUser.copyWith(
        accessToken: response.accessToken,
        needToChangePassword: response.needToChangePassword,
      );

      // Guardar usuario actualizado
      await _localDataSource.saveAuthenticatedUser(updatedUser);

      debugPrint('Token refrescado exitosamente');
      return updatedUser;
    } catch (e) {
      debugPrint('Error al refrescar token: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _localDataSource.clearAuthData();
      debugPrint('Datos de autenticación limpiados');
    } catch (e) {
      debugPrint('Error al limpiar datos de autenticación: $e');
      // No re-lanzar la excepción para permitir que el logout continúe
    }
  }
}

/// Factory para crear instancias del repositorio
class AuthRepositoryFactory {
  static Future<AuthRepository> create() async {
    final localDataSource = await AuthLocalDataSourceFactory.create();
    final remoteDataSource = AuthRemoteDataSourceFactory.create();
    final firebaseDataSource = AuthFirebaseDataSourceFactory.create();

    return AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      firebaseDataSource: firebaseDataSource,
    );
  }

  static AuthRepository createWithDataSources({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required AuthFirebaseDataSource firebaseDataSource,
  }) {
    return AuthRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
      firebaseDataSource: firebaseDataSource,
    );
  }
}
