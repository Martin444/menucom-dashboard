import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
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
      debugPrint('AuthMiddleware: AuthController no registrado - permitiendo acceso temporal a: $route');
      return null;
    }

    final authController = Get.find<AuthController>();

    // Si está autenticado, permitir acceso
    if (authController.isAuthenticated) {
      debugPrint('AuthMiddleware: Usuario autenticado - permitiendo acceso a: $route');
      return null;
    }

    // Si está verificando, permitir acceso temporal
    if (authController.authState == AuthState.loading ||
        authController.authState == AuthState.initial) {
      debugPrint('AuthMiddleware: Verificando auth - permitiendo acceso temporal a: $route');
      return null;
    }

    // Si no está autenticado, redirigir a login
    debugPrint('AuthMiddleware: No autenticado - redirigiendo a login desde: $route');
    return RouteSettings(name: PURoutes.LOGIN);
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
      return null;
    }

    final authController = Get.find<AuthController>();

    // Si el usuario ya está autenticado, redirigir al dashboard
    if (authController.isAuthenticated) {
      debugPrint('Usuario ya autenticado - redirigiendo a dashboard desde: $route');
      return RouteSettings(name: PURoutes.HOME);
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
      return RouteSettings(name: PURoutes.LOGIN);
    }

    final authController = Get.find<AuthController>();

    // Si ya está autenticado, verificar roles directamente
    if (authController.isAuthenticated) {
      if (!authController.hasAnyRole(requiredRoles)) {
        debugPrint('RoleMiddleware: Usuario sin permisos para: $route');
        return const RouteSettings(name: '/access-denied');
      }
      return null;
    }

    // Si está verificando, permitir acceso temporal
    if (authController.authState == AuthState.loading ||
        authController.authState == AuthState.initial) {
      debugPrint(
          'RoleMiddleware: Verificando auth/roles - permitiendo acceso temporal para: $route');
      return null;
    }

    // Si definitivamente no está autenticado, al login
    debugPrint('RoleMiddleware: No autenticado - redirigiendo a login');
    return RouteSettings(name: PURoutes.LOGIN);
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
      return RouteSettings(name: PURoutes.LOGIN);
    }

    final authController = Get.find<AuthController>();

    // Si ya está autenticado, permitir acceso
    if (authController.isAuthenticated) {
      return null;
    }

    // Si está cargando, permitir acceso temporal
    if (authController.authState == AuthState.loading ||
        authController.authState == AuthState.initial) {
      debugPrint(
          'MembershipMiddleware: Verificando auth - permitiendo acceso temporal a: $route');
      return null;
    }

    return RouteSettings(name: PURoutes.LOGIN);
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
