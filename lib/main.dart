import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase imports
import 'package:firebase_core/firebase_core.dart';
// Auth system imports
import 'package:pickmeup_dashboard/features/auth/presentation/controllers/auth_bindings.dart';
import 'package:pickmeup_dashboard/features/auth/config/firebase_config.dart';

import 'routes/pages.dart';

void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await initializeFirebase();

  // Inicializar servicios existentes
  await getToken();
  inicialiceServiceMenucomAPi();

  // Inicializar sistema de autenticación
  AuthInitializer.initialize();

  runApp(const MyApp());
}

/// Inicializa Firebase para la aplicación
Future<void> initializeFirebase() async {
  try {
    debugPrint('Iniciando configuración de Firebase...');
    debugPrint('Configuración a usar: ${FirebaseConfig.currentPlatform}');

    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );

    debugPrint('Firebase inicializado correctamente para ${Firebase.app().name}');
    debugPrint('Proyecto ID: ${Firebase.app().options.projectId}');
    debugPrint('Auth Domain: ${Firebase.app().options.authDomain}');

    // Solo configurar emuladores en desarrollo si está habilitado
    // Comentado temporalmente para debugging
    // FirebaseDevConfig.configureEmulators();
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
    debugPrint('Stack trace: ${StackTrace.current}');

    // En desarrollo, continuar sin Firebase para no bloquear la app
    // TODO: En producción, considera mostrar un error al usuario o usar valores por defecto

    debugPrint('Continuando sin Firebase - funcionalidad social deshabilitada');
  }
}

void inicialiceServiceMenucomAPi() {
  try {
    API.getInstance(URL_PICKME_API);
  } catch (e) {
    rethrow;
  }
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String?> getToken() async {
  var prefs = await _prefs;
  var token = prefs.getString('acccesstoken');
  if (token != null) {
    ACCESS_TOKEN = token;
    API.setAccessToken(ACCESS_TOKEN);
  }
  return token;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
    );
  }
}
