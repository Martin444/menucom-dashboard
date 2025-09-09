import '../../domain/entities/auth_params.dart';

/// Modelo de datos para la request de login tradicional
class LoginRequestModel {
  final String email;
  final String password;

  const LoginRequestModel({
    required this.email,
    required this.password,
  });

  /// Crea el modelo desde los parámetros de dominio
  factory LoginRequestModel.fromDomain(LoginCredentials credentials) {
    return LoginRequestModel(
      email: credentials.email,
      password: credentials.password,
    );
  }

  /// Convierte el modelo a JSON para la API
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  /// Crea el modelo desde JSON
  factory LoginRequestModel.fromJson(Map<String, dynamic> json) {
    return LoginRequestModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginRequestModel && other.email == email && other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() => 'LoginRequestModel(email: $email)';
}

/// Modelo de datos para la request de registro tradicional
class RegisterRequestModel {
  final String email;
  final String name;
  final String? password;
  final String? phone;
  final String? photoURL;
  final String role;

  const RegisterRequestModel({
    required this.email,
    required this.name,
    this.password,
    this.phone,
    this.photoURL,
    this.role = 'customer',
  });

  /// Crea el modelo desde los parámetros de dominio
  factory RegisterRequestModel.fromDomain(RegistrationParams params) {
    return RegisterRequestModel(
      email: params.email,
      name: params.name,
      password: params.password,
      phone: params.phone,
      photoURL: params.photoURL,
      role: params.role,
    );
  }

  /// Convierte el modelo a JSON para la API
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'name': name,
      'role': role,
    };

    // Solo incluir campos opcionales si tienen valor
    if (password != null) json['password'] = password;
    if (phone != null) json['phone'] = phone;
    if (photoURL != null) json['photoURL'] = photoURL;

    return json;
  }

  /// Crea el modelo desde JSON
  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      password: json['password'],
      phone: json['phone'],
      photoURL: json['photoURL'],
      role: json['role'] ?? 'customer',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegisterRequestModel &&
        other.email == email &&
        other.name == name &&
        other.password == password &&
        other.phone == phone &&
        other.photoURL == photoURL &&
        other.role == role;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        name.hashCode ^
        (password?.hashCode ?? 0) ^
        (phone?.hashCode ?? 0) ^
        (photoURL?.hashCode ?? 0) ^
        role.hashCode;
  }

  @override
  String toString() => 'RegisterRequestModel(email: $email, name: $name, role: $role)';
}

/// Modelo de datos para la request de autenticación social
class SocialAuthRequestModel {
  /// El token de ID se envía en el header Authorization
  final String idToken;

  /// Datos adicionales del usuario (para registro social)
  final RegisterRequestModel? additionalData;

  const SocialAuthRequestModel({
    required this.idToken,
    this.additionalData,
  });

  /// Crea el modelo desde los parámetros de dominio
  factory SocialAuthRequestModel.fromDomain(SocialAuthParams params) {
    return SocialAuthRequestModel(
      idToken: params.idToken,
      additionalData: params.additionalData != null ? RegisterRequestModel.fromDomain(params.additionalData!) : null,
    );
  }

  /// Convierte solo los datos adicionales a JSON
  /// (el token va en el header Authorization)
  Map<String, dynamic>? toJson() {
    return additionalData?.toJson();
  }

  /// Obtiene el header de autorización
  Map<String, String> getAuthHeaders() {
    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SocialAuthRequestModel && other.idToken == idToken && other.additionalData == additionalData;
  }

  @override
  int get hashCode => idToken.hashCode ^ (additionalData?.hashCode ?? 0);

  @override
  String toString() => 'SocialAuthRequestModel(idToken: [REDACTED], hasAdditionalData: ${additionalData != null})';
}
