import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// Auth system imports
import 'package:pickmeup_dashboard/features/auth/config/firebase_config.dart';
import 'package:pickmeup_dashboard/core/analytics_service.dart';

import 'features/auth/presentation/controllers/auth_bindings.dart';
import 'routes/pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();

  await getToken();
  initializeServiceMenucomAPI();

  AuthInitializer.initialize();

  runApp(const MyApp());
}

Future<void> initializeFirebase() async {
  try {
    debugPrint('Iniciando configuración de Firebase...');

    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );

    debugPrint('Firebase inicializado correctamente para ${Firebase.app().name}');
    debugPrint('Auth Domain: ${Firebase.app().options.authDomain}');

    AnalyticsService().init();
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
    debugPrint('Stack trace: ${StackTrace.current}');
    debugPrint('Continuando sin Firebase - funcionalidad social deshabilitada');
  }
}

void initializeServiceMenucomAPI() {
  try {
    API.getInstance(URL_PICKME_API);
  } catch (e) {
    rethrow;
  }
}

Future<String?> getToken() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  if (token != null && token.isNotEmpty) {
    API.setAccessToken(token);
    debugPrint('Access token cargado desde secure storage');
  }
  return token;
}

/// Observador de ciclo de vida para session tracking de analytics.
class _AnalyticsLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AnalyticsService().logAppResumed();
        break;
      case AppLifecycleState.paused:
        AnalyticsService().logAppBackground();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _lifecycleObserver = _AnalyticsLifecycleObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    // Registrar app_open en el primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logAppOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MenuCom Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: PUColors.primaryColor,
        ),
        useMaterial3: true,
      ),
      initialRoute: PURoutes.HOME,
      getPages: PUPages.listPages,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
      ],
    );
  }
}
