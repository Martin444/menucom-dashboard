import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/wardrobes/getx/wardrobes_controller.dart';

class WardrobesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WardrobesController());
  }
}
