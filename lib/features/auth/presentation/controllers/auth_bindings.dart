import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'auth_controller.dart';

/// Bindings para inyectar dependencias del módulo de autenticación.
///
/// Esta clase se encarga de registrar todas las dependencias necesarias
/// para el módulo de autenticación en el sistema de inyección de GetX.
class AuthBindings extends Bindings {
  @override
  void dependencies() {
    // Registrar el controlador de autenticación como singleton
    // Se mantiene en memoria durante toda la vida de la aplicación
    Get.put<AuthController>(
      AuthController(),
      permanent: true, // No se elimina automáticamente
    );

    debugPrint('AuthController registrado como singleton');
  }
}

/// Bindings específicos para páginas de login que requieren el controlador
/// pero no necesariamente como singleton permanente.
class LoginBindings extends Bindings {
  @override
  void dependencies() {
    // Verificar si ya existe el controlador como singleton
    if (!Get.isRegistered<AuthController>()) {
      // Si no existe, crearlo como singleton
      Get.put<AuthController>(
        AuthController(),
        permanent: true,
      );
      debugPrint('AuthController creado desde LoginBindings');
    } else {
      debugPrint('AuthController ya existe - reutilizando instancia');
    }
  }
}

/// Bindings para páginas que requieren autenticación.
///
/// Estas páginas necesitan verificar que el usuario esté autenticado
/// antes de mostrar el contenido.
class AuthenticatedBindings extends Bindings {
  @override
  void dependencies() {
    // El AuthController debe existir como singleton
    if (!Get.isRegistered<AuthController>()) {
      throw Exception('AuthController no está registrado. Asegúrate de inicializar AuthBindings primero.');
    }

    // Aquí se pueden registrar otros controladores que requieren autenticación
    // Por ejemplo: DashboardController, ProfileController, etc.

    debugPrint('Dependencias para páginas autenticadas verificadas');
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
