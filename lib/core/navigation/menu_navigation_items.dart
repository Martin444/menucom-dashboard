import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../routes/routes.dart';

/// Enum que define todos los elementos de navegación disponibles en el menú lateral
enum MenuNavigationItem {
  home,
  orders,
  sales,
  membership,
  clients,
  suppliers,
  profile,
  logout;

  /// Configuración de cada item del menú
  MenuItemConfig get config {
    switch (this) {
      case MenuNavigationItem.home:
        return MenuItemConfig(
          icon: FluentIcons.home_24_regular,
          label: 'Inicio',
          route: PURoutes.HOME,
          isNavigationRoute: true,
        );
      case MenuNavigationItem.orders:
        return MenuItemConfig(
          icon: FluentIcons.clipboard_task_list_ltr_24_regular,
          label: 'Ordenes',
          route: PURoutes.ORDERS_PAGES,
          isNavigationRoute: true,
        );
      case MenuNavigationItem.membership:
        return MenuItemConfig(
          icon: FluentIcons.people_community_24_regular,
          label: 'Membresía',
          route: PURoutes.MEMBERSHIP,
          isNavigationRoute: true,
        );
      case MenuNavigationItem.sales:
        return const MenuItemConfig(
          icon: FluentIcons.money_24_regular,
          label: 'Ventas',
          route: null,
          isNavigationRoute: false,
          isComingSoon: true,
        );
      case MenuNavigationItem.clients:
        return const MenuItemConfig(
          icon: FluentIcons.people_24_regular,
          label: 'Clientes',
          route: null,
          isNavigationRoute: false,
          isComingSoon: true,
        );
      case MenuNavigationItem.suppliers:
        return const MenuItemConfig(
          icon: FluentIcons.building_24_regular,
          label: 'Proveedores',
          route: null,
          isNavigationRoute: false,
          isComingSoon: true,
        );
      case MenuNavigationItem.profile:
        return MenuItemConfig(
          icon: FluentIcons.person_24_regular,
          label: 'Perfil',
          route: PURoutes.USER_PROFILE,
          isNavigationRoute: true,
          isDynamic: true,
        );
      case MenuNavigationItem.logout:
        return const MenuItemConfig(
          icon: FluentIcons.sign_out_24_regular,
          label: 'Cerrar sesión',
          route: null,
          isNavigationRoute: false,
          isAction: true,
        );
    }
  }

  /// Items del menú principal (sin logout que va separado)
  static List<MenuNavigationItem> get mainItems => [
        home,
        orders,
        membership,
        sales,
        clients,
        suppliers,
      ];

  /// Items de acción (como logout)
  static List<MenuNavigationItem> get actionItems => [
        logout,
      ];

  /// Roles que usan catálogo (wardrobe)
  static List<String> get catalogRoles => [
        'clothes',
        'retail',
        'water_distributor',
        'grocery',
        'accessories',
        'electronics',
        'pharmacy',
        'beauty',
        'construction',
        'automotive',
        'pets',
      ];

  /// Roles que usan menú (restaurant)
  static List<String> get menuRoles => ['dinning', 'food'];

  /// Items que están disponibles según el rol del usuario
  static List<MenuNavigationItem> getItemsByRole(String role) {
    final roleLower = role.toLowerCase();
    if (menuRoles.contains(roleLower)) {
      return [home, orders, membership, sales, ...actionItems];
    }
    if (catalogRoles.contains(roleLower)) {
      return [home, orders, membership, sales, ...actionItems];
    }
    switch (roleLower) {
      case 'admin':
        return [...mainItems, ...actionItems];
      case 'customer':
        return [home, orders, membership, ...actionItems];
      default:
        return [home, membership, ...actionItems];
    }
  }
}

/// Configuración de un item del menú
class MenuItemConfig {
  final IconData icon;
  final String label;
  final String? route;
  final bool isNavigationRoute;
  final bool isAction;
  final bool isComingSoon;
  final bool isDynamic;

  const MenuItemConfig({
    required this.icon,
    required this.label,
    this.route,
    this.isNavigationRoute = false,
    this.isAction = false,
    this.isComingSoon = false,
    this.isDynamic = false,
  });
}
