import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hairfixingzone/EditProfile.dart';
import 'package:hairfixingzone/MyAppointments.dart';
import 'package:hairfixingzone/Product_My.dart';
import 'package:hairfixingzone/MyProductsProvider.dart';
import 'package:hairfixingzone/Rescheduleslotscreen.dart';
import 'package:hairfixingzone/aboutus_screen.dart';
import 'package:hairfixingzone/services/local_notifications.dart';
import 'package:hairfixingzone/services/notifi_service.dart';

import 'package:hairfixingzone/splash_screen.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'AgentAppointmentsProvider.dart';

import 'MyAppointment_Model.dart';
import 'MyAppointmentsProvider.dart';
import 'ProfileMy.dart';
import 'notifications_screen.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  print("This is a message from the background");
  print(message.notification!.title);
  String? messagetitle = message.notification!.title;
  print(message.notification!.body);
  // if (message.notification != null) {
  //   print("Message from background: ${message.notification!.title}");
  //   // Do not trigger notifications if app is in foreground
  //   bool isAppInForeground = await checkIfAppIsInForeground();
  //   if (!isAppInForeground) {
  //     BuildContext? context;
  //     print("isAppInForeground$isAppInForeground");
  //     // Show a local notification if app is in the background
  //     LocalNotificationService.showNotificationOnForeground(context!, message);
  //   }
  // }
}

// Future<bool> checkIfAppIsInForeground() async {
//   // This is a platform-specific implementation.
//   // You can use a plugin like `flutter_foreground_task` to check if the app is in the foreground.
//   return false; // Placeholder - implement actual check.
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  // NotificationService notificationService = NotificationService();
  // await notificationService.init();
  // await notificationService.requestIOSPermissions();
  // LocalNotificationService.initialize();
  // WidgetsFlutterBinding.ensureInitialized();
  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();
  tz.initializeTimeZones();
  // Retrieve all scheduled notifications
  List<PendingNotificationRequest> notifications =
      await notificationService.getScheduledNotifications();

  // Log the details of all scheduled notifications
  for (var notification in notifications) {
    print("Scheduled Notification: ${notification.id}");
    print("Title: ${notification.title}");
    print("Body: ${notification.body}");
    // print("Scheduled Time: ${notification.scheduledDate}");
  }
// Check if the app was opened from a notification
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  Widget homeWidget = SplashScreen(); // Default to Splash Screen
// Default to Splash Screen

  if (initialMessage != null) {
    // Handle the notification data and set the initial route
    String? messageBody = initialMessage.notification?.body;
    String? messagetitle = initialMessage.notification?.title;
    String formattedDate = '';
    print("web notification1== $messagetitle");

    if (messageBody != null && messagetitle!.contains("New Appointment")) {
      print("web notification2== $messagetitle");
      RegExp datePattern = RegExp(r'\b(\d{1,2})(st|nd|rd|th)? (\w+)\b');
      Match? match = datePattern.firstMatch(messageBody);

      if (match != null) {
        String day = match.group(1)!;
        String month = match.group(3)!;

        String dateString = "$day $month";

        try {
          DateTime date = DateFormat("d MMMM").parse(dateString);
          date = DateTime(DateTime.now().year, date.month, date.day);
          formattedDate = DateFormat("yyyy-MM-dd").format(date);
        } catch (e) {
          print("Error parsing date: $e");
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        int? userId = prefs.getInt('userId');
        if (userId != null) {
          homeWidget = notifications_screen(
              userId: userId,
              formattedDate: formattedDate); // Your notification screen widget
        }
      }
    }
  }
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // You can also log or send this error somewhere for further analysis.
  };
//  runApp(MyApp(initialRoute: initialRoute));
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => MyProductProvider()),
    ChangeNotifierProvider(create: (context) => MyAppointmentsProvider()),
    ChangeNotifierProvider(create: (context) => AgentAppointmentsProvider()),
  ], child: MyApp(homeWidget: homeWidget)));
}

// class NotificationHandler {
//   static String? _lastMessageId;
//
//   static void handleNotification(RemoteMessage message, BuildContext context) {
//     String? messageId = message.messageId;
//
//     if (_lastMessageId != messageId) {
//       _lastMessageId = messageId;
//
//       // Process notification
//       LocalNotificationService.showNotificationOnForeground(context, message);
//     } else {
//       print("Duplicate notification detected. Ignoring...");
//     }
//   }
// }
class MyApp extends StatelessWidget {
  final Widget homeWidget;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  late String formattedDate;
  int? userId;

  MyApp({required this.homeWidget, super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize your LocalNotificationService here.

    _firebaseMessaging.requestPermission();
    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Handle the notification when the app is in the foreground
      print("onMessage: $message");
      String? messageBody = message.notification!.body;
      String? messagetitle = message.notification!.title;
      String? messagelog = message.data["message"];
      print("onMessageBody: $messageBody");
      print("onMessageOmessagetitle: $messagetitle");
      print("onMessagelog: $messagelog");
      // NotificationHandler.handleNotification(message, context);
      // LocalNotificationService HERE
      LocalNotificationService.showNotificationOnForeground(context, message);
      // LocalNotificationService.display(message);

      if (messageBody != null) {
        if (messagetitle!.contains("Appointment Approved")) {
          print("Appointment already approved. Just opening the app.");
          // No further action needed, just return.
          return;
        } else if (messagetitle!.contains("Notification")) {
          print("web notification");
          // No further action needed, just return.
          return;
        }
        // else if (messagetitle!.contains("Appointment Cancelled")) {
        //   print("Appointment Cancelled Just opening the app");
        //   // No further action needed, just return.
        //   return;
        // }
        else if (messagetitle!.contains("Appointment Cancelled")) {
          print("Appointment cancelled from agent. Just opening the app");
          // No further action needed, just return.
          return;
        } else {
          RegExp datePattern = RegExp(r'\b(\d{1,2})(st|nd|rd|th)? (\w+)\b');
          Match? match = datePattern.firstMatch(messageBody);

          if (match != null) {
            String day = match.group(1)!;
            String month = match.group(3)!;

            String dateString = "$day $month";

            try {
              DateTime date = DateFormat("d MMMM").parse(dateString);

              // Adjust the year to the current year
              date = DateTime(DateTime.now().year, date.month, date.day);

              formattedDate = DateFormat("yyyy-MM-dd").format(date);
              print("Formatted Date: $formattedDate");
            } catch (e) {
              print("Error parsing date: $e");
            }
          } else {
            print("Date not found in the message.");
          }
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      print('zzz: $isLoggedIn');
      if (isLoggedIn) {
        userId = prefs.getInt('userId')!;

        print('User ID: $userId');
        LocalNotificationService.initialize(
            context, navigatorKey, userId!, formattedDate);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Handle the notification when the app is opened from a terminated state
      print("onMessageOpenedApp: $message");

      String? messageBody = message.notification!.body;
      String? messagetitle = message.notification!.title;
      print("onMessageOpenedApp:122 $messageBody");
      print("messagetitle:122 $messagetitle");

      if (messageBody != null) {
        if (messagetitle!.contains("Appointment Approved")) {
          print("Appointment already approved. Just opening the app.");
          // No further action needed, just return.
          return;
        } else if (messagetitle!.contains("Notification")) {
          print("web notification");
          // No further action needed, just return.
          return;
        } else if (messagetitle!.contains("Appointment Cancelled")) {
          print("Appointment Cancelled Just opening the app");
          // No further action needed, just return.
          return;
        } else {
          RegExp datePattern = RegExp(r'\b(\d{1,2})(st|nd|rd|th)? (\w+)\b');
          Match? match = datePattern.firstMatch(messageBody);

          if (match != null) {
            String day = match.group(1)!;
            String month = match.group(3)!;

            String dateString = "$day $month";
            print("dateString133: $dateString");
            try {
              DateTime date = DateFormat("d MMMM").parse(dateString);

              // Adjust the year to the current year
              date = DateTime(DateTime.now().year, date.month, date.day);
              formattedDate = DateFormat("yyyy-MM-dd").format(date);
              print("Formatted Date: $formattedDate");
            } catch (e) {
              print("Error parsing date: $e");
            }
          } else {
            print("Date not found in the message.");
          }
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        int? userId = prefs.getInt('userId');

        if (userId != null) {
          print('User ID: $userId');
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => notifications_screen(
                userId: userId,
                formattedDate:
                    formattedDate), // Replace with your screen widget
          ));
        } else {
          print('User ID not found in SharedPreferences');
        }
      }
    });

    return MaterialApp(
      builder: (context, child) {
        final originalTextScaleFactor = MediaQuery.of(context).textScaleFactor;
        final boldText = MediaQuery.boldTextOf(context);

        final newMediaQueryData = MediaQuery.of(context).copyWith(
          textScaleFactor: originalTextScaleFactor.clamp(0.8, 1.0),
          boldText: boldText,
        );

        return MediaQuery(
          data: newMediaQueryData,
          child: child!,
        );
      },
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: homeWidget, // Set home property dynamically
      routes: {
        '/about': (context) => AboutUsScreen(),
        '/ReSchedulescreen': (context) {
          MyAppointment_Model? data = null;
          return data != null
              ? Rescheduleslotscreen(data: data)
              : Rescheduleslotscreen(data: data!);
        },
        '/Mybookings': (context) => MyAppointments(),
        '/Products': (context) => ProductsMy(),
        '/ProfileMy': (context) => ProfileMy(),
      },
    );
  }
}
// @pragma('vm:entry-point')
// Future<void> backgroundHandler(RemoteMessage message) async {
//   print("This is a message from the background");
//   print(message.notification!.title);
//   print(message.notification!.body);
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   FirebaseMessaging.onBackgroundMessage(backgroundHandler);
//
//   // NotificationService notificationService = NotificationService();
//   // await notificationService.init();
//   // await notificationService.requestIOSPermissions();
//   // LocalNotificationService.initialize();
//   // WidgetsFlutterBinding.ensureInitialized();
//   NotificationService notificationService = NotificationService();
//   await notificationService.initNotification();
//   tz.initializeTimeZones();
//   // Retrieve all scheduled notifications
//   List<PendingNotificationRequest> notifications =
//   await notificationService.getScheduledNotifications();
//
//   // Log the details of all scheduled notifications
//   for (var notification in notifications) {
//     print("Scheduled Notification: ${notification.id}");
//     print("Title: ${notification.title}");
//     print("Body: ${notification.body}");
//     // print("Scheduled Time: ${notification.scheduledDate}");
//   }
//
//   runApp(MultiProvider(providers: [
//     ChangeNotifierProvider(create: (context) => MyProductProvider()),
//     ChangeNotifierProvider(create: (context) => MyAppointmentsProvider()),
//     ChangeNotifierProvider(create: (context) => AgentAppointmentsProvider()),
//   ], child: MyApp()));
// }
//
// final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
//
// class MyApp extends StatelessWidget {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   late String formattedDate;
//     int? userId;
//
//   MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Initialize your LocalNotificationService here.
//
//     _firebaseMessaging.requestPermission();
//     _firebaseMessaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       // Handle the notification when the app is in the foreground
//       print("onMessage: $message");
//       String? messageBody = message.notification!.body;
//       String? messagelog = message.data["message"];
//       print("onMessageOpenedApp: $messageBody");
//       print("onMessageOpenedApp: $messagelog");
//       LocalNotificationService.showNotificationOnForeground(context, message);
//
//       RegExp datePattern = RegExp(r'\b(\d{1,2} \w+ \d{4})\b');
//       Match? match = datePattern.firstMatch(messageBody!);
//
//       if (match != null) {
//         String dateString = match.group(1)!;
//         DateTime date = DateFormat("dd MMMM yyyy").parse(dateString);
//         formattedDate = DateFormat("yyyy-MM-dd").format(date);
//         print("Formatted Date: $formattedDate");
//       } else {
//         print("Date not found in the message.");
//       }
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//       if (isLoggedIn) {
//         userId = prefs.getInt('userId')!;
//
//         print('User ID: $userId');
//         LocalNotificationService.initialize(context, navigatorKey, userId!, formattedDate);
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       // Handle the notification when the app is opened from a terminated state
//       print("onMessageOpenedApp: $message");
//
//       String? messageBody = message.notification!.body;
//       print("onMessageOpenedApp: $messageBody");
//
//       RegExp datePattern = RegExp(r'\b(\d{1,2} \w+ \d{4})\b');
//       Match? match = datePattern.firstMatch(messageBody!);
//
//       if (match != null) {
//         String dateString = match.group(1)!;
//         DateTime date = DateFormat("dd MMMM yyyy").parse(dateString);
//         formattedDate = DateFormat("yyyy-MM-dd").format(date);
//         print("Formatted Date: $formattedDate");
//       } else {
//         print("Date not found in the message.");
//       }
//
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//
//       if (isLoggedIn) {
//         int? userId = prefs.getInt('userId');
//
//         if (userId != null) {
//           print('User ID: $userId');
//           navigatorKey.currentState?.push(MaterialPageRoute(
//             builder: (context) => notifications_screen(userId: userId, formattedDate: formattedDate), // Replace with your screen widget
//           ));
//         } else {
//           print('User ID not found in SharedPreferences');
//         }
//       }
//     });
//
//
//
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       title: 'My App',
//       routes: {
//         // Home screen route
//         '/about': (context) => AboutUsScreen(), // About Us screen route
//         '/ReSchedulescreen': (context) {
//           MyAppointment_Model? data = null;
//           return data != null ? Rescheduleslotscreen(data: data) : Rescheduleslotscreen(data: data!);
//         },
//         '/BookAppointment': (context) => SelectCity_Branch_screen(),
//         '/Mybookings': (context) => GetAppointments(),
//         '/Products': (context) => ProductsMy(),
//         '/ProfileMy': (context) => ProfileMy()
//
//         // Add routes for other screens here
//       },
//       home: SplashScreen(),
//     );
//   }
// }
