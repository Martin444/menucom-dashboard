import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import '../controllers/auth_controller.dart';

/// Middleware para proteger rutas que requiere autenticación.
///
/// Este middleware verifica si el usuario está autenticado antes
/// de permitir el acceso a rutas protegidas.
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Verificar primero el token directamente (ya cargado en main.dart)
    // Esto evita problemas de timing con AuthController
    final hasDirectToken = ACCESS_TOKEN.isNotEmpty;
    
    if (!hasDirectToken) {
      // Verificar también en API por si acaso
      final apiToken = API.loginAccessToken;
      if (apiToken.isEmpty) {
        debugPrint('AuthMiddleware: Sin token - redirigiendo a login desde: $route');
        return const RouteSettings(name: '/login');
      }
    }

    // Verificar si el AuthController está disponible
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      
      // Verificar el estado del controller (si ya verificó, usarlo)
      if (authController.authState == AuthState.authenticated) {
        debugPrint('AuthMiddleware: Usuario autenticado - permitiendo acceso a: $route');
        return null;
      }
      
      // Si está verificando, esperar un momento y reintentar
      // Pero permitir acceso si hay token directo
      if (authController.authState == AuthState.loading || 
          authController.authState == AuthState.initial) {
        debugPrint('AuthMiddleware: Verificando auth - permitiendo acceso con token directo');
        return null;
      }
    }

    // Si hay token, permitir acceso (el controller se sincronizará después)
    debugPrint('AuthMiddleware: Token disponible - permitiendo acceso a: $route');
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
    // Verificar primero si hay token directamente (más confiable)
    if (ACCESS_TOKEN.isNotEmpty || API.loginAccessToken.isNotEmpty) {
      debugPrint('GuestMiddleware: Hay token - redirigiendo a dashboard desde: $route');
      return const RouteSettings(name: '/dashboard');
    }

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
      // Si no hay controlador pero hay token, permitir (el controlador se registrará pronto)
      if (ACCESS_TOKEN.isNotEmpty || API.loginAccessToken.isNotEmpty) {
        return null;
      }
      return const RouteSettings(name: '/login');
    }

    final authController = Get.find<AuthController>();

    // 1. Si ya está autenticado, verificar roles directamente
    if (authController.isAuthenticated) {
      if (!authController.hasAnyRole(requiredRoles)) {
        debugPrint('RoleMiddleware: Usuario sin permisos para: $route');
        return const RouteSettings(name: '/access-denied');
      }
      return null;
    }

    // 2. Si está verificando (loading/initial) y hay token, permitir acceso temporal
    // Esto evita que la recarga de página mande al login antes de que AuthController termine
    if (authController.authState == AuthState.loading ||
        authController.authState == AuthState.initial) {
      if (ACCESS_TOKEN.isNotEmpty || API.loginAccessToken.isNotEmpty) {
        debugPrint(
            'RoleMiddleware: Verificando auth/roles - permitiendo acceso temporal con token para: $route');
        return null;
      }
    }

    // 3. Si definitivamente no está autenticado, al login
    debugPrint('RoleMiddleware: No autenticado - redirigiendo a login');
    return const RouteSettings(name: '/login');
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
      if (ACCESS_TOKEN.isNotEmpty || API.loginAccessToken.isNotEmpty) {
        return null;
      }
      return const RouteSettings(name: '/login');
    }

    final authController = Get.find<AuthController>();

    // 1. Si ya está autenticado, permitir acceso (la lógica de membresía se puede agregar aquí luego)
    if (authController.isAuthenticated) {
      return null;
    }

    // 2. Si está cargando y hay token, permitir acceso temporal
    if (authController.authState == AuthState.loading ||
        authController.authState == AuthState.initial) {
      if (ACCESS_TOKEN.isNotEmpty || API.loginAccessToken.isNotEmpty) {
        return null;
      }
    }

    return const RouteSettings(name: '/login');
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
