import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

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
      await _analytics?.logEvent(name: 'logout');
      debugPrint('[Analytics] Logout event');
    } catch (e) {
      debugPrint('[Analytics] Error logging logout: $e');
    }
  }

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

  Future<void> setUserProperty({required String name, required String value}) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('[Analytics] Error setting user property "$name": $e');
    }
  }

  Future<void> setUserId(String? id) async {
    if (!_initialized) return;
    try {
      await _analytics?.setUserId(id: id);
    } catch (e) {
      debugPrint('[Analytics] Error setting userId: $e');
    }
  }

  Future<void> logError(String error, {String? context, String? stackTrace}) async {
    if (!_initialized) return;
    try {
      final params = <String, Object>{
        'error': error,
        if (context != null) 'context': context,
        if (stackTrace != null) 'stack_trace': stackTrace,
      };
      await _analytics?.logEvent(name: 'error', parameters: params);
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
