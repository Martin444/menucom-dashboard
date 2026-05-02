import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import '../navigation/menu_navigation_items.dart';
import '../../features/home/controllers/dinning_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';

/// Controlador para manejar la navegación del menú lateral
class MenuNavigationController extends GetxController {
  /// Item actualmente seleccionado
  final Rx<MenuNavigationItem?> _currentItem = Rx<MenuNavigationItem?>(MenuNavigationItem.home);

  /// Getter para el item actual
  MenuNavigationItem? get currentItem => _currentItem.value;

  /// Comprueba si un ítem debe mostrarse como seleccionado
  bool isItemSelected(MenuNavigationItem item) {
    final String currentRoute = Get.currentRoute;
    final String userRole = _getUserRole().toLowerCase();
    
    // 1. Caso especial: Cerrar sesión nunca está seleccionado
    if (item == MenuNavigationItem.logout) return false;

    // 2. Match por ruta configurada (Prioridad Máxima)
    final config = item.config;
    if (config.route != null) {
      // Match exacto
      if (currentRoute == config.route) return true;
      
      // Manejo especial para Admin
      if (userRole == 'admin') {
        if (item == MenuNavigationItem.home && 
            (currentRoute == PURoutes.ADMIN_DASHBOARD || currentRoute == '/admin')) {
          return true;
        }
        if (item == MenuNavigationItem.users && 
            (currentRoute == PURoutes.ADMIN_USERS || currentRoute.startsWith('/admin/usuarios'))) {
          return true;
        }
        if (item == MenuNavigationItem.adminMemberships &&
            (currentRoute == PURoutes.ADMIN_MEMBERSHIPS ||
                currentRoute.startsWith('/admin/membresias'))) {
          return true;
        }
      }

      // Match dinámico (ej: /perfil/:idUsuario)
      if (config.isDynamic && _matchDynamicRoute(currentRoute, config.route!)) {
        return true;
      }

      // Match por prefijo (para subrutas, excepto la raíz)
      if (config.route != '/' && currentRoute.startsWith(config.route!)) {
        return true;
      }
    }

    // 3. Si no hay match por ruta, usar la selección en memoria solo como fallback
    // pero verificando que el item actual en memoria REALMENTE sea el que estamos evaluando
    // y que no estemos en una ruta que ya debería haber matcheado con otro item.
    return _currentItem.value == item;
  }

  /// Método para actualizar el item seleccionado basado en la ruta actual
  void updateCurrentItemFromRoute() {
    final currentRoute = Get.currentRoute;
    final userRole = _getUserRole().toLowerCase();

    // Caso especial para rutas de administración
    if (userRole == 'admin') {
      if (currentRoute == PURoutes.ADMIN_DASHBOARD) {
        _currentItem.value = MenuNavigationItem.home;
        update();
        return;
      }
      if (currentRoute == PURoutes.ADMIN_USERS) {
        _currentItem.value = MenuNavigationItem.users;
        update();
        return;
      }
      if (currentRoute == PURoutes.ADMIN_MEMBERSHIPS) {
        _currentItem.value = MenuNavigationItem.adminMemberships;
        update();
        return;
      }
    }

    // Buscar en los items configurados
    for (final item in MenuNavigationItem.values) {
      final config = item.config;
      if (config.route != null) {
        // Comparación exacta
        if (currentRoute == config.route) {
          _currentItem.value = item;
          break;
        }
        
        // Manejo de rutas dinámicas (ej: /perfil/:idUsuario)
        if (config.isDynamic && _matchDynamicRoute(currentRoute, config.route!)) {
          _currentItem.value = item;
          break;
        }
      }
    }
    update();
  }

  /// Verifica si una ruta actual coincide con una ruta base con parámetros
  bool _matchDynamicRoute(String current, String base) {
    if (base.contains(':')) {
      final baseSegments = base.split('/');
      final currentSegments = current.split('/');
      
      if (baseSegments.length != currentSegments.length) return false;
      
      for (int i = 0; i < baseSegments.length; i++) {
        if (!baseSegments[i].startsWith(':') && baseSegments[i] != currentSegments[i]) {
          return false;
        }
      }
      return true;
    }
    return current == base;
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

    // Evitar navegar al mismo ítem si ya estamos en esa ruta
    if (isItemSelected(item) && config.route != null && Get.currentRoute == config.route) {
      return;
    }

    _currentItem.value = item;

    // Manejo especial para el dashboard de administrador
    if (userRole == 'admin') {
      if (item == MenuNavigationItem.home) {
        _updateAdminDashboardIndex(0);
        if (Get.currentRoute != PURoutes.ADMIN_DASHBOARD) {
          Get.toNamed(PURoutes.ADMIN_DASHBOARD);
        }
        update();
        return;
      }
      
      if (item == MenuNavigationItem.users) {
        _updateAdminDashboardIndex(1);
        if (Get.currentRoute != PURoutes.ADMIN_USERS) {
          Get.toNamed(PURoutes.ADMIN_USERS);
        }
        update();
        return;
      }

      if (item == MenuNavigationItem.adminMemberships) {
        _updateAdminDashboardIndex(2);
        if (Get.currentRoute != PURoutes.ADMIN_MEMBERSHIPS) {
          Get.toNamed(PURoutes.ADMIN_MEMBERSHIPS);
        }
        update();
        return;
      }
    }

    // Navegación estándar para otros items o roles
    if (config.isNavigationRoute && config.route != null) {
      final targetRoute = config.isDynamic ? _buildDynamicRoute(config.route!) : config.route!;
      Get.toNamed(targetRoute);
    } else if (config.isComingSoon) {
      _showComingSoonMessage(config.label);
    }

    update();
  }

  /// Actualiza el índice del dashboard de admin si el controlador está registrado
  void _updateAdminDashboardIndex(int index) {
    try {
      if (Get.isRegistered<AdminDashboardController>()) {
        Get.find<AdminDashboardController>().selectedIndex.value = index;
      }
    } catch (_) {}
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
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      // Fallback si AuthController no está (no debería pasar)
      final dinningController = Get.find<DinningController>();
      dinningController.closeSesion();
    }
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
