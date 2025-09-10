/// Entidad que representa un usuario autenticado en el sistema.
///
/// Esta entidad contiene la información esencial del usuario después
/// de un proceso de autenticación exitoso, incluyendo tanto autenticación
/// tradicional como social (Firebase/Google).
class AuthenticatedUser {
  /// Identificador único del usuario en el sistema
  final String id;

  /// Correo electrónico del usuario
  final String email;

  /// Nombre completo del usuario
  final String name;

  /// URL de la foto de perfil del usuario
  final String? photoURL;

  /// Número de teléfono del usuario
  final String? phone;

  /// Rol del usuario en el sistema
  final String role;

  /// Token JWT para autenticación en el backend
  final String accessToken;

  /// Indica si el usuario necesita cambiar su contraseña
  final bool needToChangePassword;

  /// Token de Firebase para autenticación social (si aplica)
  final String? socialToken;

  /// Proveedor de autenticación social (google.com, apple.com, etc.)
  final String? firebaseProvider;

  /// Indica si el email ha sido verificado
  final bool isEmailVerified;

  /// Fecha del último login
  final DateTime? lastLoginAt;

  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.accessToken,
    required this.needToChangePassword,
    required this.isEmailVerified,
    this.photoURL,
    this.phone,
    this.socialToken,
    this.firebaseProvider,
    this.lastLoginAt,
  });

  /// Crea una copia del usuario con algunos campos modificados
  AuthenticatedUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoURL,
    String? phone,
    String? role,
    String? accessToken,
    bool? needToChangePassword,
    String? socialToken,
    String? firebaseProvider,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
  }) {
    return AuthenticatedUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      accessToken: accessToken ?? this.accessToken,
      needToChangePassword: needToChangePassword ?? this.needToChangePassword,
      socialToken: socialToken ?? this.socialToken,
      firebaseProvider: firebaseProvider ?? this.firebaseProvider,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Convierte la entidad a un Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'phone': phone,
      'role': role,
      'accessToken': accessToken,
      'needToChangePassword': needToChangePassword,
      'socialToken': socialToken,
      'firebaseProvider': firebaseProvider,
      'isEmailVerified': isEmailVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Crea una entidad desde un Map
  factory AuthenticatedUser.fromMap(Map<String, dynamic> map) {
    return AuthenticatedUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoURL: map['photoURL'],
      phone: map['phone'],
      role: map['role'] ?? '',
      accessToken: map['accessToken'] ?? '',
      needToChangePassword: map['needToChangePassword'] ?? false,
      socialToken: map['socialToken'],
      firebaseProvider: map['firebaseProvider'],
      isEmailVerified: map['isEmailVerified'] ?? false,
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.parse(map['lastLoginAt']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthenticatedUser &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photoURL == photoURL &&
        other.phone == phone &&
        other.role == role &&
        other.accessToken == accessToken &&
        other.needToChangePassword == needToChangePassword &&
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
        accessToken.hashCode ^
        needToChangePassword.hashCode ^
        (socialToken?.hashCode ?? 0) ^
        (firebaseProvider?.hashCode ?? 0) ^
        isEmailVerified.hashCode ^
        (lastLoginAt?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'AuthenticatedUser(id: $id, email: $email, name: $name, role: $role, isEmailVerified: $isEmailVerified)';
  }
}
