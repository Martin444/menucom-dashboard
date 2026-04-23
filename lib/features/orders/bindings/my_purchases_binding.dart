import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/orders/getx/my_purchases_controller.dart';

class MyPurchasesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPurchasesController>(() => MyPurchasesController());
  }
}