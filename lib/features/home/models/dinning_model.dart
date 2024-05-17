class DinningModel {
  String? id;
  String? photoURL;
  String? name;
  String? email;
  String? phone;
  String? password;
  String? role;
  DateTime? createAt;
  DateTime? updateAt;

  DinningModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.role,
    this.createAt,
    this.updateAt,
    this.photoURL,
  });

  static DinningModel fromJson(Map<String, dynamic> json) {
    return DinningModel(
      id: json['id'] ?? '',
      name: json['name'] ??
          'Sin nombre', // Asigna un valor por defecto si es nulo
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoURL: json['photoURL'] ?? '',
      role: json['role'] ?? '',
      createAt: json['createAt'] == null
          ? null
          : DateTime.parse(
              json['createAt']), // Evita llamar a DateTime.parse si es nulo
      updateAt:
          json['updateAt'] == null ? null : DateTime.parse(json['updateAt']),
    );
  }
}
