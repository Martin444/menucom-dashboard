import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/auth_request_model.dart';
import '../models/auth_response_model.dart';
import '../../../../core/config.dart';
import '../../domain/usecases/login_with_credentials_usecase.dart';

/// Contrato para el datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  /// Autentica usuario con credenciales tradicionales
  Future<AuthResponseModel> loginWithCredentials(LoginRequestModel request);

  /// Autentica usuario con token social
  Future<AuthResponseModel> loginWithSocial(SocialAuthRequestModel request);

  /// Registra nuevo usuario tradicional
  Future<AuthResponseModel> registerUser(RegisterRequestModel request);

  /// Registra usuario con autenticación social
  Future<AuthResponseModel> registerWithSocial(SocialAuthRequestModel request);

  /// Refresca el token de autenticación
  Future<AuthResponseModel> refreshToken(String currentToken);
}

/// Implementación del datasource remoto usando HTTP
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client httpClient;
  final String baseUrl;

  const AuthRemoteDataSourceImpl({
    required this.httpClient,
    required this.baseUrl,
  });

  @override
  Future<AuthResponseModel> loginWithCredentials(LoginRequestModel request) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      return _handleResponse(response, 'login tradicional');
    } catch (e) {
      throw NetworkException('Error de red durante login tradicional: $e');
    }
  }

  @override
  Future<AuthResponseModel> loginWithSocial(SocialAuthRequestModel request) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/social/login'),
        headers: request.getAuthHeaders(),
        body: request.toJson() != null ? json.encode(request.toJson()) : null,
      );

      return _handleResponse(response, 'login social');
    } catch (e) {
      throw NetworkException('Error de red durante login social: $e');
    }
  }

  @override
  Future<AuthResponseModel> registerUser(RegisterRequestModel request) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      return _handleResponse(response, 'registro tradicional');
    } catch (e) {
      throw NetworkException('Error de red durante registro tradicional: $e');
    }
  }

  @override
  Future<AuthResponseModel> registerWithSocial(SocialAuthRequestModel request) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/social/register'),
        headers: request.getAuthHeaders(),
        body: request.toJson() != null ? json.encode(request.toJson()) : null,
      );

      return _handleResponse(response, 'registro social');
    } catch (e) {
      throw NetworkException('Error de red durante registro social: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String currentToken) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      return _handleResponse(response, 'refresco de token');
    } catch (e) {
      throw NetworkException('Error de red durante refresco de token: $e');
    }
  }

  /// Maneja la respuesta HTTP y convierte errores
  AuthResponseModel _handleResponse(http.Response response, String operation) {
    debugPrint('${operation.toUpperCase()} - Status: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonData = json.decode(response.body);
        return AuthResponseModel.fromJson(jsonData);
      } catch (e) {
        throw AuthException('Error al procesar respuesta del servidor durante $operation');
      }
    } else {
      _handleErrorResponse(response, operation);
    }

    // Esta línea nunca debería ejecutarse debido a las excepciones anteriores
    throw AuthException('Error inesperado durante $operation');
  }

  /// Maneja respuestas de error HTTP
  void _handleErrorResponse(http.Response response, String operation) {
    String errorMessage = 'Error durante $operation';
    String? errorCode;

    try {
      final errorData = json.decode(response.body);
      errorMessage = errorData['message'] ?? errorMessage;
      errorCode = errorData['code'];
    } catch (e) {
      // Si no se puede parsear el error, usar mensaje genérico
      debugPrint('No se pudo parsear error response para $operation: $e');
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationException(errorMessage);
      case 401:
        throw AuthException(errorMessage, code: errorCode ?? 'unauthorized');
      case 403:
        throw const AuthException('Acceso denegado', code: 'forbidden');
      case 404:
        throw const AuthException('Recurso no encontrado', code: 'not_found');
      case 409:
        throw AuthException(errorMessage, code: errorCode ?? 'conflict');
      case 422:
        throw ValidationException(errorMessage);
      case 429:
        throw const AuthException('Demasiadas solicitudes. Intenta más tarde', code: 'rate_limit');
      case 500:
        throw const NetworkException('Error interno del servidor', statusCode: 500);
      case 502:
        throw const NetworkException('Servidor no disponible', statusCode: 502);
      case 503:
        throw const NetworkException('Servicio no disponible', statusCode: 503);
      default:
        throw NetworkException(
          'Error HTTP ${response.statusCode}: $errorMessage',
          statusCode: response.statusCode,
        );
    }
  }
}

/// Factory para crear instancias del datasource remoto
class AuthRemoteDataSourceFactory {
  static AuthRemoteDataSource create() {
    return AuthRemoteDataSourceImpl(
      httpClient: http.Client(),
      baseUrl: URL_PICKME_API,
    );
  }

  static AuthRemoteDataSource createWithClient(http.Client client) {
    return AuthRemoteDataSourceImpl(
      httpClient: client,
      baseUrl: URL_PICKME_API,
    );
  }
}
