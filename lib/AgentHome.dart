import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/Branches_screen.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/CustomerLoginScreen.dart';
import 'package:hairfixingzone/Inventory_screen.dart';
import 'package:hairfixingzone/MyAppointments.dart';
import 'package:hairfixingzone/branchesforagent.dart';
import 'package:hairfixingzone/startingscreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'AddConsulationscreen.dart';
import 'AgentDashBoard.dart';
import 'AgentLogin.dart';
import 'ViewConsultation.dart';

class AgentHome extends StatefulWidget {
  final int userId;

  const AgentHome({super.key, required this.userId});

  @override
  State<AgentHome> createState() => _AgentHomeState();
}

class _AgentHomeState extends State<AgentHome> {
  String userFullName = '';
  @override
  void initState() {
    super.initState();
    checkLoginuserdata();
    print('_____Agent Home_____');
  }

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return Future.value(false);
        } else {
          bool confirmClose = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Exit'),
                content: const Text('Are You Sure You Want to Close The App?'),
                actions: [
                  Container(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: CommonUtils.primaryTextColor,
                        ),
                        side: const BorderSide(
                          color: CommonUtils.primaryTextColor,
                        ),
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontSize: 16,
                          color: CommonUtils.primaryTextColor,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          color: CommonUtils.primaryTextColor,
                        ),
                        side: const BorderSide(
                          color: CommonUtils.primaryTextColor,
                        ),
                        backgroundColor: CommonUtils.primaryTextColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          if (confirmClose == true) {
            SystemNavigator.pop();
          }
          return Future.value(false);
        }
      },
      child: Scaffold(
        appBar: CommonStyles.agentAppbar(
          context: context,
          title: buildTitle(_currentIndex, context),
          userName:
              userFullName.isNotEmpty ? userFullName[0].toUpperCase() : "A",
          onTap: () {
            logOutDialog(context);
          },
        ),
        body: _buildScreens(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          backgroundColor: const Color(0xffffffff),
          onTap: (index) => setState(() {
            _currentIndex = index;
          }),
          selectedItemColor: Colors.black,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/home.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/home.svg',
                width: 20,
                height: 20,
                color: CommonUtils.primaryTextColor,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/invite-alt.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/invite-alt.svg',
                width: 20,
                height: 20,
                color: Color(0xFF11528f),
              ),
              label: 'Book Appointment',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/calendarcheck.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/calendarcheck.svg',
                width: 20,
                height: 20,
                color: CommonUtils.primaryTextColor,
              ),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/overview.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/overview.svg',
                width: 20,
                height: 20,
                color: CommonUtils.primaryTextColor,
              ),
              label: 'Consultations',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/invertory.svg',
                width: 20,
                height: 20,
                color: Colors.black.withOpacity(0.6),
              ),
              activeIcon: SvgPicture.asset(
                'assets/invertory.svg',
                width: 20,
                height: 20,
                color: CommonUtils.primaryTextColor,
              ),
              label: 'Inventory',
            ),
          ],
          selectedLabelStyle: CommonStyles.txSty_16b_fb,
        ),
      ),
    );
  }

  Widget _buildScreens(int index) {
    switch (index) {
      case 0:
        return AgentDashBoard(
          agentid: widget.userId,
        );
      case 1:
        return Branchesforagent_screen(userId: widget.userId!);
      case 2:
        return Branches_screen(userId: widget.userId!);
      case 3:
        return ViewConsultation(
          agentId: widget.userId!,
        );
      case 4:
        return Branches_screen(
            userId: widget.userId, isBranchFrom: 'inventory');
      // return InventoryScreen(userId: widget.userId);

      default:
        return AgentDashBoard(
          agentid: widget.userId,
        );
    }
  }

  void logOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: CommonStyles.txSty_18b_fb,
          ),
          content: const Text('Are You Sure You Want to Logout?',
              style: CommonStyles.txSty_16b_fb),
          actions: [
            Container(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    color: CommonUtils.primaryTextColor,
                  ),
                  side: const BorderSide(
                    color: CommonUtils.primaryTextColor,
                  ),
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                child: const Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16,
                    color: CommonUtils.primaryTextColor,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10), // Add spacing between buttons
            Container(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmLogout();
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    color: CommonUtils.primaryTextColor,
                  ),
                  side: const BorderSide(
                    color: CommonUtils.primaryTextColor,
                  ),
                  backgroundColor: CommonUtils.primaryTextColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                ),
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onConfirmLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userId');
    prefs.remove('userRoleId');
    CommonUtils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => startingscreen()),
      (route) => false,
    );
  }

  void checkLoginuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userFullName = prefs.getString('userFullName') ?? '';
      print('userFullName: $userFullName');
    });
  }

  String buildTitle(int currentIndex, BuildContext context) {
    switch (currentIndex) {
      case 0:
        return '';
      case 1:
        return 'Book Appointment';
      case 2:
        return 'Check Appointments';
      case 3:
        return 'View Consultations';
      case 4:
        return 'Inventory';
      default:
        return 'default';
    }
  }
}
