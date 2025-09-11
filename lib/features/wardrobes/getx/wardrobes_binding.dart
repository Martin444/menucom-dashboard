import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/wardrobes/getx/wardrobes_controller.dart';
import 'package:pickmeup_dashboard/features/home/controllers/dinning_controller.dart';

class WardrobesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WardrobesController());
    // Asegurar que DinningController esté disponible para las páginas de wardrobes
    Get.lazyPut(() => DinningController(), fenix: true);
  }
}
