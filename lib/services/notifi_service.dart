import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  Future<void> initNotification() async {
    // Initialization settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('applogo');

    // Initialization settings for iOS
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification: (int id, String? title, String? body,
                String? payload) async {});

    // Combine Android and iOS initialization settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    // Initialize notifications plugin
    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        print("Notification tapped with payload: $payload");
      }
    });
  }

  // Notification details
  NotificationDetails notificationDetails({String? bigText}) {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      // Set the bigText property if provided
      styleInformation:
          bigText != null ? BigTextStyleInformation(bigText) : null,
    );

    var platformChannelSpecifics = NotificationDetails(android: androidDetails);
    return platformChannelSpecifics;
  }

  // Show a single notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails(),
      payload: payload,
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledNotificationDateTime,
  }) async {
    DateTime now = DateTime.now();
    if (scheduledNotificationDateTime.isBefore(now)) {
      scheduledNotificationDateTime = now.add(const Duration(minutes: 1));
    }

    // Use the complete body text as bigText
    String bigText = body ?? '';

    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledNotificationDateTime,
        tz.local,
      ),
      notificationDetails(bigText: bigText),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Retrieve all scheduled notifications
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return notificationsPlugin.pendingNotificationRequests();
  }
}
