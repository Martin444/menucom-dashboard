import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_dart_api/core/api.dart';
import 'package:menu_dart_api/menu_com_api.dart';
import 'package:pickmeup_dashboard/core/config.dart';
import 'package:pickmeup_dashboard/core/fcm_util.dart';
import 'package:pickmeup_dashboard/routes/routes.dart';
import 'package:pu_material/pu_material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  // // Configurar FCM
  // await setupFCM();

  runApp(const MyApp());
}

/// Inicializa Firebase para la aplicación
Future<void> initializeFirebase() async {
  try {
    debugPrint('Iniciando configuración de Firebase...');

    await Firebase.initializeApp(
      options: FirebaseConfig.currentPlatform,
    );

    debugPrint('Firebase inicializado correctamente para ${Firebase.app().name}');
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

/// Configura Firebase Cloud Messaging
// Future<void> setupFCM() async {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   // 1. Solicitar permisos de notificación
//   NotificationSettings settings = await _firebaseMessaging.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );

//   debugPrint('User granted permission: ${settings.authorizationStatus}');

//   // 2. Obtener el token de FCM
//   String? fcmToken = await _firebaseMessaging.getToken();
//   debugPrint('FCM Token: $fcmToken');

//   // 3. Enviar el token al backend
//   if (fcmToken != null) {
//     try {
//       // Asumiendo que UpdateFCMTokenUseCase se puede instanciar o resolver con GetX
//       final UpdateFcmTokenUseCase updateFCMTokenUseCase = Get.find<UpdateFcmTokenUseCase>();
//       await updateFCMTokenUseCase.execute(fcmToken: fcmToken);
//       debugPrint('FCM Token enviado al backend correctamente.');
//     } catch (e) {
//       debugPrint('Error al enviar el FCM Token al backend: $e');
//     }
//   }

//   // 4. Manejar mensajes en primer plano
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     debugPrint('Got a message whilst in the foreground!');
//     debugPrint('Message data: ${message.data}');

//     if (message.notification != null) {
//       debugPrint(
//           'Message also contained a notification: ${message.notification!.title} - ${message.notification!.body}');
//       // Aquí puedes mostrar una notificación local si lo deseas
//     }
//   });

//   // 5. Manejar mensajes en segundo plano/terminados
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// }

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(); // Asegúrate de inicializar Firebase en el handler de segundo plano
//   debugPrint('Handling a background message: ${message.messageId}');
//   // Aquí puedes procesar la notificación en segundo plano
// }

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
    debugPrint('Access token cargado desde SharedPreferences: $ACCESS_TOKEN');
    setupFCM();
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
