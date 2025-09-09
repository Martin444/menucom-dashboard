import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Middleware para proteger rutas que requieren autenticación.
///
/// Este middleware verifica si el usuario está autenticado antes
/// de permitir el acceso a rutas protegidas.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Verificar si el AuthController está disponible
    if (!Get.isRegistered<AuthController>()) {
      debugPrint('AuthController no registrado - redirigiendo a login');
      return const RouteSettings(name: '/login');
    }

    final authController = Get.find<AuthController>();

    // Si el usuario no está autenticado, redirigir a login
    if (!authController.isAuthenticated) {
      debugPrint('Usuario no autenticado - redirigiendo a login desde: $route');
      return const RouteSettings(name: '/login');
    }

    // Si el usuario está autenticado, permitir acceso
    debugPrint('Usuario autenticado - permitiendo acceso a: $route');
    return null;
  }
}

/// Middleware para rutas de invitados (como login, registro).
///
/// Este middleware redirige a usuarios ya autenticados lejos
/// de páginas como login y registro.
class GuestMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Verificar si el AuthController está disponible
    if (!Get.isRegistered<AuthController>()) {
      // Si no está registrado, permitir acceso (probablemente es la primera vez)
      return null;
    }

    final authController = Get.find<AuthController>();

    // Si el usuario ya está autenticado, redirigir al dashboard
    if (authController.isAuthenticated) {
      debugPrint('Usuario ya autenticado - redirigiendo a dashboard desde: $route');
      return const RouteSettings(name: '/dashboard');
    }

    // Si no está autenticado, permitir acceso a la página de invitados
    return null;
  }
}

/// Middleware para verificar roles específicos.
///
/// Este middleware verifica que el usuario autenticado tenga
/// el rol requerido para acceder a ciertas rutas.
class RoleMiddleware extends GetMiddleware {
  final List<String> requiredRoles;

  RoleMiddleware({required this.requiredRoles});

  @override
  int? get priority => 2; // Ejecutar después del AuthMiddleware

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: '/login');
    }

    final authController = Get.find<AuthController>();

    // Verificar autenticación primero
    if (!authController.isAuthenticated) {
      return const RouteSettings(name: '/login');
    }

    // Verificar roles
    if (!authController.hasAnyRole(requiredRoles)) {
      debugPrint('Usuario sin permisos para acceder a: $route');
      debugPrint('Roles requeridos: $requiredRoles');
      debugPrint('Rol del usuario: ${authController.currentUser?.role}');

      // Redirigir a página de acceso denegado o dashboard principal
      return const RouteSettings(name: '/access-denied');
    }

    return null;
  }
}

/// Middleware específico para administradores
class AdminMiddleware extends RoleMiddleware {
  AdminMiddleware() : super(requiredRoles: ['admin']);
}

/// Middleware específico para usuarios pro
class ProMiddleware extends RoleMiddleware {
  ProMiddleware() : super(requiredRoles: ['admin', 'pro']);
}

/// Middleware específico para operadores
class OperatorMiddleware extends RoleMiddleware {
  OperatorMiddleware() : super(requiredRoles: ['admin', 'operador']);
}

/// Middleware para verificación de membresías activas
class MembershipMiddleware extends GetMiddleware {
  @override
  int? get priority => 3; // Ejecutar después de Auth y Role middlewares

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<AuthController>()) {
      return const RouteSettings(name: '/login');
    }

    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated) {
      return const RouteSettings(name: '/login');
    }

    // TODO: Implementar verificación de membresía
    // Aquí puedes agregar lógica para verificar si el usuario
    // tiene una membresía activa válida

    // Por ahora, permitir acceso
    return null;
  }
}

/// Utilitarios para manejo de middlewares
class AuthMiddlewareUtils {
  /// Crea una lista de middlewares para rutas protegidas básicas
  static List<GetMiddleware> protectedRoute() {
    return [AuthMiddleware()];
  }

  /// Crea una lista de middlewares para rutas de invitados
  static List<GetMiddleware> guestRoute() {
    return [GuestMiddleware()];
  }

  /// Crea una lista de middlewares para rutas de administrador
  static List<GetMiddleware> adminRoute() {
    return [AuthMiddleware(), AdminMiddleware()];
  }

  /// Crea una lista de middlewares para rutas pro
  static List<GetMiddleware> proRoute() {
    return [AuthMiddleware(), ProMiddleware()];
  }

  /// Crea una lista de middlewares para rutas de operador
  static List<GetMiddleware> operatorRoute() {
    return [AuthMiddleware(), OperatorMiddleware()];
  }

  /// Crea una lista de middlewares con roles personalizados
  static List<GetMiddleware> customRoleRoute(List<String> roles) {
    return [AuthMiddleware(), RoleMiddleware(requiredRoles: roles)];
  }

  /// Crea una lista de middlewares con verificación de membresía
  static List<GetMiddleware> membershipRoute() {
    return [AuthMiddleware(), MembershipMiddleware()];
  }
}
