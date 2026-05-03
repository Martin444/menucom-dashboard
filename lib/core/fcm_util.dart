import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handler para mensajes en segundo plano
// ...existing code...
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // Aquí puedes procesar la notificación en segundo plano
}

bool _fcmInitialized = false;
Future<void> Function(String fcmToken)? _onTokenReceivedCallback;

/// Configura Firebase Cloud Messaging de forma general
Future<void> setupFCM({
  Future<void> Function(String fcmToken)? onTokenReceived,
  void Function(Object error)? onError,
}) async {
  _onTokenReceivedCallback = onTokenReceived;
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

  // 4. Manejar mensajes (solo registrar una vez)
  if (!_fcmInitialized) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification!.title} - ${message.notification!.body}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
    
    // Escuchar refrescos de token
    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refrescado: $newToken');
      if (_onTokenReceivedCallback != null) {
        try {
          await _onTokenReceivedCallback!(newToken);
          debugPrint('FCM Token refrescado procesado correctamente.');
        } catch (e) {
          debugPrint('Error al procesar FCM Token refrescado: $e');
        }
      }
    });

    _fcmInitialized = true;
    debugPrint('FCM Listeners configurados por primera vez.');
  }
}

/// Limpia las referencias de FCM (útil en logout)
void resetFCM() {
  _onTokenReceivedCallback = null;
  debugPrint('FCM callbacks reseteados.');
}
