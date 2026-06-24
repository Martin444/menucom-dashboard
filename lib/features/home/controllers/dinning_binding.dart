import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_session_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/mp_link_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/form_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_role_service.dart';

class DinningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserSessionController(), fenix: true);
    Get.lazyPut(() => MPLinkController(), fenix: true);
    Get.lazyPut(() => FormController(), fenix: true);
    Get.lazyPut(() => UserRoleService(), fenix: true);
    Get.lazyPut(() => DinningController(), fenix: true);
  }
}
