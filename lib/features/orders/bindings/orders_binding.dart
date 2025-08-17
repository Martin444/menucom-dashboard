import 'package:get/get.dart';
import '../getx/orders_controller.dart';

/// Binding para la página de órdenes
/// Gestiona la inicialización y disposición del OrdersController
class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy initialization del OrdersController
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
