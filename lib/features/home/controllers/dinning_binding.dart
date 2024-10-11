import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

class DinningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DinningController());
  }
}
