import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handler para mensajes en segundo plano
// ...existing code...
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // Aquí puedes procesar la notificación en segundo plano
}

/// Configura Firebase Cloud Messaging de forma general
Future<void> setupFCM({
  Future<void> Function(String fcmToken)? onTokenReceived,
  void Function(Object error)? onError,
}) async {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  // 1. Solicitar permisos de notificación
  NotificationSettings settings = await firebaseMessaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

// ...existing code...
  debugPrint('User granted permission: ${settings.authorizationStatus}');

  // 2. Obtener el token de FCM
  String? fcmToken = await firebaseMessaging.getToken();
  debugPrint('FCM Token: $fcmToken');

  // 3. Callback para token recibido
  if (fcmToken != null && onTokenReceived != null) {
    try {
      await onTokenReceived(fcmToken);
      debugPrint('FCM Token procesado correctamente.');
    } catch (e) {
      debugPrint('Error al procesar el FCM Token: $e');
      if (onError != null) onError(e);
    }
  }

  // 4. Manejar mensajes en primer plano
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
          'Message also contained a notification: ${message.notification!.title} - ${message.notification!.body}');
      // Aquí puedes mostrar una notificación local si lo deseas
    }
  });

  // 5. Manejar mensajes en segundo plano/terminados
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
}
