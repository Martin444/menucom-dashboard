import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:pickmeup_dashboard/core/analytics_events.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  void init() {
    try {
      _analytics = FirebaseAnalytics.instance;
      _analytics?.setAnalyticsCollectionEnabled(true);
      _initialized = true;
      debugPrint('[Analytics] Firebase Analytics initialized');
    } catch (e) {
      debugPrint('[Analytics] Error initializing: $e');
    }
  }

  FirebaseAnalytics? get instance => _analytics;

  // ── Eventos genéricos ──

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) return;
    try {
      await _analytics?.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('[Analytics] Error logging event "$name": $e');
    }
  }

  // ── Auth (GA4 standard) ──

  Future<void> logLogin({String method = 'email'}) async {
    if (!_initialized) return;
    try {
      await _analytics?.logLogin(loginMethod: method);
      debugPrint('[Analytics] Login event: $method');
    } catch (e) {
      debugPrint('[Analytics] Error logging login: $e');
    }
  }

  Future<void> logSignUp({String method = 'email'}) async {
    if (!_initialized) return;
    try {
      await _analytics?.logSignUp(signUpMethod: method);
      debugPrint('[Analytics] SignUp event: $method');
    } catch (e) {
      debugPrint('[Analytics] Error logging signUp: $e');
    }
  }

  Future<void> logLogout() async {
    if (!_initialized) return;
    try {
      await _analytics?.logEvent(name: AnalyticsEvents.logout);
      debugPrint('[Analytics] Logout event');
    } catch (e) {
      debugPrint('[Analytics] Error logging logout: $e');
    }
  }

  // ── Session tracking ──

  Future<void> logAppOpen() async {
    if (!_initialized) return;
    try {
      await _analytics?.logAppOpen();
      debugPrint('[Analytics] App open event');
    } catch (e) {
      debugPrint('[Analytics] Error logging app_open: $e');
    }
  }

  Future<void> logAppBackground() async {
    await logEvent(name: AnalyticsEvents.appBackground);
  }

  Future<void> logAppResumed() async {
    await logEvent(name: AnalyticsEvents.appResumed);
  }

  // ── Screens ──

  Future<void> logScreen({required String screenName, String? screenClass}) async {
    if (!_initialized) return;
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      debugPrint('[Analytics] Error logging screen "$screenName": $e');
    }
  }

  // ── User identity y properties ──

  Future<void> setUserId(String? id) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserId(id: id);
    } catch (e) {
      debugPrint('[Analytics] Error setting userId: $e');
    }
  }

  Future<void> setUserProperty({required String name, required String value}) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('[Analytics] Error setting user property "$name": $e');
    }
  }

  /// Establece múltiples user properties de una sola vez.
  Future<void> setUserProfile({
    String? role,
    String? businessType,
    String? subscriptionPlan,
    int? catalogCount,
    bool? isEmailVerified,
  }) async {
    if (!_initialized) return;
    try {
      if (role != null) {
        await setUserProperty(name: AnalyticsParams.userRole, value: role);
      }
      if (businessType != null) {
        await setUserProperty(name: AnalyticsParams.businessType, value: businessType);
      }
      if (subscriptionPlan != null) {
        await setUserProperty(name: AnalyticsParams.subscriptionPlan, value: subscriptionPlan);
      }
      if (catalogCount != null) {
        await setUserProperty(
          name: AnalyticsParams.catalogCount,
          value: catalogCount.toString(),
        );
      }
      if (isEmailVerified != null) {
        await setUserProperty(
          name: AnalyticsParams.isEmailVerified,
          value: isEmailVerified.toString(),
        );
      }
    } catch (e) {
      debugPrint('[Analytics] Error setting user profile: $e');
    }
  }

  // ── Errores ──

  Future<void> logError(String error, {String? context, String? stackTrace}) async {
    if (!_initialized) return;
    try {
      final params = <String, Object>{
        AnalyticsParams.error: error,
        if (context != null) AnalyticsParams.context: context,
        if (stackTrace != null) AnalyticsParams.stackTrace: stackTrace,
      };
      await _analytics?.logEvent(name: AnalyticsEvents.appError, parameters: params);
    } catch (e) {
      debugPrint('[Analytics] Error logging error: $e');
    }
  }

  Future<void> logErrorWithException(
    dynamic exception, {
    String? context,
    StackTrace? stackTrace,
  }) async {
    if (!_initialized) return;
    final message = _extractMessage(exception);
    await logError(message, context: context, stackTrace: stackTrace?.toString());
  }

  String _extractMessage(dynamic error) {
    if (error is Exception && error.toString().startsWith('Exception: ')) {
      return error.toString().substring(11);
    }
    return error.toString();
  }
}
