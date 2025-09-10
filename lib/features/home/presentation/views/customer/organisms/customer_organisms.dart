import 'package:flutter/material.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import '../atoms/customer_atoms.dart';
import '../molecules/customer_molecules.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:pu_material/pu_material.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';

/// ORGANISMOS - Combinaciones de moléculas y átomos

/// Organismo: Sección de comercios destacados
class CustomerFeaturedCommerces extends StatelessWidget {
  const CustomerFeaturedCommerces({
    super.key,
    required this.isMobile,
    required this.commercesList,
    required this.isLoading,
    this.onCommerceSelected,
  });

  final bool isMobile;

  /// Lista de usuarios que representan comercios
  final List<UserByRoleModel> commercesList;

  /// Indica si los datos están cargando
  final bool isLoading;

  /// Callback para cuando se selecciona un comercio
  final void Function(UserByRoleModel)? onCommerceSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la sección con contador
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomerSectionTitle(
              text: 'Comercios Registrados',
              fontSize: isMobile ? 16 : 18,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PUColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isLoading ? 'Cargando...' : '${commercesList.length} comercios',
                style: PuTextStyle.brandHeadStyle.copyWith(
                  color: PUColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Contenido principal - loading, empty o grid
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // Estado de carga
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando comercios...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Estado vacío
    if (commercesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.building_shop_24_regular,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay comercios disponibles',
              style: PuTextStyle.brandHeadStyle.copyWith(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los comercios aparecerán aquí cuando estén registrados',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Grid de comercios con datos reales
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        childAspectRatio: isMobile ? 2.0 : 1.3, // Ajustado para contenido compacto
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: commercesList.length,
      itemBuilder: (context, index) {
        final commerce = commercesList[index];
        final calculatedRating = _calculateRating(commerce);
        final calculatedDistance = _calculateDistance(commerce);

        // Debug detallado para cada comercio
        debugPrint('=== COMERCIO $index ===');
        debugPrint('Name: ${commerce.name}');
        debugPrint('Role: ${commerce.role}');
        debugPrint('PhotoURL: ${commerce.photoURL}');
        debugPrint('Email: ${commerce.email}');
        debugPrint('Phone: ${commerce.phone}');
        debugPrint('EmailVerified: ${commerce.isEmailVerified}');
        debugPrint('CreateAt: ${commerce.createAt}');
        debugPrint('LastLoginAt: ${commerce.lastLoginAt}');
        debugPrint('Menus count: ${commerce.menus?.length ?? 0}');
        debugPrint('Total menu items: ${commerce.menus != null ? _calculateTotalMenuItems(commerce.menus!) : 0}');
        debugPrint('Calculated Rating: $calculatedRating');
        debugPrint('Calculated Distance: $calculatedDistance');
        debugPrint('================');

        return CommerceCard(
          name: commerce.name ?? 'Comercio sin nombre',
          category: _getCategoryFromRole(commerce.role),
          rating: calculatedRating, // Rating dinámico basado en datos
          distance: calculatedDistance, // Distancia estimada
          imageUrl: commerce.photoURL ?? '',
          email: commerce.email,
          phone: commerce.phone,
          isEmailVerified: commerce.isEmailVerified,
          memberSince: commerce.createAt,
          lastActivity: commerce.lastLoginAt,
          menus: commerce.menus, // Pasar los menús del comercio
          onTap: () {
            debugPrint('Tapped on ${commerce.name} (${commerce.email})');
            onCommerceSelected?.call(commerce);
          },
        );
      },
    );
  }

  /// Convierte el rol del usuario en una categoría legible
  String _getCategoryFromRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'dinning':
        return 'Restaurante';
      case 'clothes':
        return 'Tienda de Ropa';
      case 'admin':
        return 'Administrador';
      default:
        return 'Comercio';
    }
  }

  /// Calcula un rating dinámico basado en los datos del comercio
  double _calculateRating(UserByRoleModel commerce) {
    double baseRating = 3.0; // Rating base

    // Bonificaciones por verificación y actividad
    if (commerce.isEmailVerified == true) {
      baseRating += 0.5; // +0.5 por email verificado
    }

    // Bonificación por antigüedad (comercios más antiguos tienen mejor rating)
    if (commerce.createAt != null) {
      final daysSinceCreation = DateTime.now().difference(commerce.createAt!).inDays;
      if (daysSinceCreation > 365) {
        baseRating += 0.8; // +0.8 por más de 1 año
      } else if (daysSinceCreation > 180) {
        baseRating += 0.4; // +0.4 por más de 6 meses
      } else if (daysSinceCreation > 30) {
        baseRating += 0.2; // +0.2 por más de 1 mes
      }
    }

    // Bonificación por actividad reciente
    if (commerce.lastLoginAt != null) {
      final daysSinceLastLogin = DateTime.now().difference(commerce.lastLoginAt!).inDays;
      if (daysSinceLastLogin <= 7) {
        baseRating += 0.3; // +0.3 por actividad en la última semana
      } else if (daysSinceLastLogin <= 30) {
        baseRating += 0.1; // +0.1 por actividad en el último mes
      }
    }

    // Bonificación por tener menús y contenido
    if (commerce.menus != null && commerce.menus!.isNotEmpty) {
      final menusCount = commerce.menus!.length;
      final totalItems = _calculateTotalMenuItems(commerce.menus!);

      // Bonificación por cantidad de menús
      if (menusCount >= 3) {
        baseRating += 0.4; // +0.4 por tener 3 o más menús
      } else if (menusCount >= 2) {
        baseRating += 0.2; // +0.2 por tener 2 menús
      } else if (menusCount >= 1) {
        baseRating += 0.1; // +0.1 por tener al menos 1 menú
      }

      // Bonificación por contenido en los menús
      if (totalItems >= 10) {
        baseRating += 0.3; // +0.3 por tener 10 o más items
      } else if (totalItems >= 5) {
        baseRating += 0.2; // +0.2 por tener 5 o más items
      } else if (totalItems >= 1) {
        baseRating += 0.1; // +0.1 por tener al menos 1 item
      }
    }

    // Aseguramos que el rating esté entre 1.0 y 5.0
    return (baseRating).clamp(1.0, 5.0);
  }

  /// Calcula una distancia estimada (simulada por ahora)
  String _calculateDistance(UserByRoleModel commerce) {
    // Por ahora simularemos distancias basadas en el ID o email
    if (commerce.id != null) {
      final hash = commerce.id.hashCode.abs();
      final distance = (hash % 50) / 10.0 + 0.1; // Entre 0.1km y 5.0km
      return '${distance.toStringAsFixed(1)} km';
    }

    if (commerce.email != null) {
      final hash = commerce.email.hashCode.abs();
      final distance = (hash % 50) / 10.0 + 0.1;
      return '${distance.toStringAsFixed(1)} km';
    }

    return 'N/A';
  }

  /// Calcula el total de items en todos los menús de un comercio
  int _calculateTotalMenuItems(List<MenuModel> menus) {
    int total = 0;
    for (final menu in menus) {
      if (menu.items != null) {
        total += menu.items!.length;
      }
    }
    return total;
  }
}

/// Organismo: Sección de información del servicio
class CustomerServiceInfo extends StatelessWidget {
  const CustomerServiceInfo({
    super.key,
    required this.isMobile,
  });

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomerSectionTitle(
          text: 'Información del Servicio',
          fontSize: isMobile ? 16 : 18,
        ),
        const SizedBox(height: 16),
        CustomerContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomerInfoTile(
                icon: FluentIcons.clock_24_regular,
                title: 'Horarios de Atención',
                subtitle: 'Lunes a Domingo: 8:00 AM - 10:00 PM',
              ),
              SizedBox(height: 12),
              CustomerInfoTile(
                icon: FluentIcons.phone_24_regular,
                title: 'Soporte al Cliente',
                subtitle: 'Disponible 24/7 para ayudarte',
              ),
              SizedBox(height: 12),
              CustomerInfoTile(
                icon: FluentIcons.star_24_regular,
                title: 'Programa de Beneficios',
                subtitle: 'Descuentos y promociones exclusivas',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Organismo: Panel lateral con notificaciones
class CustomerSidePanel extends StatelessWidget {
  const CustomerSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomerSectionTitle(
            text: 'Notificaciones',
            fontSize: 16,
          ),

          const SizedBox(height: 16),

          // Notificación placeholder
          const CustomerNotification(
            message: 'No tienes notificaciones nuevas',
            icon: FluentIcons.info_24_regular,
          ),

          const SizedBox(height: 12),

          // Estadísticas rápidas
          CustomerSectionTitle(
            text: 'Estadísticas',
            fontSize: 14,
          ),

          const SizedBox(height: 8),

          const CustomerInfoTile(
            icon: FluentIcons.receipt_24_regular,
            title: 'Pedidos Realizados',
            subtitle: '0 este mes',
          ),
        ],
      ),
    );
  }
}
