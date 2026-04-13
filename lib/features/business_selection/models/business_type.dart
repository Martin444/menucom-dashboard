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

  /// Lista de tipos de negocio disponibles (12 tipos del registro)
  static List<BusinessType> get availableTypes => [
        // FOOD - Restaurantes y comida
        const BusinessType(
          id: 'food_store',
          title: 'Restaurant/Comida',
          description:
              'Restaurante, cafetería, panadería o cualquier negocio gastronómico',
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
          id: 'food',
          title: 'Restaurant/Comida',
          description: 'Restaurant, cocina, comida para llevar',
          iconPath: 'assets/business_icons/food_store.svg',
          roleType: RolesUsers.food,
          features: [
            'Gestión de menús',
            'Pedidos online',
            'Delivery',
            'Reservas',
          ],
          colorHex: '#FF6B6B',
        ),
        // CLOTHES - Ropa y accesorios de moda
        const BusinessType(
          id: 'clothes',
          title: 'Tienda de Ropa',
          description:
              'Boutique, tienda de moda o cualquier negocio de vestimenta',
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
        // RETAIL - Venta de productos general
        const BusinessType(
          id: 'retail',
          title: 'Comercio General',
          description: 'Tienda de productos generales, kiosco, librería',
          iconPath: 'assets/business_icons/general_commerce.svg',
          roleType: RolesUsers.retail,
          features: [
            'Inventario múltiple',
            'Ventas rápidas',
            'Control de stock',
            'Facturación simple',
          ],
          colorHex: '#45B7D1',
        ),
        // WATER_DISTRIBUTOR - Distribuidora de agua
        const BusinessType(
          id: 'water_distributor',
          title: 'Distribuidora de Agua',
          description: 'Distribución de água embotellada',
          iconPath: 'assets/business_icons/distributor.svg',
          roleType: RolesUsers.water_distributor,
          features: [
            'Gestión de rutas',
            'Control de tambos',
            'Pedidos recurrentes',
            'Facturación',
          ],
          colorHex: '#00B4D8',
        ),
        // GROCERY - Distribuidora de alimentos
        const BusinessType(
          id: 'grocery',
          title: 'Distribuidora de Alimentos',
          description: 'Mayorista de alimentos, abarrotes',
          iconPath: 'assets/business_icons/distributor.svg',
          roleType: RolesUsers.grocery,
          features: [
            'Ventas por mayor',
            'Catálogo de productos',
            'Precios mayoristas',
            'Entregas',
          ],
          colorHex: '#90BE6D',
        ),
        // ACCESSORIES - Accesorios
        const BusinessType(
          id: 'accessories',
          title: 'Accesorios',
          description: 'Joyería, bolsos, accesorios personales',
          iconPath: 'assets/business_icons/clothes_store.svg',
          roleType: RolesUsers.accessories,
          features: [
            'Catálogo de productos',
            'Gestión de inventario',
            'Variantes',
            'Fotos de producto',
          ],
          colorHex: '#F984E4',
        ),
        // ELECTRONICS - Electrónica
        const BusinessType(
          id: 'electronics',
          title: 'Electrónica',
          description: 'Tienda de dispositivos electrónicos',
          iconPath: 'assets/business_icons/general_commerce.svg',
          roleType: RolesUsers.electronics,
          features: [
            'Catálogo técnico',
            'Garantías',
            'Soporte',
            'Accesorios',
          ],
          colorHex: '#577590',
        ),
        // PHARMACY - Farmacia
        const BusinessType(
          id: 'pharmacy',
          title: 'Farmacia',
          description: 'Farmacia, droguería, productos de salud',
          iconPath: 'assets/business_icons/service.svg',
          roleType: RolesUsers.pharmacy,
          features: [
            'Productos medicinales',
            'Inventario controlado',
            'Asesoría',
            'Entregas',
          ],
          colorHex: '#F94144',
        ),
        // BEAUTY - Belleza
        const BusinessType(
          id: 'beauty',
          title: 'Belleza',
          description: 'Salón, estética, productos de belleza',
          iconPath: 'assets/business_icons/service.svg',
          roleType: RolesUsers.beauty,
          features: [
            'Citas',
            'Servicios',
            'Productos',
            'Promociones',
          ],
          colorHex: '#FF69B4',
        ),
        // CONSTRUCTION - Materiales de construcción
        const BusinessType(
          id: 'construction',
          title: 'Materiales de Construcción',
          description: 'Ferretería, materiales de construcción',
          iconPath: 'assets/business_icons/distributor.svg',
          roleType: RolesUsers.construction,
          features: [
            'Catálogo de materiales',
            'Ventas por mayor',
            'Entregas',
            'Presupuestos',
          ],
          colorHex: '#8D99AE',
        ),
        // AUTOMOTIVE - Automotriz
        const BusinessType(
          id: 'automotive',
          title: 'Automotriz',
          description: 'Repuestos, mecánica, accesorios vehiculares',
          iconPath: 'assets/business_icons/service.svg',
          roleType: RolesUsers.automotive,
          features: [
            'Catálogo de partes',
            'Servicios',
            'Citas',
            'Garantías',
          ],
          colorHex: '#FFD166',
        ),
        // PETS - Petshop
        const BusinessType(
          id: 'pets',
          title: 'Petshop',
          description: 'Tienda para mascotas, alimentos y accesorios',
          iconPath: 'assets/business_icons/general_commerce.svg',
          roleType: RolesUsers.pets,
          features: [
            'Alimentos',
            'Accesorios',
            'Servicios',
            'Citas',
          ],
          colorHex: '#06D6A0',
        ),
        // SERVICE - Servicios profesionales
        const BusinessType(
          id: 'service',
          title: 'Servicios',
          description: 'Consultoría, reparaciones, servicios profesionales',
          iconPath: 'assets/business_icons/service.svg',
          roleType: RolesUsers.service,
          features: [
            'Agenda de citas',
            'Gestión de clientes',
            'Facturación por horas',
            'Seguimiento',
          ],
          colorHex: '#FECA57',
        ),
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
