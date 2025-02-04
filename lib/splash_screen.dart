import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/startingscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AgentHome.dart';
import 'Branches_screen.dart';
import 'HomeScreen.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    // Navigate to the next screen after 2 seconds
    Future.delayed(Duration(seconds: 1), () {
      navigateToUserSelection();
      checkLoginStatus();
    });
  }

  void navigateToUserSelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => startingscreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/hairfixing_logo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final isGranted = prefs.getBool('notificationPermissionStatus') ?? false;
    PermissionStatus status = await Permission.notification.request();
    if (!isGranted) {
      if (status.isGranted) {
        print('permissionisaccepted');
        await storeNotificationPermissionStatus(true);
        print('permissionisstored');
      }
    } else if (status.isDenied) {
      navigateToUserSelection();
      // The user denied permission
      // You may want to inform the user about why you need this permission
    } else if (status.isPermanentlyDenied) {
      // The user denied permission permanently
      // You should guide the user to app settings to enable the permission manually
      openAppSettings();
    }
  }

  Future<void> storeNotificationPermissionStatus(bool isGranted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationPermissionStatus', isGranted);
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('isLoggedIn: $isLoggedIn');
    if (isLoggedIn) {
      int? userId = prefs.getInt('userId'); // Retrieve the user ID
      int? roleId = prefs.getInt('userRoleId'); // Retrieve the role ID

      // if (userId != null && roleId != null) {
      if (userId != null ) {
        // Use the user ID and role ID as needed
        print('User ID: $userId, Role ID: $roleId');
        if (roleId == 2) {
          // Navigate to home screen for users with role ID 1
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(boolflagpopup: true,)),
          );
        } else {
          // Navigate to another screen for users with different role ID
          // For example, you might have a different screen for users with role ID 2
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AgentHome(userId: userId)));

        }
      } else {
        // Handle the case where the user ID or role ID is not available
        print('User ID or Role ID not found in SharedPreferences');
      }
    } else {
      // If not logged in, navigate to the login screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => startingscreen()),
      );
    }
  }

}
