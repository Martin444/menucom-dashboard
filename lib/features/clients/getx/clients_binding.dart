import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/clients/getx/clients_controller.dart';

class ClientsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientsController>(() => ClientsController());
  }
}
