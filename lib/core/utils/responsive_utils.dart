import 'package:flutter/material.dart';

/// Utilidades para diseño responsivo
///
/// Proporciona métodos helper para determinar el tipo de dispositivo
/// y aplicar diseños adaptativos según el tamaño de pantalla.
class ResponsiveUtils {
  // Breakpoints para diseño responsivo
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1200;

  /// Determina si el dispositivo es móvil
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  /// Determina si el dispositivo es tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  /// Determina si el dispositivo es desktop/web
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Determina si el dispositivo es web (tablet o desktop)
  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Obtiene el padding adaptativo según el dispositivo
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Obtiene el máximo ancho para contenido centrado
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 800;
    }
  }

  /// Obtiene el número de columnas para grids adaptativos
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  /// Obtiene el espaciado adaptativo
  static double getAdaptiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 24;
    } else {
      return 32;
    }
  }
}
