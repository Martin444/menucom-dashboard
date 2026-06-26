import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_session_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/mp_link_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/form_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/user_role_service.dart';

class DinningBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserSessionController>()) {
      Get.put(UserSessionController(), permanent: true);
    }
    if (!Get.isRegistered<MPLinkController>()) {
      Get.put(MPLinkController(), permanent: true);
    }
    if (!Get.isRegistered<FormController>()) {
      Get.put(FormController(), permanent: true);
    }
    if (!Get.isRegistered<UserRoleService>()) {
      Get.put(UserRoleService(), permanent: true);
    }
    if (!Get.isRegistered<DinningController>()) {
      Get.put(DinningController(), permanent: true);
    }
  }
}
