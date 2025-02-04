import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'CommonUtils.dart';
import 'CustomerLoginScreen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(context),
        body: Container(
          color: Colors.white,
    child:
    SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // banner
                Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 5, left: 5, right: 5),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/about_us.jpg',
                    ),
                  ),
                ),
                // space
                const SizedBox(
                  height: 5,
                ),
                // about us content
                 Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Text('Meta Description',
                    //     style: TextStyle(
                    //       fontSize: 16,
                    //       color: Color(0xFF662d91),
                    //     )),
                    Text(
                      'Discover exceptional hair replacement solutions at Hair Fixing Zone Bangalore. Offering customized treatments for hair loss, we provide innovative, non-surgical options tailored to your needs. Visit us for the best in hair restoration services.',
                      textAlign: TextAlign.justify,
                      style: CommonStyles.txSty_16black_f5,
                    ),
                    SizedBox(height: 15),
                    Text('About Us',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Outfit",
                          color: Color(0xFF11528f),
                        )),
                    SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: CommonStyles.txSty_16black_f5,
                        children: [
                          TextSpan(
                            text: 'Welcome to Hair Fixing Zone Bangalore, your ultimate destination for premier hair replacement services For Men and Women. Established with a commitment to excellence, we specialize in providing innovative and non-surgical solutions to address hair loss and baldness. Our team of experienced professionals offers a comprehensive range of treatments, including Hair weaving, Hair bonding, customized hair systems, Hair Toppers For women, clip in hair extensions, Hair wigs for women, Hair Wigs for Men and Chemotherapy wigs ensuring that each client receives a personalized approach to meet their unique needs.\n\n',
                            style: CommonStyles.txSty_16black_f5,
                          ),
                          TextSpan(
                            text: 'Located in the bustling areas of Marathahalli, Indiranagar, Kadugodi and Sarjapur Road our state-of-the-art clinics are equipped with the latest technology and adhere to the highest standards of hygiene and customer care. Whether you are looking for a quick, same-day solution or a more extensive hair restoration plan, Hair Fixing Zone Bangalore is dedicated to helping you regain your confidence with natural-looking, long-lasting results.\n\n',
                            style: CommonStyles.txSty_16black_f5,
                          ),
                          TextSpan(
                            text: 'Choose Hair Fixing Zone for the best in hair Fixing and transformation. Experience the difference with our expert services and join the countless satisfied clients who have made us their preferred choice for hair replacement in Bangalore. For more information about our services, view our gallery, and read our Google reviews, please visit our website at ',
                          ),
                          TextSpan(
                            text: 'hairfixingzone.com',
                            style: TextStyle(
                              color: Colors.blue, // Color for the clickable text
                              decoration: TextDecoration.underline, // Underline the clickable text
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                _launchURL('https://hairfixingzone.com');
                              },
                          ),
                          TextSpan(
                            text: '. \n\n',
                          ),

                          TextSpan(
                            text: 'Thank You,\n',
                          ),
                          TextSpan(
                            text: 'Hair Fixing Zone Team.',
                          ),

                        ],
                      ),
                    ),
                  ),
             
                  ]),
                )
              ],
            ),
          ),
        )));
  }

  void logOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirmLogout(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> onConfirmLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userId'); // Remove userId from SharedPreferences
    prefs.remove('userRoleId'); // Remove roleId from SharedPreferences
    CommonUtils.showCustomToastMessageLong("Logout Successful", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
      (route) => false,
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffe2f0fd),
        title: const Text(
          'About Us',
          style: TextStyle(color: Color(0xFF0f75bc), fontSize: 16.0,  fontFamily: "Outfit",),
        ),
        // actions: [
        //   IconButton(
        //     icon: SvgPicture.asset(
        //       'assets/sign-out-alt.svg', // Path to your SVG asset
        //       color: const Color(0xFF662e91),
        //       width: 24, // Adjust width as needed
        //       height: 24, // Adjust height as needed
        //     ),
        //     onPressed: () {
        //       logOutDialog(context);
        //       // Add logout functionality here
        //     },
        //   ),
        // ],
        // centerTitle: true,
      titleSpacing:0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: CommonUtils.primaryTextColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ));
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
