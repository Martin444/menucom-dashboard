import 'package:get/get.dart';
import '../navigation/menu_navigation_controller.dart';

/// Binding para registrar automáticamente el controlador de navegación del menú
class MenuNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuNavigationController>(
      () => MenuNavigationController(),
      fenix: true,
    );
  }
}
