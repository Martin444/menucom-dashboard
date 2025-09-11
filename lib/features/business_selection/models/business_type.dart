import 'package:menu_dart_api/by_feature/user/get_me_profile/model/roles_users.dart';

/// Modelo que representa un tipo de negocio con información visual y funcional
class BusinessType {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final RolesUsers roleType;
  final List<String> features;
  final String colorHex;

  const BusinessType({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.roleType,
    required this.features,
    required this.colorHex,
  });

  /// Lista de tipos de negocio disponibles
  static List<BusinessType> get availableTypes => [
        const BusinessType(
          id: 'food_store',
          title: 'Tienda de Comida',
          description: 'Restaurante, cafetería, panadería o cualquier negocio gastronómico',
          iconPath: 'assets/business_icons/food_store.svg',
          roleType: RolesUsers.dinning,
          features: [
            'Gestión de menús',
            'Control de inventario',
            'Pedidos online',
            'Delivery integrado',
          ],
          colorHex: '#FF6B6B',
        ),
        const BusinessType(
          id: 'clothes',
          title: 'Tienda de Ropa',
          description: 'Boutique, tienda de moda o cualquier negocio de vestimenta',
          iconPath: 'assets/business_icons/clothes_store.svg',
          roleType: RolesUsers.clothes,
          features: [
            'Catálogo de productos',
            'Gestión de tallas',
            'Colecciones por temporada',
            'Tendencias de moda',
          ],
          colorHex: '#4ECDC4',
        ),
        // const BusinessType(
        //   id: 'general_commerce',
        //   title: 'Comercio General',
        //   description: 'Tienda de productos variados, kiosco, librería, etc.',
        //   iconPath: 'assets/business_icons/general_commerce.svg',
        //   roleType: RolesUsers.commerce,
        //   features: [
        //     'Inventario múltiple',
        //     'Ventas rápidas',
        //     'Control de stock',
        //     'Facturación simple',
        //   ],
        //   colorHex: '#45B7D1',
        // ),
        const BusinessType(
          id: 'service',
          title: 'Servicio',
          description: 'Consultoría, reparaciones, servicios profesionales',
          iconPath: 'assets/business_icons/service.svg',
          roleType: RolesUsers.service,
          features: [
            'Agenda de citas',
            'Gestión de clientes',
            'Facturación por horas',
            'Seguimiento de proyectos',
          ],
          colorHex: '#FECA57',
        ),
        // const BusinessType(
        //   id: 'distributor',
        //   title: 'Distribuidor',
        //   description: 'Mayorista, proveedor o distribución a gran escala',
        //   iconPath: 'assets/business_icons/distributor.svg',
        //   roleType: RolesUsers.distributor,
        //   features: [
        //     'Ventas por mayor',
        //     'Gestión de clientes',
        //     'Logística avanzada',
        //     'Reportes detallados',
        //   ],
        //   colorHex: '#96CEB4',
        // ),
      ];

  /// Obtener tipo de negocio por ID
  static BusinessType? getById(String id) {
    try {
      return availableTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener tipo de negocio por rol
  static BusinessType? getByRole(RolesUsers role) {
    try {
      return availableTypes.firstWhere((type) => type.roleType == role);
    } catch (e) {
      return null;
    }
  }
}
