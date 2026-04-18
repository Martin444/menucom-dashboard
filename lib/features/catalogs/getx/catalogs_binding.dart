import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/catalogs/getx/catalogs_controller.dart';

class CatalogsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CatalogsController>(CatalogsController());
  }
}
