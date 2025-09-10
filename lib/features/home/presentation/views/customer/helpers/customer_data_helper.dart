import 'package:get/get.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../../../../controllers/dinning_controller.dart';

/// Helper para obtener datos de usuarios sin dependencias directas con controladores
///
/// Este helper actúa como intermediario entre los widgets y el controlador,
/// proporcionando una interfaz limpia y desacoplada para obtener datos.
class CustomerDataHelper {
  /// Obtiene usuarios con rol de negocio (dinning y clothes) para mostrar como comercios
  ///
  /// Retorna una lista de comercios basada en usuarios registrados en el sistema
  /// o null si hay error o no hay datos
  static Future<List<CommerceData>?> getFeaturedCommerces() async {
    try {
      // Obtener el controlador si existe
      if (!Get.isRegistered<DinningController>()) {
        return null;
      }

      final dinningController = Get.find<DinningController>();

      // Solicitar usuarios con roles de negocio
      final users = await dinningController.getUsersByRoles(
        roles: [RolesUsers.dinning, RolesUsers.clothes],
        withVinculedAccount: false,
      );

      if (users == null || users.isEmpty) {
        return null;
      }

      // Convertir usuarios a datos de comercio
      return users.map((user) => CommerceData.fromUserByRole(user)).toList();
    } catch (e) {
      // En caso de error, devolver null para que el widget maneje el estado
      return null;
    }
  }

  /// Verifica si hay una carga en progreso
  static bool get isLoadingCommerces {
    if (!Get.isRegistered<DinningController>()) {
      return false;
    }

    final dinningController = Get.find<DinningController>();
    return dinningController.usersByRolesList.isEmpty && dinningController.lastUsersByRolesResponse == null;
  }
}

/// Modelo de datos para representar un comercio
///
/// Convierte datos de usuario a información de comercio para la UI
class CommerceData {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String distance;
  final String imageUrl;
  final String email;
  final String role;

  const CommerceData({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distance,
    required this.imageUrl,
    required this.email,
    required this.role,
  });

  /// Crea un CommerceData desde un UserByRoleModel
  factory CommerceData.fromUserByRole(UserByRoleModel user) {
    return CommerceData(
      id: user.id ?? 'unknown',
      name: (user.name?.isNotEmpty == true) ? user.name! : 'Comercio Sin Nombre',
      category: _getCategoryFromRole(user.role ?? ''),
      rating: _generateRating(), // Rating simulado
      distance: _generateDistance(), // Distancia simulada
      imageUrl: user.photoURL ?? '',
      email: user.email ?? '',
      role: user.role ?? '',
    );
  }

  /// Convierte el rol del usuario en una categoría legible
  static String _getCategoryFromRole(String role) {
    switch (role.toLowerCase()) {
      case 'dinning':
        return 'Restaurante';
      case 'clothes':
        return 'Tienda de Ropa';
      case 'admin':
        return 'Administración';
      default:
        return 'Comercio General';
    }
  }

  /// Genera un rating simulado entre 4.0 y 5.0
  static double _generateRating() {
    final ratings = [4.2, 4.3, 4.5, 4.6, 4.7, 4.8, 4.9];
    ratings.shuffle();
    return ratings.first;
  }

  /// Genera una distancia simulada
  static String _generateDistance() {
    final distances = ['0.3 km', '0.5 km', '0.8 km', '1.2 km', '1.5 km', '2.0 km'];
    distances.shuffle();
    return distances.first;
  }
}
