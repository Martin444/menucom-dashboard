import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import '../navigation/menu_navigation_items.dart';
import '../../features/home/controllers/dinning_controller.dart';
import 'package:flutter/foundation.dart';

/// Controlador para manejar la navegación del menú lateral
class MenuNavigationController extends GetxController {
  /// Item actualmente seleccionado
  final Rx<MenuNavigationItem?> _currentItem = Rx<MenuNavigationItem?>(MenuNavigationItem.home);

  /// Getter para el item actual
  MenuNavigationItem? get currentItem => _currentItem.value;

  /// Método para determinar si un item está seleccionado
  bool isItemSelected(MenuNavigationItem item) {
    final userRole = _getUserRole().toLowerCase();
    
    if (userRole == 'admin') {
      try {
        final adminController = Get.find<AdminDashboardController>();
        if (item == MenuNavigationItem.home) return adminController.selectedIndex.value == 0 && Get.currentRoute != PURoutes.USER_PROFILE;
        if (item == MenuNavigationItem.users) return adminController.selectedIndex.value == 1;
      } catch (_) {
        // Si no se encuentra el controlador, fallback al comportamiento normal
      }
    }
    
    return _currentItem.value == item;
  }

  /// Método para actualizar el item seleccionado basado en la ruta actual
  void updateCurrentItemFromRoute() {
    final currentRoute = Get.currentRoute;

    for (final item in MenuNavigationItem.values) {
      if (item.config.route == currentRoute) {
        _currentItem.value = item;
        
        // Sincronizar con el dashboard de admin si es necesario
        if (_getUserRole().toLowerCase() == 'admin' && currentRoute == PURoutes.ADMIN_DASHBOARD) {
           try {
             final adminController = Get.find<AdminDashboardController>();
             if (item == MenuNavigationItem.home) adminController.onNavIndexChanged(0);
             if (item == MenuNavigationItem.users) adminController.onNavIndexChanged(1);
           } catch (_) {}
        }
        break;
      }
    }
    update();
  }

  /// Navegar a un item del menú
  void navigateToItem(MenuNavigationItem item) {
    final config = item.config;
    final userRole = _getUserRole().toLowerCase();

    // Si es una acción (como logout)
    if (config.isAction) {
      _handleAction(item);
      return;
    }

    // Si es coming soon
    if (config.isComingSoon) {
      _showComingSoonMessage(config.label);
      return;
    }

    // Manejo especial para el dashboard de administrador
    if (userRole == 'admin') {
      if (item == MenuNavigationItem.home) {
        _currentItem.value = item;
        // Navegar a la raíz o al dashboard admin
        if (Get.currentRoute != PURoutes.HOME && Get.currentRoute != PURoutes.ADMIN_DASHBOARD) {
          Get.toNamed(PURoutes.ADMIN_DASHBOARD);
        }
        
        // Actualizar el índice del dashboard
        try {
          final adminController = Get.find<AdminDashboardController>();
          adminController.onNavIndexChanged(0);
        } catch (_) {
          // El controlador se inicializará con el dashboard
        }
        update();
        return;
      }

      if (item == MenuNavigationItem.users) {
        _currentItem.value = item;
        // Asegurar que estamos en la vista de admin usuarios
        if (Get.currentRoute != PURoutes.ADMIN_USERS) {
          Get.toNamed(PURoutes.ADMIN_USERS);
        } else {
          // Si ya estamos en la ruta, solo cambiar el índice
          try {
            final adminController = Get.find<AdminDashboardController>();
            adminController.onNavIndexChanged(1);
          } catch (_) {}
        }
        update();
        return;
      }
    }

    // Si no es una ruta de navegación válida
    if (!config.isNavigationRoute || config.route == null) {
      return;
    }

    // Manejar rutas dinámicas
    String finalRoute = config.route!;
    if (config.isDynamic) {
      finalRoute = _buildDynamicRoute(finalRoute);
    }

    // Actualizar item seleccionado y navegar
    _currentItem.value = item;
    Get.toNamed(finalRoute);
    update();
  }

  String _getUserRole() {
    try {
      final dinningController = Get.find<DinningController>();
      return dinningController.dinningLogin.role ?? 'guest';
    } catch (e) {
      return 'guest';
    }
  }


  /// Maneja acciones especiales (logout, etc.)
  void _handleAction(MenuNavigationItem item) {
    switch (item) {
      case MenuNavigationItem.logout:
        _handleLogout();
        break;
      default:
        break;
    }
  }

  /// Maneja el logout
  void _handleLogout() {
    final dinningController = Get.find<DinningController>();
    dinningController.closeSesion();
  }

  /// Construye rutas dinámicas reemplazando parámetros
  String _buildDynamicRoute(String route) {
    try {
      final dinningController = Get.find<DinningController>();

      if (route.contains(':idUsuario')) {
        final userName = dinningController.dinningLogin.name?.toLowerCase().split(' ').join('-') ?? 'usuario';
        return route.replaceFirst(':idUsuario', userName);
      }

      return route;
    } catch (e) {
      debugPrint('Error building dynamic route: $e');
      return route;
    }
  }

  /// Muestra mensaje para funcionalidades que vienen pronto
  void _showComingSoonMessage(String feature) {
    Get.snackbar(
      'Próximamente',
      '$feature estará disponible pronto',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Obtiene los items del menú según el rol del usuario
  List<MenuNavigationItem> getMenuItems() {
    try {
      final dinningController = Get.find<DinningController>();
      final userRole = dinningController.dinningLogin.role ?? 'guest';
      return MenuNavigationItem.getItemsByRole(userRole);
    } catch (e) {
      return [MenuNavigationItem.home, MenuNavigationItem.logout];
    }
  }

  /// Inicializar el controlador con la ruta actual
  void initialize() {
    updateCurrentItemFromRoute();
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }
}
