import 'package:get/get.dart';
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
    return _currentItem.value == item;
  }

  /// Método para actualizar el item seleccionado basado en la ruta actual
  void updateCurrentItemFromRoute() {
    final currentRoute = Get.currentRoute;

    for (final item in MenuNavigationItem.values) {
      if (item.config.route == currentRoute) {
        _currentItem.value = item;
        break;
      }
    }
    update();
  }

  /// Navegar a un item del menú
  void navigateToItem(MenuNavigationItem item) {
    final config = item.config;

    // Si es una acción (como logout)
    if (config.isAction) {
      _handleAction(item);
      return;
    }

    // Si es una ruta que viene pronto
    if (config.isComingSoon) {
      _showComingSoonMessage(config.label);
      return;
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

      // Reemplazar parámetros según sea necesario
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
      // Si no se puede obtener el rol, mostrar items básicos
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
