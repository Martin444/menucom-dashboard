import 'dart:convert';

class ChangePasswordParams {
  final String emailRecovery;
  final int? code;
  final String? newPassword;

  ChangePasswordParams({
    required this.emailRecovery,
    this.code,
    this.newPassword,
  });

  // Método para convertir el objeto a un mapa (para guardar en la base de datos, por ejemplo)
  Map<String, dynamic> toMap() {
    return {
      'emailRecovery': emailRecovery,
      'code': code,
      'newPassword': newPassword,
    };
  }

  // Método para convertir el objeto a JSON (para enviar al servidor, por ejemplo)
  String toJson() => json.encode(toMap());

  // Método para crear un objeto desde un mapa (por ejemplo, al leer de la base de datos)
  factory ChangePasswordParams.fromMap(Map<String, dynamic> map) {
    return ChangePasswordParams(
      emailRecovery: map['emailRecovery'],
      code: map['code'],
      newPassword: map['newPassword'],
    );
  }

  // Método para crear un objeto desde JSON (por ejemplo, al recibir datos del servidor)
  factory ChangePasswordParams.fromJson(String source) => ChangePasswordParams.fromMap(json.decode(source));
}
