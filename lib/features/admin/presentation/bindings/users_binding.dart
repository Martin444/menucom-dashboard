import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/admin/presentation/controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersController>(() => UsersController());
  }
}