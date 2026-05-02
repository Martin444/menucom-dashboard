import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'auth_controller.dart';

/// Bindings principal para inyectar dependencias del módulo de autenticación.
///
/// Esta clase se encarga de registrar el AuthController unificado
/// como singleton permanente en el sistema de inyección de GetX.
class AuthBindings extends Bindings {
  @override
  void dependencies() {
    // Registrar el controlador unificado de autenticación como singleton
    // Se mantiene en memoria durante toda la vida de la aplicación
    Get.put<AuthController>(
      AuthController(),
      permanent: true, // No se elimina automáticamente
    );

    debugPrint('AuthController unificado registrado como singleton');
  }
}

/// Clase utilitaria para manejar la inicialización global de autenticación
class AuthInitializer {
  /// Inicializa el sistema de autenticación de forma global
  static void initialize() {
    // Registrar bindings globales de autenticación
    AuthBindings().dependencies();

    debugPrint('Sistema de autenticación inicializado globalmente');
  }

  /// Verifica si el sistema de autenticación está inicializado
  static bool isInitialized() {
    return Get.isRegistered<AuthController>();
  }

  /// Obtiene la instancia del controlador de autenticación
  static AuthController getAuthController() {
    if (!isInitialized()) {
      throw Exception('Sistema de autenticación no inicializado');
    }

    return Get.find<AuthController>();
  }
}
