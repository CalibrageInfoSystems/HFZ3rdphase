import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/EditProfile.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'ChangePasswordScreen.dart';
import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'CommonUtils.dart';
import 'package:http/http.dart' as http;

import 'User.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  Profile_screenState createState() => Profile_screenState();
}

class Profile_screenState extends State<Profile> {
  String fullusername = '';
  String? phonenumber;
  String? email;
  String? contactNumber;
  String gender = '';
  int Id = 0;
  String username = '';
  String mobileNumber = '';
  String? dob;
  String? password = '';
  String? Mobilenumber;
  String formattedDate = '';
  DateTime? createdDate;
  List<User> userlist = [];
  bool isloading = false;
  @override
  void initState() {
    super.initState();
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
        });

        // fetchMyAppointments(userId);
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  Future<void> fetchdetailsofcustomer(int id) async {
    //String apiUrl = 'http://182.18.157.215/SaloonApp/API/GetCustomerData?id=$id';
    String apiUrl = baseUrl + getCustomerDatabyid + '$id';
    print('apiurl:$apiUrl');
    setState(() {
      isloading = true;
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
          isloading = false;
          username = customerData['userName'] ?? '';
          fullusername = customerData['firstname'] ?? '';
          String lastName = customerData['lastname'] ?? '';
          contactNumber = customerData['contactNumber'] ?? '';
          email = customerData['email'] ?? '';
          gender = customerData['gender'] ?? '';
          String roleName = customerData['rolename'] ?? '';
          // Mobilenumber = customerData['MobileNumber']??'';
          password = customerData['password'] ?? '';
          String dob = customerData['dateofbirth'] ?? '';
          //  formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dob));
          // if (dob != null) {
          //   formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dob));
          // } else {
          //   formattedDate = '';
          // }

          if (dob.isNotEmpty) {
            formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dob));
          } else {
            formattedDate = '';
          }

          if (!formattedDate.isEmpty) {
            formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dob));
          } else {
            formattedDate = '';
          }
          // if (dob != null) {
          //   formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dob));
          // } else {
          //   formattedDate = '';
          // }
          if (mobileNumber != null) {
            mobileNumber = customerData['mobileNumber'] ?? '';
          } else {
            mobileNumber = '';
          }

          // fullusername = firstName;
          // contactNumber = contactnumber;
          // email = Email;

          // Use the data as needed
          //  print('First Name: $firstName');
          print('Last Name: $lastName');
          print('Contact Number: $contactNumber');
          print('Email: $email');
          print('Role Name: $roleName');
        });

        await saveUserDataToSharedPreferences(customerData);
        // Now you can access individual fields like 'firstname', 'lastname', etc.
      } else {
        // Handle error cases
        setState(() {
          isloading = true;
        });
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isloading = true;
      });
      // Handle exceptions
      print('Exception occurred: $e');
    }
  }

  Future<void> saveUserDataToSharedPreferences(Map<String, dynamic> customerData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('profileId', customerData['id'] ?? '');
    await prefs.setString('profileUserId', customerData['userid'] ?? '');
    await prefs.setString('profilefullname', customerData['firstname'] ?? '');
    await prefs.setString('profiledateofbirth', customerData['dateofbirth'] ?? '');
    await prefs.setString('profilegender', customerData['gender'] ?? '');
    await prefs.setInt('profilegenderId', customerData['genderId'] ?? '');
    await prefs.setString('profileemail', customerData['email'] ?? '');
    await prefs.setString('profilecontactNumber', customerData['contactNumber'] ?? '');
    await prefs.setString('profilealternatenumber', customerData['mobileNumber'] ?? '');
    // await prefs.setInt('profilecreatedId', customerData['createdByUserId'] ?? '');
    await prefs.setString('profilecreateddate', customerData['createdDate'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonStyles.primaryTextColor,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            height: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isloading
                        ? Center(
                            child: CircularProgressIndicator.adaptive(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$fullusername',
                                style: CommonStyles.txSty_18w_fb,
                              ),
                              Text(
                                '$email',
                                style: CommonStyles.txSty_16w_fb,
                              ),
                            ],
                          ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditProfile(createdDate: "$createdDate"),
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/pen-circle.svg',
                        width: 40.0,
                        height: 40.0,
                        color: CommonStyles.whiteColor,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              //height:   MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: CommonStyles.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              width: double.infinity,

              child: isloading
                  ? Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            // userLayOut('assets/id-card-clip-alt.svg', CommonStyles.primaryTextColor, username,'UserName'),
                            // userLayOut('assets/venus-mars.svg', CommonStyles.statusGreenText, gender,'Gender'),
                            // userLayOut('assets/calendar_icon.svg', CommonStyles.statusRedText, formattedDate,'Date of Birth'),
                            // userLayOut('assets/mobile-notch.svg', CommonStyles.statusYellowText, '+91 ${contactNumber}','Contact Number'),
                            // userLayOut('assets/mobile-notch.svg', CommonStyles.statusBlueText, '+91${Mobilenumber}','Alternate Number'),
                            Container(
                                height: 50,
                                child: UserLayout(
                                  icon: 'assets/id-card-clip-alt.svg',
                                  bgColor: CommonStyles.primaryTextColor,
                                  data: '$username',
                                  tooltipMessage: 'User Name',
                                )),
                            SizedBox(height: 15),

                            Container(
                                height: 50,
                                child: UserLayout(
                                  icon: 'assets/venus-mars.svg',
                                  bgColor: CommonStyles.statusGreenText,
                                  data: '$gender',
                                  tooltipMessage: 'Gender',
                                )),
                            SizedBox(height: 15),
                            Container(
                                height: 50,
                                child: UserLayout(
                                  icon: 'assets/calendar_icon.svg',
                                  bgColor: CommonStyles.statusRedText,
                                  data: '$formattedDate',
                                  tooltipMessage: 'Date of Birth',
                                )),
                            SizedBox(height: 15),
                            Container(
                                height: 50,
                                child: UserLayout(
                                  icon: 'assets/mobile-notch.svg',
                                  bgColor: CommonStyles.statusYellowText,
                                  data: '+91 ${contactNumber}',
                                  tooltipMessage: 'Mobile Number',
                                )),
                            SizedBox(height: 15),
                            Container(
                              height: 50,
                              child: Visibility(
                                visible: mobileNumber != null && mobileNumber.isNotEmpty,
                                child: UserLayout(
                                  icon: 'assets/mobile-notch.svg',
                                  bgColor: CommonStyles.statusBlueText,
                                  data: '+91 ${mobileNumber}',
                                  tooltipMessage: 'Alternate Mobile Number',
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          // height:  MediaQuery.of(context).size.height,
                          //  width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                    buttonText: 'Change Password',
                                    textColor: CommonStyles.whiteColor,
                                    borderColor: CommonStyles.primaryTextColor,
                                    color: CommonStyles.primaryTextColor,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ChangePasswordScreen(
                                            id: Id,
                                            password: password!,
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

// Widget userLayOut(String icon, Color bgColor, String data, String tooltipMessage) {
//   // if (data.isEmpty) {
//   //   return SizedBox.shrink(); // Returns an empty widget if data is empty
//   // }
//
//   return Tooltip(
//     message: tooltipMessage,
//    // padding: EdgeInsets.all(20),
//    // margin: EdgeInsets.all(20),
//     showDuration: Duration(seconds: 5),
//     decoration: BoxDecoration(
//       color: Colors.blue.withOpacity(0.9),
//       borderRadius: const BorderRadius.all(Radius.circular(4)),
//     ),
//     textStyle: TextStyle(color: Colors.black),
//     preferBelow: true,
//     verticalOffset: 20,
//     child: GestureDetector(
//       onTap: () {
//         // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         //   content: Text(tooltipMessage),
//         //   duration: Duration(seconds: 2),
//         // ));
//       },
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: bgColor,
//           child: Container(
//             padding: EdgeInsets.all(10),
//             child: SvgPicture.asset(
//               icon,
//               width: 30.0,
//               height: 30.0,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         title: Text(data),
//       ),
//     ),
//   );
// }

// Future<void> fetchdetailsofcustomer(int id) async {
//   String apiUrl = 'http://182.18.157.215/SaloonApp/API/GetCustomerData?id=$id';
//   print('apiUrl: $apiUrl');
//
//   final response = await http.get(Uri.parse(apiUrl));
//
//   // Check if the request was successful
//   if (response.statusCode == 200) {
//     // Parse the JSON response
//     Map<String, dynamic> data = json.decode(response.body);
//
//     // Extract the necessary information
//     bool isSuccess = data['isSuccess'];
//     String statusMessage = data['statusMessage'];
//
//     // Print the result
//     print('Is Success: $isSuccess');
//     print('Status Message: $statusMessage');
//
//     // Handle the data accordingly
//     if (isSuccess) {
//       // If the user is valid, you can extract more data from 'listResult'
//       Map<String, dynamic> user = data['listResult'];
//
//       if (data['listResult'] != null && data['listResult'] is List && data['listResult'].isNotEmpty) {
//         List<dynamic> userList = data['listResult'];
//         Map<String, dynamic> user = data['listResult'];
//
//         // Now 'user' should be a map containing user data
//         String userDataJsonString = jsonEncode(user);
//         final users = User.fromJson(jsonDecode(userDataJsonString));
//
//         // Update the state with user data
//         setState(() {
//           fullusername = users.userName;
//           gender = users.gender;
//           formattedDate = DateFormat('dd-MM-yyyy').format(users.dateOfBirth);
//           contactNumber = users.contactNumber;
//           createdDate = users.createdDate;
//         });
//       } else {
//         // Handle the case where the user is not valid or listResult is empty
//         print('No user data found');
//       }
//     } else {
//       // Handle any error cases here
//       print('Failed to connect to the API. Status code: ${response.statusCode}');
//     }
//   }
// }
}

class UserLayout extends StatefulWidget {
  final String icon;
  final Color bgColor;
  final String data;
  final String tooltipMessage;

  const UserLayout({
    Key? key,
    required this.icon,
    required this.bgColor,
    required this.data,
    required this.tooltipMessage,
  }) : super(key: key);

  @override
  _UserLayoutState createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  bool _isTooltipVisible = false;
  final GlobalKey _tooltipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isTooltipVisible = !_isTooltipVisible;
          });
          if (_isTooltipVisible) {
            Future.delayed(Duration(seconds: 5), () {
              setState(() {
                _isTooltipVisible = false;
              });
            });
          }
        },
        child: Stack(
          children: [
            ListTile(
              leading: FloatingActionButton(
                mini: true,
                backgroundColor: widget.bgColor,
                onPressed: () {},
                tooltip: '${widget.tooltipMessage}',
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    widget.icon,
                    width: 30.0,
                    height: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
              title: Text(widget.data),
            ),
            // if (_isTooltipVisible)
            //   LayoutBuilder(
            //     builder: (context, constraints) {
            //       return Positioned(
            //         key: _tooltipKey,
            //         top: 80, // Adjust position to show below the widget
            //         left: 10, // Adjust position as needed
            //         width: constraints.maxWidth, // Adjust width based on parent width
            //         child: Container(
            //           padding: EdgeInsets.all(8),
            //           decoration: BoxDecoration(
            //             color: Colors.grey.withOpacity(0.9),
            //             borderRadius: BorderRadius.circular(4),
            //           ),
            //           child: Text(
            //             widget.tooltipMessage,
            //             textAlign: TextAlign.center,
            //             style: TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
          ],
        ),
      ),
    );
  }
}
