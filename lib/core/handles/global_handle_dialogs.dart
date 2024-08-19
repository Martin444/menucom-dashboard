import 'package:get/get.dart';
import 'package:pu_material/utils/pu_colors.dart';

class GlobalDialogsHandles {
  static void snackbarError({
    required String title,
    String? message,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: PUColors.bgError,
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }
}
