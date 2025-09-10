import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../../routes/routes.dart';

/// Enum que define todos los elementos de navegación disponibles en el menú lateral
enum MenuNavigationItem {
  home,
  orders,
  sales,
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
      case MenuNavigationItem.sales:
        return const MenuItemConfig(
          icon: FluentIcons.money_24_regular,
          label: 'Ventas',
          route: null, // No implementado aún
          isNavigationRoute: false,
          isComingSoon: true,
        );
      case MenuNavigationItem.clients:
        return const MenuItemConfig(
          icon: FluentIcons.people_24_regular,
          label: 'Clientes',
          route: null, // No implementado aún
          isNavigationRoute: false,
          isComingSoon: true,
        );
      case MenuNavigationItem.suppliers:
        return const MenuItemConfig(
          icon: FluentIcons.building_24_regular,
          label: 'Proveedores',
          route: null, // No implementado aún
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
        sales,
        clients,
        suppliers,
      ];

  /// Items de acción (como logout)
  static List<MenuNavigationItem> get actionItems => [
        logout,
      ];

  /// Items que están disponibles según el rol del usuario
  static List<MenuNavigationItem> getItemsByRole(String role) {
    // Aquí puedes implementar lógica para mostrar diferentes items según el rol
    switch (role.toLowerCase()) {
      case 'admin':
        return [...mainItems, ...actionItems];
      case 'dinning':
        return [home, orders, sales, ...actionItems];
      case 'clothes':
        return [home, orders, sales, ...actionItems];
      case 'customer':
        return [home, orders, ...actionItems];
      default:
        return [home, ...actionItems];
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
