import '../../domain/entities/authenticated_user.dart';

/// Modelo de datos para la respuesta de autenticación de la API.
///
/// Este modelo mapea la respuesta JSON del backend y la convierte
/// en la entidad de dominio [AuthenticatedUser].
class AuthResponseModel {
  /// Token JWT de acceso
  final String accessToken;

  /// Indica si el usuario necesita cambiar su contraseña
  final bool needToChangePassword;

  /// Datos del usuario (opcional, puede venir en la respuesta)
  final UserDataModel? user;

  const AuthResponseModel({
    required this.accessToken,
    required this.needToChangePassword,
    this.user,
  });

  /// Crea el modelo desde un JSON de respuesta de la API
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] ?? '',
      needToChangePassword: json['needToChangePassword'] ?? false,
      user: json['user'] != null ? UserDataModel.fromJson(json['user']) : null,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'needToChangePassword': needToChangePassword,
      'user': user?.toJson(),
    };
  }

  /// Convierte el modelo a la entidad de dominio
  ///
  /// Requiere datos adicionales del usuario si no vienen en la respuesta
  AuthenticatedUser toDomain({
    String? userId,
    String? email,
    String? name,
    String? photoURL,
    String? phone,
    String? role,
    String? socialToken,
    String? firebaseProvider,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
  }) {
    // Si hay datos del usuario en la respuesta, usarlos
    if (user != null) {
      return user!.toDomain(accessToken: accessToken);
    }

    // Si no, usar los parámetros proporcionados
    return AuthenticatedUser(
      id: userId ?? '',
      email: email ?? '',
      name: name ?? '',
      photoURL: photoURL,
      phone: phone,
      role: role ?? 'customer',
      accessToken: accessToken,
      needToChangePassword: needToChangePassword,
      socialToken: socialToken,
      firebaseProvider: firebaseProvider,
      isEmailVerified: isEmailVerified ?? false,
      lastLoginAt: lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthResponseModel &&
        other.accessToken == accessToken &&
        other.needToChangePassword == needToChangePassword &&
        other.user == user;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^ needToChangePassword.hashCode ^ (user?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: [REDACTED], needToChangePassword: $needToChangePassword, hasUser: ${user != null})';
  }
}

/// Modelo de datos del usuario en las respuestas de la API
class UserDataModel {
  final String id;
  final String email;
  final String name;
  final String? photoURL;
  final String? phone;
  final String role;
  final String? socialToken;
  final String? firebaseProvider;
  final bool isEmailVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserDataModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isEmailVerified,
    this.photoURL,
    this.phone,
    this.socialToken,
    this.firebaseProvider,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea el modelo desde JSON
  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoURL: json['photoURL'],
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      socialToken: json['socialToken'],
      firebaseProvider: json['firebaseProvider'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      createdAt: json['createAt'] != null ? DateTime.parse(json['createAt']) : null,
      updatedAt: json['updateAt'] != null ? DateTime.parse(json['updateAt']) : null,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'phone': phone,
      'role': role,
      'socialToken': socialToken,
      'firebaseProvider': firebaseProvider,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createAt': createdAt?.toIso8601String(),
      'updateAt': updatedAt?.toIso8601String(),
    };
  }

  /// Convierte el modelo a la entidad de dominio
  AuthenticatedUser toDomain({
    required String accessToken,
    bool needToChangePassword = false,
  }) {
    return AuthenticatedUser(
      id: id,
      email: email,
      name: name,
      photoURL: photoURL,
      phone: phone,
      role: role,
      accessToken: accessToken,
      needToChangePassword: needToChangePassword,
      socialToken: socialToken,
      firebaseProvider: firebaseProvider,
      isEmailVerified: isEmailVerified,
      lastLoginAt: lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDataModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photoURL == photoURL &&
        other.phone == phone &&
        other.role == role &&
        other.socialToken == socialToken &&
        other.firebaseProvider == firebaseProvider &&
        other.isEmailVerified == isEmailVerified &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        (photoURL?.hashCode ?? 0) ^
        (phone?.hashCode ?? 0) ^
        role.hashCode ^
        (socialToken?.hashCode ?? 0) ^
        (firebaseProvider?.hashCode ?? 0) ^
        isEmailVerified.hashCode ^
        (lastLoginAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'UserDataModel(id: $id, email: $email, name: $name, role: $role)';
  }
}
