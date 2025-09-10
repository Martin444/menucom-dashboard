/// Parámetros requeridos para la autenticación tradicional (email/password)
class LoginCredentials {
  /// Correo electrónico del usuario
  final String email;

  /// Contraseña del usuario
  final String password;

  const LoginCredentials({
    required this.email,
    required this.password,
  });

  /// Convierte los parámetros a un Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
    };
  }

  /// Crea parámetros desde un Map
  factory LoginCredentials.fromMap(Map<String, dynamic> map) {
    return LoginCredentials(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LoginCredentials && other.email == email && other.password == password;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode;

  @override
  String toString() => 'LoginCredentials(email: $email)';
}

/// Parámetros para el registro de nuevos usuarios
class RegistrationParams {
  /// Correo electrónico del usuario
  final String email;

  /// Nombre completo del usuario
  final String name;

  /// Contraseña del usuario (opcional para registro social)
  final String? password;

  /// Número de teléfono del usuario
  final String? phone;

  /// URL de la foto de perfil
  final String? photoURL;

  /// Rol del usuario (por defecto: customer)
  final String role;

  const RegistrationParams({
    required this.email,
    required this.name,
    this.password,
    this.phone,
    this.photoURL,
    this.role = 'customer',
  });

  /// Convierte los parámetros a un Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'phone': phone,
      'photoURL': photoURL,
      'role': role,
    };
  }

  /// Crea parámetros desde un Map
  factory RegistrationParams.fromMap(Map<String, dynamic> map) {
    return RegistrationParams(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      password: map['password'],
      phone: map['phone'],
      photoURL: map['photoURL'],
      role: map['role'] ?? 'customer',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RegistrationParams &&
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
  String toString() => 'RegistrationParams(email: $email, name: $name, role: $role)';
}

/// Parámetros para la autenticación social
class SocialAuthParams {
  /// Token de ID de Firebase/Google
  final String idToken;

  /// Datos adicionales del usuario (para registro)
  final RegistrationParams? additionalData;

  const SocialAuthParams({
    required this.idToken,
    this.additionalData,
  });

  /// Convierte los parámetros a un Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'idToken': idToken,
      'additionalData': additionalData?.toMap(),
    };
  }

  /// Crea parámetros desde un Map
  factory SocialAuthParams.fromMap(Map<String, dynamic> map) {
    return SocialAuthParams(
      idToken: map['idToken'] ?? '',
      additionalData: map['additionalData'] != null ? RegistrationParams.fromMap(map['additionalData']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SocialAuthParams && other.idToken == idToken && other.additionalData == additionalData;
  }

  @override
  int get hashCode => idToken.hashCode ^ (additionalData?.hashCode ?? 0);

  @override
  String toString() => 'SocialAuthParams(idToken: [REDACTED], hasAdditionalData: ${additionalData != null})';
}
