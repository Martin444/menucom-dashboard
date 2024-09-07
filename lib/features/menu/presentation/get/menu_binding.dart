import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/menu/presentation/get/menu_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MenusController());
  }
}
