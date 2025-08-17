import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../navigation/menu_navigation_controller.dart';

/// Mixin para páginas que necesitan sincronizar su estado con el menú de navegación
mixin NavigationStateMixin {
  /// Llama este método en el onInit() o onReady() de tus controladores
  void syncNavigationState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<MenuNavigationController>()) {
        final navController = Get.find<MenuNavigationController>();
        navController.updateCurrentItemFromRoute();
      }
    });
  }
}

/// Extension para facilitar la sincronización en controladores GetX
extension NavigationSyncExtension on GetxController {
  /// Sincroniza el estado de navegación con la ruta actual
  void syncNavigationState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<MenuNavigationController>()) {
        final navController = Get.find<MenuNavigationController>();
        navController.updateCurrentItemFromRoute();
      }
    });
  }
}
