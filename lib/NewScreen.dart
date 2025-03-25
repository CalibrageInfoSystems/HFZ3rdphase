import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/EditProfile.dart';
import 'package:hairfixingzone/Privacy_policy.dart';
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
  late Future<void> _fetchUserDataFuture;
  @override
  void initState() {
    super.initState();

    print('username===47 ${widget.userName}');
    // getUserDataFromSharedPreferences();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    CommonUtils.checkInternetConnectivity().then((isConnected) async {
      if (isConnected) {
        print('The Internet Is Connected');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          Id = prefs.getInt('userId') ?? 0;
          fetchdetailsofcustomer(Id);
          // _fetchUserDataFuture = fetchLoginUserData();
        });

        // fetchMyAppointments(userId);
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //  _fetchUserDataFuture = fetchLoginUserData();
    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: Scaffold(
        backgroundColor: CommonStyles.whiteColor,
        // appBar: AppBar(
        //   elevation: 0,
        //   backgroundColor: const Color(0xffffffff),
        //   leading: IconButton(
        //     icon: const Icon(
        //       Icons.arrow_back_ios,
        //       color: CommonUtils.primaryTextColor, // Adjust the color as needed
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     Text(
              //       'Profile',
              //       style: CommonStyles.txSty_20b_fb.copyWith(fontSize: 24),
              //     ),
              //   ],
              // ),
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
                    // color: Colors.grey,
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
                      // Container(
                      //   width: 40,
                      //   height: 40,
                      //   decoration: const BoxDecoration(
                      //     color: CommonStyles.primaryTextColor,
                      //     shape: BoxShape.circle,
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       widget.userName[0].toUpperCase(),
                      //       style: const TextStyle(
                      //           fontSize: 22, color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loginUserFullName ?? '',
                            style: CommonStyles.txSty_20black_fb,
                          ),
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
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0), // Adjust padding as needed
                child: Divider(),
              ),
              ListTile(
                minTileHeight: 40.0,
                leading: SvgPicture.asset(
                  'assets/about_us.svg',
                  width: 25,
                  height: 25,
                  color: const Color(0xFF11528f), // Adjust color as needed
                ),
                title: const Text('About Us', style: CommonStyles.txSty_18b_fb),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.grey, size: 16), // Add trailing icon here
                onTap: () {
                  AboutUs(context);
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
                  contact_us(context); // Execute your action here
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
              ),
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

  void contact_us(BuildContext context) {
    // Implement your contact us logic here, like navigating to a contact screen
    print('Navigating to Contact Us screen');
    // Example navigation
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const contactus()),
    );
  }

  void AboutUs(BuildContext context) {
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

  Future<void> fetchdetailsofcustomer(int id) async {
    // String apiUrl = 'http://182.18.157.215/SaloonApp/API/GetCustomerData?id=$id';
    String apiUrl = '$baseUrl$getCustomerDatabyid$id';
    setState(() {
      //   isloading = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Access the 'listResult' from the response
        List<dynamic> listResult = jsonResponse['listResult'];

        // Assuming there's only one item in the listResult
        Map<String, dynamic> customerData = listResult[0];

        setState(() {
          ;
          password = customerData['password'] ?? '';
          loginUserFullName = customerData['firstname'] ?? '';

          print('Role Name: $password');
        });

        // await saveUserDataToSharedPreferences(customerData);
        // Now you can access individual fields like 'firstname', 'lastname', etc.
      } else {
        // Handle error cases

        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {});
      // Handle exceptions
      print('Exception occurred: $e');
    }
  }

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
