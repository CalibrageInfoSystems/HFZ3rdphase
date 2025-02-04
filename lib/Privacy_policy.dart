import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import 'CommonUtils.dart';
import 'CustomerLoginScreen.dart';
class Privacypolicyscreen extends StatefulWidget {
  @override
  _PrivacypolicyscreenState createState() => _PrivacypolicyscreenState();
}

class _PrivacypolicyscreenState extends State<Privacypolicyscreen> {
  late final WebViewController _webViewController;




  // Future<WebViewController> loadContent() async {Privacypolicyscreen
  //   const apiUrl =
  //       'http://182.18.157.215/SaloonApp/Web/auth/privacy-note';
  //
  //   final jsonResponse = await http.get(Uri.parse(apiUrl));
  //   if (jsonResponse.statusCode == 200) {
  //     Map<String, dynamic> response = jsonDecode(jsonResponse.body);
  //     final result = response;
  //
  //     return WebViewController()
  //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //       ..loadRequest(Uri.parse(apiUrl))
  //       ..enableZoom(true)
  //       ..goForward()
  //       ..getScrollPosition()
  //       ..reload()
  //       ..setOnScrollPositionChange(
  //             (change) {
  //           // print('change: ${change.x} | ${change.y}');
  //           change.x;
  //           change.y;
  //         },
  //       )
  //       ..setNavigationDelegate(
  //         NavigationDelegate(
  //           onPageFinished: (String url) {
  //             WebViewController()
  //                 .runJavaScript("document.body.style.zoom = '4.5';");
  //           },
  //         ),
  //       );
  //   } else {
  //     throw Exception('Failed to get learning data');
  //   }
  // }
  Future<WebViewController> loadContent() async {
    const apiUrl = 'http://182.18.157.215/SaloonApp/Web/auth/privacy-note';

    // Create an instance of WebViewController
    final WebViewController webViewController = WebViewController();

    // Configure the WebViewController
    webViewController

      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(apiUrl))
      ..enableZoom(true)
      ..enableZoom(true)
      ..goForward()
      ..getScrollPosition()

      ..reload()
      ..setOnScrollPositionChange(
            (change) {
          // print('change: ${change.x} | ${change.y}');
          change.x;
          change.y;
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {

            // WebViewController()
            //     .runJavaScript("document.body.style.zoom = '4.5';");
          },
        ),
      );

    return webViewController;
  }
  @override
  void initState() {
    // TODO: implement initState
    //loadContent();
    _webViewController = WebViewController()

      ..setJavaScriptMode(JavaScriptMode.unrestricted)//http://182.18.157.215/SaloonApp/Web/auth/privacy-notet this is test url
      ..loadRequest(Uri.parse('http://182.18.157.215/Saloon_UAT/Web/auth/privacy-note'))//http://182.18.157.215/Saloon_UAT/Web/auth/privacy-note this uat url
      ..enableZoom(true)
      ..goForward()
      ..getScrollPosition()
      ..reload()
      ..setBackgroundColor(Colors.white)
      ..setOnScrollPositionChange((change) {
        print('Scroll position: x=${change.x}, y=${change.y}');
      })

      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {

           // _webViewController.runJavaScript("document.body.style.zoom = '4.5';");
            _webViewController.enableZoom(false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('mailto:')) {
              final Uri emailUri = Uri.parse(request.url);
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                print('Could not launch $emailUri');
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),

      );


  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: _appBar(context),
        body:Column(
          children: [

                        Container(
                          padding:  EdgeInsets.all(10),
                          child: ClipRRect(
                            child: Image.asset(
                              'assets/privacy_policy_image_3.jpg',
                            ),
                          ),
                        ),


            Expanded(
              child: WebViewWidget(controller: _webViewController),
            ),
          ],
        ),

        // Container(
        //     color: Colors.white,
        //     child:
        //     SingleChildScrollView(
        //       child: Padding(
        //         padding: const EdgeInsets.all(10.0),
        //         child: Column(
        //           children: [
        //             // banner
        //             Container(
        //               padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5, right: 5),
        //               child: ClipRRect(
        //                 child: Image.asset(
        //                   'assets/privacy_policy_img.jpg',
        //                 ),
        //               ),
        //             ),
        //             // space
        //             const SizedBox(
        //               height: 5,
        //             ),
        //             // about us content
        //             // Padding(
        //             //   padding: EdgeInsets.all(0.0),
        //             //   child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
        //             //
        //             //     SizedBox(
        //             //       height: 500, // Set a specific height
        //             //       child: WebViewWidget(controller: _webViewController),
        //             //     ),
        //             //   ]),
        //             // )
        //             Padding(
        //               padding: EdgeInsets.all(0.0),
        //               child: LayoutBuilder(
        //                 builder: (context, constraints) {
        //                   return Column(
        //                     mainAxisAlignment: MainAxisAlignment.start,
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       SizedBox(
        //                         height: constraints.maxHeight * 0.5, // Adjustable percentage
        //                         child: WebViewWidget(controller: _webViewController),
        //                       ),
        //                     ],
        //                   );
        //                 },
        //               ),
        //             )
        //
        //
        //
        //           ],
        //         ),
        //       ),
        //     ))
    );
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
  // // Text('Meta Description',
  // //     style: TextStyle(
  // //       fontSize: 16,
  // //       color: Color(0xFF662d91),
  // //     )),
  // SizedBox(height: 15),
  // Text('Introduction',
  //     style: TextStyle(
  //       fontSize: 16,
  //       fontFamily: "Outfit",
  //       color: Color(0xFF11528f),
  //     )),
  // SizedBox(height: 5),
  // Padding(
  //   padding: const EdgeInsets.all(0.0),
  //   child: RichText(
  //     textAlign: TextAlign.justify,
  //     text: TextSpan(
  //       style: CommonStyles.txSty_16black_f5,
  //       children: [
  //         TextSpan(
  //           text: 'This Privacy Notice applies to all products, applications and services offered by Hair Fixing Zone. Office located in Bengaluru, India\n\n',
  //           style: CommonStyles.txSty_16black_f5,
  //         ),
  //         TextSpan(
  //           text: 'Information We Collect\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //         TextSpan(
  //           text: 'We may collect and store the following types of information.\n\n',
  //           style: CommonStyles.txSty_16black_f5,
  //         ),
  //         TextSpan(
  //           text: 'Personal Information: When you register or book through our App, we may collect personal details such as your name, email address, phone number, payment information, and any other information you provide to us.\n\n ',
  //         ),
  //         TextSpan(
  //           text: 'Booking Information: Details related to your bookings, including dates, times, services, and preferences.\n\n',
  //         ),
  //
  //         TextSpan(
  //             text: 'How We Use Your Information\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //         TextSpan(
  //             text: 'We use the information we collect to:\n\n',
  //             // style: TextStyle(
  //             //   fontSize: 16,
  //             //   fontFamily: "Outfit",
  //             //   color: Color(0xFF11528f),
  //             // )
  //         ),
  //         TextSpan(
  //           text: 'Provide and manage your bookings and accounts.\n',
  //           style: CommonStyles.txSty_16black_f5,
  //         ),
  //         TextSpan(
  //           text: 'Improve and personalize your experience with our App.\n\n ',
  //         ),
  //         TextSpan(
  //           text: 'Communicate with you regarding updates, promotions, and other information relevant to our services.\n\n',
  //         ),
  //         TextSpan(
  //             text: 'Sharing Your Information\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //
  //         TextSpan(
  //           text: 'We take security and data privacy very seriously.\n',
  //           style: CommonStyles.txSty_16black_f5,
  //         ),
  //         TextSpan(
  //           text: 'We never share your data with anyone.\n\n ',
  //         ),
  //         TextSpan(
  //           text: 'We value your data privacy and solely use your data.\n\n',
  //         ),
  //         TextSpan(
  //             text: 'Data Security\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //         TextSpan(
  //           text: 'We implement appropriate security measures to protect your information from unauthorized access, disclosure, alteration, or destruction.\n\n ',
  //         ),
  //         TextSpan(
  //             text: 'Your Choices\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //         TextSpan(
  //           text: 'You can manage your personal information and communication preferences through your profile settings.\n\n ',
  //         ),
  //         TextSpan(
  //             text: 'Third-Party Links\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //         TextSpan(
  //           text: 'Connected Apps at your discretion, you can allow 3rd party connections (we call them Connected Apps) such as calling (when clicking on phone number hyperlink) and directions through Google Maps.\n\n ',
  //         ),
  //         TextSpan(
  //             text: 'Further Information\n\n',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontFamily: "Outfit",
  //               color: Color(0xFF11528f),
  //             )
  //         ),
  //         TextSpan(
  //           text: 'If you have any queries about how we treat your information, the contents of this Privacy Notice, your rights under local law, how to update your records or how to obtain a copy of the information that we hold about you, please contact our team on hairfixingzone@gmail.com.\n\n ',
  //         ),
  //       ],
  //     ),
  //   ),
  // ),
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
          'Privacy Policy',
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
