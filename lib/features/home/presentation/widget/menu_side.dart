import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    if (!Get.isRegistered<MenuNavigationController>()) {
      Get.put(MenuNavigationController());
    }

    return GetBuilder<DinningController>(
      builder: (dinningController) {
        return GetBuilder<MenuNavigationController>(
          builder: (navController) {
            final menuItems = navController.getMenuItems();
            final mainItems = menuItems
                .where((item) => !MenuNavigationItem.actionItems.contains(item))
                .toList();
            final actionItems = menuItems
                .where((item) => MenuNavigationItem.actionItems.contains(item))
                .toList();

            if (isMobile ?? false) {
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
                      Column(
                        children: [
                          UserAvatarSide(
                            dinningController: dinningController,
                            isMobile: true,
                          ),
                          const SizedBox(height: 24),
                          ...mainItems.map((item) => EnhancedMenuDrawItem(
                                item: item,
                                showBadge: _shouldShowBadge(item),
                                badgeText: _getBadgeText(item),
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          if (actionItems.isNotEmpty) ...[
                            Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: PUColors.iconColor.withOpacity(0.2),
                              ),
                            ),
                          ],
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
                    Column(
                      children: [
                        UserAvatarSide(
                          dinningController: dinningController,
                          isMobile: false,
                        ),
                        const SizedBox(height: 32),
                        ...mainItems.map((item) => EnhancedMenuDrawItem(
                              item: item,
                              showBadge: _shouldShowBadge(item),
                              badgeText: _getBadgeText(item),
                            )),
                      ],
                    ),
                    Column(
                      children: [
                        if (actionItems.isNotEmpty) ...[
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: PUColors.iconColor.withOpacity(0.2),
                            ),
                          ),
                        ],
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

  bool _shouldShowBadge(MenuNavigationItem item) {
    switch (item) {
      case MenuNavigationItem.orders:
        return false;
      default:
        return false;
    }
  }

  String? _getBadgeText(MenuNavigationItem item) {
    switch (item) {
      case MenuNavigationItem.orders:
        return null;
      default:
        return null;
    }
  }
}

class UserAvatarSide extends StatelessWidget {
  final DinningController dinningController;
  final bool isMobile;

  const UserAvatarSide({
    super.key,
    required this.dinningController,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = isMobile ? 80.0 : 100.0;
    final titleFontSize = isMobile ? 14.0 : 16.0;
    final roleFontSize = isMobile ? 10.0 : 12.0;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: PUColors.primaryColor.withAlpha((0.3 * 255).toInt()),
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
        if (dinningController.dinningLogin.name != null) ...[
          Text(
            dinningController.dinningLogin.name ?? 'Usuario',
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
              _formatUserRole(dinningController.dinningLogin.role ?? 'Usuario'),
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

  String _formatUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'dinning':
        return 'Restaurante';
      case 'food':
        return 'Restaurant/Comida';
      case 'clothes':
        return 'Tienda de Ropa';
      case 'retail':
        return 'Comercio General';
      case 'water_distributor':
        return 'Distribuidora de Agua';
      case 'grocery':
        return 'Distribuidora de Alimentos';
      case 'accessories':
        return 'Accesorios';
      case 'electronics':
        return 'Electrónica';
      case 'pharmacy':
        return 'Farmacia';
      case 'beauty':
        return 'Belleza';
      case 'construction':
        return 'Materiales de Construcción';
      case 'automotive':
        return 'Automotriz';
      case 'pets':
        return 'Petshop';
      case 'service':
        return 'Servicios';
      case 'admin':
        return 'Administrador';
      case 'customer':
        return 'Cliente';
      default:
        return role;
    }
  }
}