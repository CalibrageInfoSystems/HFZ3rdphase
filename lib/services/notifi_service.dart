import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  Future<void> initNotification() async {
    // Initialization settings for Android
    final AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('applogo');

    // Initialization settings for iOS
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    // Combine Android and iOS initialization settings
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    // Initialize notifications plugin
    await notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
          if (payload != null) {
            // Handle the tap action here
            print("Notification tapped with payload: $payload");
            // Example: Navigate to a specific screen based on the payload
            // navigatorKey.currentState?.push(MaterialPageRoute(
            //   builder: (context) => notifications_screen(
            //     userId: user_Id,
            //     formattedDate: formatted_Date,
            //   ),
            // ));
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
      styleInformation: bigText != null ? BigTextStyleInformation(bigText) : null,
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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Retrieve all scheduled notifications
  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return notificationsPlugin.pendingNotificationRequests();
  }
}

// class NotificationService {
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // Counter for generating unique IDs
//   int _notificationIdCounter = 0;
//
//   // Initialize notification settings
//   Future<void> initNotification() async {
//     // Initialization settings for Android
//
//     final AndroidInitializationSettings initializationSettingsAndroid =
//     const AndroidInitializationSettings('applogo');
//     // var initializationSettings = InitializationSettings(
//     //     android: initializationSettingsAndroid);
//     //
//     // Initialization settings for iOS
//     var initializationSettingsIOS = IOSInitializationSettings (
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//         onDidReceiveLocalNotification:
//             (int id, String? title, String? body, String? payload) async {});
//
//   //  Combine Android and iOS initialization settings
//     var initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//
//    //Initialize notifications plugin
//    //  await notificationsPlugin.initialize(initializationSettings,
//    //      onDidReceiveNotificationResponse:
//    //          (NotificationResponse notificationResponse) async {});
//
//
//     await notificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (String? payload) {
//           if (payload != null) {
//             // Handle the tap action here.
//             print("Notification tapped with payload: $payload");
//
//             // Example: Navigate to a specific screen based on the payload.
//             // navigatorKey.currentState?.push(MaterialPageRoute(
//             //   builder: (context) => notifications_screen(
//             //     userId: user_Id,
//             //     formattedDate: formatted_Date,
//             //   ),
//             // ));
//           }
//         });
//   }
//
//   // Notification details
//   // notificationDetails() {
//   //   return const NotificationDetails(
//   //       android: AndroidNotificationDetails('channelId', 'channelName',
//   //           importance: Importance.max),
//   //       // iOS: DarwinNotificationDetails()
//   //   );
//   // }
//   notificationDetails({String? bigText}) {
//     var androidDetails = AndroidNotificationDetails(
//       'channelId',
//       'channelName',
//       importance: Importance.max,
//       // Set the bigText property if provided
//       styleInformation: bigText != null ? BigTextStyleInformation(bigText) : null,
//     );
//
//     var platformChannelSpecifics = NotificationDetails(android: androidDetails);
//     return platformChannelSpecifics;
//   }
//
//   // Show a single notification
//   Future showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//     String? payload,
//   }) async {
//     return notificationsPlugin.show(
//         id, title, body, await notificationDetails());
//   }
//
//   // Schedule a notification
// // Schedule a notification
//
//
//   // Schedule a notification
//   // Future<void> scheduleNotification({
//   //   required int id, // Pass the ID as a parameter
//   //   String? title,
//   //   String? body,
//   //   String? payload,
//   //   required DateTime scheduledNotificationDateTime,
//   // }) async {
//   //   DateTime now = DateTime.now();
//   //   if (scheduledNotificationDateTime.isBefore(now)) {
//   //     // Adjust the scheduledNotificationDateTime to be in the future, e.g., 1 minute from now
//   //     scheduledNotificationDateTime = now.add(const Duration(minutes: 1));
//   //   }
//   //
//   //
//   //   await notificationsPlugin.zonedSchedule(
//   //     id,
//   //     title,
//   //     body, // Use the complete body text
//   //     tz.TZDateTime.from(
//   //       scheduledNotificationDateTime,
//   //       tz.local,
//   //     ),
//   //     await notificationDetails(),
//   //     androidAllowWhileIdle: true,
//   //     uiLocalNotificationDateInterpretation:
//   //     UILocalNotificationDateInterpretation.absoluteTime,
//   //   );
//   // }
//
//   Future<void> scheduleNotification({
//     required int id,
//     String? title,
//     String? body,
//     String? payload,
//     required DateTime scheduledNotificationDateTime,
//   }) async {
//     DateTime now = DateTime.now();
//     if (scheduledNotificationDateTime.isBefore(now)) {
//       scheduledNotificationDateTime = now.add(const Duration(minutes: 1));
//     }
//
//     // Use the complete body text as bigText
//     String bigText = body ?? '';
//
//     await notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(
//         scheduledNotificationDateTime,
//         tz.local,
//       ),
//       await notificationDetails(
//         bigText: bigText, // Pass the complete body text as bigText
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
//
//   // Retrieve all scheduled notifications
//   Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
//     return notificationsPlugin.pendingNotificationRequests();
//   }
// }
