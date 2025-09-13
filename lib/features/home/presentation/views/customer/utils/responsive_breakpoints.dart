import 'package:flutter/material.dart';

/// Responsive Breakpoints - Unified breakpoint system for customer view
///
/// This utility provides consistent breakpoint definitions across all
/// customer view components to ensure uniform responsive behavior.

class ResponsiveBreakpoints {
  // Primary breakpoints
  static const double mobile = 768;
  static const double tablet = 1200;
  static const double desktop = 1600;

  // Secondary breakpoints for fine-tuned control
  static const double smallMobile = 480;
  static const double largeTablet = 1024;
  static const double largeDesktop = 1920;

  /// Check if current width is mobile
  static bool isMobile(double width) => width < mobile;

  /// Check if current width is tablet
  static bool isTablet(double width) => width >= mobile && width < tablet;

  /// Check if current width is desktop
  static bool isDesktop(double width) => width >= tablet;

  /// Check if current width is small mobile
  static bool isSmallMobile(double width) => width < smallMobile;

  /// Check if current width is large tablet
  static bool isLargeTablet(double width) => width >= largeTablet && width < tablet;

  /// Check if current width is large desktop
  static bool isLargeDesktop(double width) => width >= largeDesktop;

  /// Get device category as string
  static String getDeviceCategory(double width) {
    if (isSmallMobile(width)) return 'small-mobile';
    if (isMobile(width)) return 'mobile';
    if (isTablet(width)) return 'tablet';
    if (isLargeDesktop(width)) return 'large-desktop';
    return 'desktop';
  }

  /// Get grid column count based on device and content type
  static int getGridColumns(double width, {bool isCompact = false}) {
    if (isCompact) {
      // Compact mode: prioritize density
      if (isLargeDesktop(width)) return 5;
      if (isDesktop(width)) return 4;
      if (isLargeTablet(width)) return 3;
      if (isTablet(width)) return 2;
      return 1; // Mobile
    } else {
      // Normal mode: prioritize content visibility
      if (isLargeDesktop(width)) return 4;
      if (isDesktop(width)) return 3;
      if (isTablet(width)) return 2;
      return 1; // Mobile
    }
  }

  /// Get responsive padding based on device
  static double getResponsivePadding(double width, {double basePadding = 16}) {
    if (isSmallMobile(width)) return basePadding * 0.75;
    if (isMobile(width)) return basePadding;
    if (isTablet(width)) return basePadding * 1.25;
    return basePadding * 1.5; // Desktop
  }

  /// Get responsive spacing based on device
  static double getResponsiveSpacing(double width, {double baseSpacing = 16}) {
    if (isSmallMobile(width)) return baseSpacing * 0.75;
    if (isMobile(width)) return baseSpacing;
    if (isTablet(width)) return baseSpacing * 1.125;
    return baseSpacing * 1.25; // Desktop
  }

  /// Get responsive font size scaling factor
  static double getFontScaling(double width) {
    if (isSmallMobile(width)) return 0.9;
    if (isMobile(width)) return 1.0;
    if (isTablet(width)) return 1.1;
    return 1.2; // Desktop
  }

  /// Get responsive aspect ratio for cards
  static double getCardAspectRatio(double width, {double baseRatio = 1.0}) {
    if (isMobile(width)) return baseRatio * 1.2; // Taller cards on mobile
    if (isTablet(width)) return baseRatio * 1.1; // Slightly taller on tablet
    return baseRatio; // Base ratio for desktop
  }
}

/// Extension for MediaQuery to easily access responsive utilities
extension MediaQueryResponsive on MediaQueryData {
  bool get isMobile => ResponsiveBreakpoints.isMobile(size.width);
  bool get isTablet => ResponsiveBreakpoints.isTablet(size.width);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(size.width);
  bool get isSmallMobile => ResponsiveBreakpoints.isSmallMobile(size.width);
  bool get isLargeTablet => ResponsiveBreakpoints.isLargeTablet(size.width);
  bool get isLargeDesktop => ResponsiveBreakpoints.isLargeDesktop(size.width);

  String get deviceCategory => ResponsiveBreakpoints.getDeviceCategory(size.width);

  int getGridColumns({bool isCompact = false}) =>
      ResponsiveBreakpoints.getGridColumns(size.width, isCompact: isCompact);

  double getResponsivePadding({double basePadding = 16}) =>
      ResponsiveBreakpoints.getResponsivePadding(size.width, basePadding: basePadding);

  double getResponsiveSpacing({double baseSpacing = 16}) =>
      ResponsiveBreakpoints.getResponsiveSpacing(size.width, baseSpacing: baseSpacing);

  double get fontScaling => ResponsiveBreakpoints.getFontScaling(size.width);

  double getCardAspectRatio({double baseRatio = 1.0}) =>
      ResponsiveBreakpoints.getCardAspectRatio(size.width, baseRatio: baseRatio);
}
