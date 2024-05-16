import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/login/presentation/controllers/login_controller.dart';

class MainBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => LoginController(),
      fenix: true,
    );
  }
}
