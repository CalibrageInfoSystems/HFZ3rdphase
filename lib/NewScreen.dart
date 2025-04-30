import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/EditProfile.dart';
import 'package:hairfixingzone/Privacy_policy.dart';
import 'package:hairfixingzone/screens/auth/customer_login.dart';
import 'package:hairfixingzone/screens/login_screen.dart';
import 'package:hairfixingzone/startingscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ChangePasswordScreen.dart';
import 'Common/common_styles.dart';
import 'CommonUtils.dart';
import 'CustomerLoginScreen.dart';
import 'FavouritesScreen.dart';
import 'MyProducts.dart';
import 'Product_My.dart';
import 'ProfileMy.dart';
import 'aboutus_screen.dart';
import 'api_config.dart';
import 'contactus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NewScreen extends StatefulWidget {
  final String userName;

  const NewScreen({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  DateTime? createdDate;
  String? password = '';
  int Id = 0;
  int? loginUserId;
  String? loginUserFullName;

  late Future<Map<String, dynamic>> futureCustomerDetails;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    futureCustomerDetails = getCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: Scaffold(
        backgroundColor: CommonStyles.whiteColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfile(createdDate: '$createdDate'),
                    ),
                  );
                },
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: CommonStyles.primaryTextColor,
                        radius: 25,
                        child: Text(
                          widget.userName.isNotEmpty
                              ? widget.userName[0].toUpperCase()
                              : 'X',
                          style: const TextStyle(
                              fontSize: 22, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                              future: getLoginUserName(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError ||
                                    snapshot.data == null) {
                                  return const Text(
                                    'User Name',
                                    style: CommonStyles.txSty_20black_fb,
                                  );
                                }
                                return Text(
                                  '${snapshot.data}',
                                  style: CommonStyles.txSty_20black_fb,
                                );
                              }),
                          const Text('Edit Profile',
                              style: CommonStyles.txSty_16black_f5),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
                width: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/about_us.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f),
                ),
                title: const Text('About Us', style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16),
                onTap: () {
                  aboutUs(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(),
              ),
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/apps.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title: const Text('Products', style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  products(context);
                  // MyProducts();
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              ListTile(
                  minTileHeight: 40.0,
                  leading: SvgPicture.asset(
                    'assets/fav_star.svg',
                    width: 25,
                    height: 25,
                    color: const Color(0xFF11528f), // Adjust color as needed
                  ),
                  title: const Text('Favourites',
                      style: CommonStyles.txSty_20black_fb),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.grey, size: 16), // Add trailing icon here
                  onTap: () {
                    Favourite(context);
                  }),
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/headset.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title:
                    const Text('Contact Us', style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  contactUs(context); // Execute your action here
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              /* ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/change-password-icon.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title: const Text('Change Password',
                    style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        id: Id!,
                        password: password!,
                      ),
                    ),
                  ); // Execute your action here
                },
              ), 
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ), */
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/privacy_icon.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title: const Text('Privacy Policy',
                    style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Privacypolicyscreen(),
                    ),
                  );
                  // _launchURL('https://www.hairfixingzone.com/privacy-policy/');// Execute your action here
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/logout_new.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title: const Text('Logout', style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  logOutDialog(context); // Execute your action here
                },
              ),
              /* const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/logout_new.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title: const Text('Test', style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CustomerLogin(),
                    ),
                  );
                },
              ), */
              const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              referBox(),
              const SizedBox(height: 50),
              Text(
                'Version 1.0.0',
                style: CommonStyles.txSty_16black_f5,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget referBox() {
    return Container(
      height: 150,
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: CommonStyles.primarylightColor,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
                padding: const EdgeInsets.all(12),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Refer & earn', style: CommonStyles.txSty_20black_fb),
                    Text(
                        'Invite a Friend to Hair Fixing Zone and you will get Complimentary Service',
                        style: CommonStyles.txSty_16black_f5),
                    SizedBox(height: 5),
                  ],
                )),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: SvgPicture.asset(
                'assets/giftbox.svg',
                width: 60,
                height: 60,
              ),
            ),
          ),
        ],
      ),
    );
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
                  onConfirmLogout(context);
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

  Future<void> onConfirmLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userId'); // Remove userId from SharedPreferences
    prefs.remove('userRoleId'); // Remove roleId from SharedPreferences

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => startingscreen()),
      (route) => false,
    );
  }

  Future<bool> onBackPressed(BuildContext context) {
    // Navigate back when the back button is pressed
    Navigator.pop(context);
    // Return false to indicate that we handled the back button press
    return Future.value(false);
  }

  void contactUs(BuildContext context) {
    // Implement your contact us logic here, like navigating to a contact screen
    print('Navigating to Contact Us screen');
    // Example navigation
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const contactus()),
    );
  }

  void aboutUs(BuildContext context) {
    print('Navigating to About Us screen');
    // Example navigation

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AboutUsScreen()),
    );
  }

  void profile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfileMy()),
    );
  }

  void Favourite(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FavouritesScreen()),
    );
  }

  Future<String> getLoginUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final userFullName = prefs.getString('userFullName') ?? '';
    return userFullName;
  }

  Future<Map<String, dynamic>> getCustomerDetails() async {
    final isConnected = await CommonUtils.checkInternetConnectivity();
    if (!isConnected) {
      CommonUtils.showCustomToastMessageLong(
          'Please Check Your Internet Connection', context, 1, 4);
      throw Exception('No internet connection');
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('userId') ?? 0;
    String apiUrl = '$baseUrl$getCustomerDatabyid$id';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['listResult'] != null) {
          List<dynamic> listResult = jsonResponse['listResult'];

          Map<String, dynamic> customerData = listResult[0];
          setState(() {
            password = customerData['password'] ?? '';
            loginUserFullName = customerData['firstname'] ?? '';
          });
          return customerData;
        } else {
          throw Exception('No data found');
        }
      } else {
        throw Exception('Failed to fetch customer details');
      }
    } catch (e) {
      rethrow;
    }
  }

  /* Future<void> fetchdetailsofcustomer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final id = prefs.getInt('userId') ?? 0;
    // String apiUrl = 'http://182.18.157.215/SaloonApp/API/GetCustomerData?id=$id';
    String apiUrl = '$baseUrl$getCustomerDatabyid$id';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        List<dynamic> listResult = jsonResponse['listResult'];

        Map<String, dynamic> customerData = listResult[0];

        setState(() {
          print('Customer Data: ${customerData['firstname']}');
          password = customerData['password'] ?? '';
          loginUserFullName = customerData['firstname'] ?? '';

          print('Role Name: $password');
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {});
      // Handle exceptions
      print('Exception occurred: $e');
    }
  }
 */
  void products(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProductsMy()),
    );
  }

  Future<void> fetchLoginUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getInt('userId') ?? 0;
    //String apiUrl = 'http://182.18.157.215/SaloonApp/API/GetCustomerData?id=$id';
    String apiUrl = '$baseUrl$getCustomerDatabyid$loginUserId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('apiurl: $apiUrl');
      print('response: ${response.body}');
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Access the 'listResult' from the response
        List<dynamic> listResult = jsonResponse['listResult'];

        // Assuming there's only one item in the listResult
        Map<String, dynamic> customerData = listResult[0];

        loginUserFullName = customerData['firstname'] ?? '';

        print('loginUserFullName: ${loginUserFullName}');
        Future.value();

        // Now you can access individual fields like 'firstname', 'lastname', etc.
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred: $e');
      rethrow;
    }
  }
}
