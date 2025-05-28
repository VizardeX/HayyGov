import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Local notification plugin
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestPermission();

    // FCM Token
    final token = await _messaging.getToken();
    print("🔐 FCM Token: $token");

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initSettings);

    await _initializeToken();
    _setupInteractedMessage();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('📱 Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _initializeToken() async {
    String? token = await _messaging.getToken();
    print('✅ FCM Token: $token');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔄 FCM token refreshed: $newToken');
      // Save to Firestore if needed
    });
  }

  void _setupInteractedMessage() {
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    FirebaseMessaging.onMessage.listen((message) {
      print('📬 Foreground notification: ${message.notification?.title}');

      if (message.notification != null) {
        final notification = message.notification!;
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Default Notifications',
              channelDescription: 'This channel is used for important notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(route);
      print('🔀 Navigated to route: $route');
    }
  }
}
