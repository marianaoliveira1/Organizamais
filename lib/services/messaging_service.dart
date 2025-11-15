import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'org_default_channel',
    'Notificações',
    description: 'Canal padrão do app',
    importance: Importance.high,
  );

  static Future<void> backgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('FCM background: ${message.messageId} data=${message.data}');
    }
  }

  Future<void> init() async {
    if (_initialized) return;

    /// ---------------------- iOS SETTINGS ----------------------
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    /// ---------------------- ANDROID SETTINGS ----------------------
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    /// ---------------------- GLOBAL SETTINGS ----------------------
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _local.initialize(initSettings);

    /// ---------------------- ANDROID CHANNEL ----------------------
    final androidImpl = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(_channel);

    /// ---------------------- REQUEST PERMISSIONS (iOS + Android) ----------------------
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    /// ---------------------- BACKGROUND HANDLER ----------------------
    FirebaseMessaging.onBackgroundMessage(MessagingService.backgroundHandler);

    /// ---------------------- FOREGROUND NOTIFICATIONS ----------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint('FCM foreground: ${message.messageId} data=${message.data}');
      }
      final RemoteNotification? notif = message.notification;
      final AndroidNotification? android = notif?.android;
      if (notif != null && android != null) {
        await _local.show(
          notif.hashCode,
          notif.title,
          notif.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    _initialized = true;
  }

  Future<String?> getToken() => _messaging.getToken();
}
