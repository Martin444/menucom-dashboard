import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/navigation/menu_navigation_controller.dart';

/// Widget que se encarga de mantener sincronizado el estado de navegación
/// Se debe envolver alrededor de las páginas principales para detectar cambios de ruta
class NavigationStateSync extends StatefulWidget {
  final Widget child;

  const NavigationStateSync({
    super.key,
    required this.child,
  });

  @override
  State<NavigationStateSync> createState() => _NavigationStateSyncState();
}

class _NavigationStateSyncState extends State<NavigationStateSync> with RouteAware {
  MenuNavigationController? _navController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtener el controlador de navegación si está disponible
    if (Get.isRegistered<MenuNavigationController>()) {
      _navController = Get.find<MenuNavigationController>();
      _navController?.updateCurrentItemFromRoute();
    }
  }

  @override
  void didPush() {
    super.didPush();
    _updateNavigationState();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _updateNavigationState();
  }

  void _updateNavigationState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navController?.updateCurrentItemFromRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
