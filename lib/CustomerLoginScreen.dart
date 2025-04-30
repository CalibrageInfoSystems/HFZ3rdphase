import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/customerLoginScreen_2.dart';
import 'package:hairfixingzone/services/local_notifications.dart';
import 'package:hairfixingzone/startingscreen.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'Common/custome_form_field.dart';
import 'CustomerRegisterScreen.dart';
import 'ForgotChangePassword.dart';
import 'ForgotPasswordscreen.dart';
import 'HomeScreen.dart';
import 'OtpVerificationScreen.dart';
import 'api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  State<CustomerLoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<CustomerLoginScreen> {
  bool isTextFieldFocused = false;
  bool _obscureText = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String firebaseToken = "";
  Color textColor = Color(0xFF11528f); // Default color

  String notificationMsg = "Waiting for notifications";
  @override
  void initState() {
    super.initState();
    // UAT
    // _emailController.text = "Arun";
    // _passwordController.text = "Abcd@123";

    // Test
    _emailController.text = "durgatest";
    _passwordController.text = "Abcd@1234";

    // Terminated State
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        setState(() {
          notificationMsg =
              "${event.notification!.title} ${event.notification!.body} I am coming from terminated state";
        });
      }
    });

    // Foregrand State
    FirebaseMessaging.onMessage.listen((event) {
      //  LocalNotificationService.showNotificationOnForeground(context, event);
      setState(() {
        notificationMsg =
            "${event.notification!.title} ${event.notification!.body} I am coming from foreground";
      });
    });

    // background State
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      setState(() {
        notificationMsg =
            "${event.notification!.title} ${event.notification!.body} I am coming from background";
      });
    });
    // Get Firebase Token
    FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        firebaseToken = token ?? "";
        print('firebaseToken==>70===>   $firebaseToken');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonUtils.primaryColor,
      appBar: _appBar(),
      body: SingleChildScrollView(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: const BoxDecoration(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.height / 5,
                    child: Image.asset('assets/hfz_logo.png'),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Text('Customer Login',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: Color(0xFF11528f),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text('Login Your Account',
                      style: CommonUtils.Sub_header_Styles),
                  const Text('to Access All the Services',
                      style: CommonUtils.Sub_header_Styles),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
              // physics: const AlwaysScrollableScrollPhysics(),
              child: Form(
            key: _formKey,
            child: Container(
              // height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              height: MediaQuery.of(context).size.height / 1.7,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    children: [
                      Text(
                        'User Name / Email / Mobile Number',
                        style: CommonStyles.txSty_12b_f5,
                      ),
                      Text(' *',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    controller: _emailController, // Assigning the controller
                    keyboardType: TextInputType.visiblePassword,
                    // obscureText: true,

                    maxLength: 60,
                    decoration: InputDecoration(
                      errorMaxLines: 2,
                      contentPadding: const EdgeInsets.only(
                          top: 15, bottom: 10, left: 15, right: 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: CommonUtils.primaryTextColor,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: CommonUtils.primaryTextColor,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      hintText: 'Enter User Name / Email / Mobile Number',
                      counterText: "",
                      hintStyle: CommonStyles.texthintstyle,
                    ),
                    validator: validateEmail,
                    style: CommonStyles.txSty_14b_fb,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // CustomeFormField(
                  //   label: 'Password',
                  //   validator: validatePassword,
                  //   controller: _passwordController, // Pass the password controller
                  // ),
                  const Row(
                    children: [
                      Text(
                        'Password',
                        style: CommonStyles.txSty_12b_f5,
                      ),
                      Text(' *',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextFormField(
                    obscureText: _obscureText,

                    controller: _passwordController, // Assigning the controller
                    keyboardType: TextInputType.visiblePassword,
                    // obscureText: true,
                    onTap: () {},
                    maxLength: 25,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                          top: 15, bottom: 10, left: 15, right: 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: CommonUtils.primaryTextColor,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: CommonUtils.primaryTextColor,
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      hintText: 'Enter Password',
                      counterText: "",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          // Toggle the password visibility
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      hintStyle: CommonStyles.texthintstyle,
                    ),
                    validator: validatePassword,
                    style: CommonStyles.txSty_14b_fb,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordscreen()),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: CommonUtils.Mediumtext_o_14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => const HomeScreen()),
                              // );
                            },
                            child: CustomButton(
                              buttonText: 'Login',
                              color: CommonUtils.primaryTextColor,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                CommonUtils.checkInternetConnectivity()
                                    .then((isConnected) {
                                  if (isConnected) {
                                    loginUser();
                                    print('The Internet Is Connected');
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                        'Please Check Your Internet Connection',
                                        context,
                                        1,
                                        4);
                                    print('The Internet Is not Connected');
                                  }
                                });
                              },
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  // Container(
                  //   child: GestureDetector(
                  //     onTap: (){
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) =>  CustomerLoginScreen_2()),
                  //       );
                  //     },
                  //     child:Text(
                  //       'Login with OTP',
                  //       style: TextStyle(
                  //         decoration: TextDecoration.underline,
                  //         decorationColor:textColor,
                  //         decorationThickness: 1.5,
                  //         fontFamily: "Outfit",
                  //         fontWeight: FontWeight.w500,
                  //         color: textColor,
                  //         fontSize: 16,
                  //       ),
                  //     ),
                  //   )
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerLoginScreen_2()),
                          );
                        },
                        child: Text(
                          'Login with OTP',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: textColor,
                            decorationThickness: 1.5,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('New User?', style: CommonUtils.Mediumtext_14),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () {
                          // Handle the click event for the "Click here!" text
                          print('Click here! clicked');
                          // Add your custom logic or navigation code here
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerRegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Register Here!',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0f75bc),
                            )),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ))
        ],
      )),
    );
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter Password';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter User Name / Email / Mobile Number';
    }
    // else if (!RegExp(
    //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    //     .hasMatch(value)) {
    //   return 'Please enter a valid email address';
    // }
    return null;
  }

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      print('login: Login success!');
      String? email = _emailController.text;
      String? password = _passwordController.text;

      // Print the username and password
      print('Username: $email');
      print('Password: $password');
      setState(() {
        _isLoading = true; //Enable loading before getQuestions
      });
      // CommonStyles.progressBar(context);
      ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      progressDialog.show();
      final String apiUrl = baseUrl + ValidateUser;
      print('apiUrl: $apiUrl');
      final requestBody = {
        'userName': email,
        'password': password,
        "deviceTokens": firebaseToken
      };
      print('Object: ${json.encode(requestBody)}');
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
      );
      print('Is Success: $JsonEncoder{}');
      // Check if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> data = json.decode(response.body);

        // Extract the necessary information
        bool isSuccess = data['isSuccess'];
        String statusMessage = data['statusMessage'];

        // Print the result
        print('Is Success: $isSuccess');
        print('Status Message: $statusMessage');

        // Handle the data accordingly
        if (isSuccess) {
          // If the user is valid, you can extract more data from 'listResult'

          if (data['listResult'] != null) {
            setState(() {
              _isLoading = false;
            });
            progressDialog.dismiss();

            List<dynamic> listResult = data['listResult'];
            Map<String, dynamic> user = listResult.first;
            print('User ID: ${user['id']}');
            print('Full Name: ${user['firstName']}');
            print('Role ID: ${user['roleID']}');

            // Extract other user information as needed

            if (user['roleID'] == 2) {
              await saveUserDataToSharedPreferences(user);
              AddCustomer_Notification(user['id'], user['roleID']);
              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs.setBool('isLoggedIn', true);
              // Navigator.push(
              // context,
              // MaterialPageRoute(builder: (context) =>  OtpVerificationScreen(id: user['id'],email: user['email'],password :user['password'], )),
              // );
              progressDialog.dismiss();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          boolflagpopup: true,
                        )),
              );
            } else {
              // Show toast for invalid user
              FocusScope.of(context).unfocus();
              // CommonUtils.showCustomToastMessageLong(
              //     "Invalid User", context, 1, 3,
              //     toastPosition: MediaQuery.of(context).size.height / 2);
              //CommonUtils.showCustomToastMessageLongbottom(data['statusMessage'], context, 1, 4);
              CommonUtils.showCustomToastMessageLongbottom(
                  "Invalid User", context, 1, 4);
              // showToast('Invalid user');
            }
          } else {
            FocusScope.of(context).unfocus();
            // CommonUtils.showCustomToastMessageLong(
            //     'Invalid User ', context, 1, 3,
            //     toastPosition: MediaQuery.of(context).size.height / 2);
            CommonUtils.showCustomToastMessageLongbottom(
                data['statusMessage'], context, 1, 4);
            progressDialog.dismiss();
          }
        } else {
          FocusScope.of(context).unfocus();
          progressDialog.dismiss();
          // CommonUtils.showCustomToastMessageLongbottom(data['statusMessage'], context, 1, 4);
          CommonUtils.showCustomToastMessageLongbottom(
              'Invalid User Name / Email / Mobile Number or Password',
              context,
              1,
              4);
          // CommonUtils.showCustomToastMessageLong(
          //     "${data["statusMessage"]}", context, 1, 3,
          //     toastPosition: MediaQuery.of(context).size.height / 2);
          // Handle the case where the user is not valid
          List<dynamic> validationErrors = data['validationErrors'];
          if (validationErrors.isNotEmpty) {
            // Print or handle validation errors if any
          }
        }
      } else {
        setState(() {
          _isLoading = false;
          progressDialog.dismiss();
        });
        // Handle any error cases here
        print(
            'Failed to connect to the API. Status code: ${response.statusCode}');
      }
    }
  }

  Future<void> saveUserDataToSharedPreferences(
      Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    // prefs.setBool('isLoggedIn', true);
    // Save user data using unique keys
    await prefs.setInt('userId', userData['id']);
    await prefs.setString('userFullName', userData['firstName']);
    await prefs.setString('username', userData['userName']);
    await prefs.setInt('userRoleId', userData['roleID']);
    await prefs.setString('email', userData['email']);
    await prefs.setString('contactNumber', userData['contactNumber']);
    await prefs.setString('gender', userData['gender']);
    await prefs.setString('dateofbirth', userData['dateofbirth'] ?? '');
    await prefs.setString('password', userData['password']);
    await prefs.setInt('genderTypeId', userData['genderTypeId']);
    // Save other user data as needed
  }

  static void progressBar(BuildContext context) {
    LoadingProgress.start(
      context,
      widget: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.withOpacity(0.6),
        ),
        width: MediaQuery.of(context).size.width / 4,
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 13),
        child: const AspectRatio(
          aspectRatio: 1,
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: CommonUtils.primaryTextColor,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => startingscreen()),
          );
        },
      ),
      backgroundColor: Colors.transparent, // Transparent app bar
      elevation: 0, // No shadow
    );
  }

  Future<void> AddCustomer_Notification(int userId, int roleid) async {
    final url = Uri.parse(baseUrl + AddCustomerNotification);

    final request = {
      "id": null,
      "userId": userId,
      "roleId": roleid,
      "deviceToken": firebaseToken
    };

    print('Object: ${json.encode(request)}');
    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        // LoadingProgress.stop(context);
        // Extract the necessary information
        bool isSuccess = data['isSuccess'];
        // if(isSuccess){
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) =>  HomeScreen()),
        //   );
        // }
      } else {}
    } catch (e) {
      // ProgressManager.stopProgress();
      print('Error slot: $e');
    }
  }
}
