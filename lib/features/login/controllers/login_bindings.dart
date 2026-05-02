import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pickmeup_dashboard/features/auth/presentation/controllers/auth_controller.dart';

/// Binding para páginas que requieren el AuthController.
///
/// Este binding asegura que el AuthController unificado esté disponible
/// para las páginas de login, registro y recuperación de contraseña.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Verificar si ya existe el controlador como singleton
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(),
        permanent: true,
      );
      debugPrint('AuthController creado desde LoginBinding');
    } else {
      debugPrint('AuthController ya existe - reutilizando instancia');
    }
  }
}
