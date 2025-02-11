import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';


import '../notifications_screen.dart';


class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static void initialize(
      BuildContext context, GlobalKey<NavigatorState> navigatorKey, int user_Id, String formatted_Date) {
    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings("@drawable/applogo"),
    );
    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) {
          if (payload != null) {
            // Handle the tap action here.
            print("Notification tapped with payload: $payload");

            // Example: Navigate to a specific screen based on the payload.
            navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => notifications_screen(
                userId: user_Id,
                formattedDate: formatted_Date,
              ),
            ));
          }
        });
  }

  static Future<void> showNotificationOnForeground(
      BuildContext context, RemoteMessage message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      "com.calibrage.hairfixingservice",
      "HAIRFIXINGZONE",
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      DateTime.now().microsecond,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data["message"],
    );
  }
}



// class LocalNotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static void initialize() {
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: AndroidInitializationSettings("@drawable/hair_fixing_2"),
//     );
//     _notificationsPlugin.initialize(initializationSettings,
//         onSelectNotification: (String? payload) {
//           print(payload);
//         });
//   }
//
//   static Future<void> showNotificationOnForeground(RemoteMessage message) async {
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       "com.example.hairfixingservice",
//       "HAIRFIXINGZONE",
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     final NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await _notificationsPlugin.show(
//       DateTime.now().microsecond,
//       message.notification!.title,
//       message.notification!.body,
//       platformChannelSpecifics,
//       payload: message.data["message"],
//     );
//   }
// }
