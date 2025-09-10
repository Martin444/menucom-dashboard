import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pu_material/utils/style/pu_style_containers.dart';
import 'package:pu_material/utils/style/pu_style_fonts.dart';
import 'package:pu_material/pu_material.dart';

import '../../../../core/navigation/menu_navigation_controller.dart';
import '../../../../core/navigation/menu_navigation_items.dart';
import '../../../../widgets/enhanced_menu_draw_item.dart';
import '../../controllers/dinning_controller.dart';

class MenuSide extends StatelessWidget {
  final bool? isMobile;

  const MenuSide({
    super.key,
    this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    // Inicializar el controlador de navegación si no existe
    if (!Get.isRegistered<MenuNavigationController>()) {
      Get.put(MenuNavigationController());
    }

    return GetBuilder<DinningController>(
      builder: (dinningController) {
        return GetBuilder<MenuNavigationController>(
          builder: (navController) {
            final menuItems = navController.getMenuItems();
            final mainItems = menuItems.where((item) => !MenuNavigationItem.actionItems.contains(item)).toList();
            final actionItems = menuItems.where((item) => MenuNavigationItem.actionItems.contains(item)).toList();

            if (isMobile ?? false) {
              // Versión móvil como Drawer
              return Drawer(
                backgroundColor: PUColors.bgItem.withOpacity(0.3),
                elevation: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: PuStyleContainers.borderLeftContainer.copyWith(
                    color: PUColors.primaryBackground,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sección principal del menú
                      Column(
                        children: [
                          // Avatar del usuario - versión compacta para móvil
                          _buildUserAvatar(dinningController, true),
                          const SizedBox(height: 24),
                          // Items principales del menú
                          ...mainItems.map((item) => EnhancedMenuDrawItem(
                                item: item,
                                showBadge: _shouldShowBadge(item),
                                badgeText: _getBadgeText(item),
                              )),
                        ],
                      ),
                      // Sección de acciones (logout, etc.)
                      Column(
                        children: [
                          // Divider si hay items de acción
                          if (actionItems.isNotEmpty) ...[
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: PUColors.iconColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                          // Items de acción
                          ...actionItems.map((item) => EnhancedMenuDrawItem(
                                item: item,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Versión desktop como panel lateral fijo
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                decoration: PuStyleContainers.borderLeftContainer.copyWith(
                  color: PUColors.primaryBackground,
                  border: Border(
                    right: BorderSide(
                      color: PUColors.iconColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sección principal del menú
                    Column(
                      children: [
                        // Avatar del usuario - versión desktop
                        _buildUserAvatar(dinningController, false),
                        const SizedBox(height: 32),
                        // Items principales del menú
                        ...mainItems.map((item) => EnhancedMenuDrawItem(
                              item: item,
                              showBadge: _shouldShowBadge(item),
                              badgeText: _getBadgeText(item),
                            )),
                      ],
                    ),
                    // Sección de acciones (logout, etc.)
                    Column(
                      children: [
                        // Divider si hay items de acción
                        if (actionItems.isNotEmpty) ...[
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: PUColors.iconColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                        // Items de acción
                        ...actionItems.map((item) => EnhancedMenuDrawItem(
                              item: item,
                            )),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  /// Construye el avatar del usuario con información
  Widget _buildUserAvatar(DinningController dinningController, [bool isMobile = false]) {
    final avatarSize = isMobile ? 80.0 : 100.0;
    final titleFontSize = isMobile ? 14.0 : 16.0;
    final roleFontSize = isMobile ? 10.0 : 12.0;

    return Column(
      children: [
        // Avatar circular
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: PUColors.primaryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: PuRobustNetworkImage(
              imageUrl: dinningController.dinningLogin.photoURL ?? '',
              height: avatarSize,
              width: avatarSize,
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: isMobile ? 12 : 16),

        // Nombre del usuario
        if (dinningController.dinningLogin.name != null) ...[
          Text(
            dinningController.dinningLogin.name!,
            style: PuTextStyle.title3.copyWith(
              fontWeight: FontWeight.w600,
              color: PUColors.iconColor,
              fontSize: titleFontSize,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
        ],

        // Rol del usuario
        if (dinningController.dinningLogin.role != null) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 8 : 12,
              vertical: isMobile ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: PUColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _formatUserRole(dinningController.dinningLogin.role!),
              style: PuTextStyle.description1.copyWith(
                color: PUColors.primaryColor,
                fontSize: roleFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Formatea el rol del usuario para mostrar
  String _formatUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'dinning':
        return 'Restaurante';
      case 'clothes':
        return 'Tienda de Ropa';
      case 'admin':
        return 'Administrador';
      case 'customer':
        return 'Cliente';
      default:
        return role;
    }
  }

  /// Determina si un item debe mostrar badge
  bool _shouldShowBadge(MenuNavigationItem item) {
    switch (item) {
      case MenuNavigationItem.orders:
        // Aquí podrías agregar lógica para mostrar cantidad de órdenes pendientes
        return false;
      default:
        return false;
    }
  }

  /// Obtiene el texto del badge para un item
  String? _getBadgeText(MenuNavigationItem item) {
    switch (item) {
      case MenuNavigationItem.orders:
        // Aquí podrías obtener la cantidad real de órdenes pendientes
        return null;
      default:
        return null;
    }
  }
}
