// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/CustomerRegisterScreen.dart';
import 'package:hairfixingzone/HomeScreen.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerLoginOtp extends StatefulWidget {
  final bool isExisting;
  final String? contactNumber;
  final String? deviceTokens;
  final int? userId;
  final int? roleId;
  const CustomerLoginOtp(
      {super.key,
      required this.isExisting,
      this.contactNumber,
      this.deviceTokens,
      this.userId,
      this.roleId});

  @override
  State<CustomerLoginOtp> createState() => _CustomerLoginOtpState();
}

class _CustomerLoginOtpState extends State<CustomerLoginOtp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  String? currentText;
  bool _isOtpValid = true;
  late Timer _timer;
  int _secondsRemaining = 600;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void restartTimer() {
    _timer.cancel(); // Cancel the current timer if it's running
    _secondsRemaining = 600; // Reset seconds remaining to 10 minutes
    startTimer(); // Start a new timer
  }
/* 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: CommonUtils.primaryTextColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            header(context),
            Expanded(
              child: Form(
                key: _formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          PinCodeTextField(
                            appContext: context,
                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 50,
                              fieldWidth: 45,
                              activeColor: _isOtpValid
                                  ? const Color.fromARGB(255, 63, 3, 109)
                                  : Colors.red, // Red border if invalid
                              selectedColor: _isOtpValid
                                  ? const Color.fromARGB(255, 63, 3, 109)
                                  : Colors.red,
                              selectedFillColor: Colors.white,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              inactiveColor: _isOtpValid
                                  ? CommonUtils.primaryTextColor
                                  : Colors.red,
                              errorBorderColor: Colors.red,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            controller: _otpController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            onCompleted: (v) {
                              print("Completed");
                            },
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                currentText = value;
                                _isOtpValid = true; // Reset validation state
                              });
                            },
                            beforeTextPaste: (text) {
                              print("Allowing to paste $text");
                              return true;
                            },
                          ),
                          if (!_isOtpValid) // Show error message if invalid
                            const Text(
                              'Please Enter Valid OTP',
                              style: TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: CustomButton(
                              buttonText: 'Verify OTP',
                              color: CommonUtils.primaryTextColor,
                              onPressed: () {
                                if (_otpController.text.length != 6) {
                                  setState(() {
                                    _isOtpValid = false;
                                  });
                                } else {
                                  setState(() {
                                    _isOtpValid = true;
                                  });
                                  checkInternetConnection();
                                }
                              },
                            ),
                          ),

                          //MARK: OTP Timer
                          const SizedBox(height: 10),
                          Text(
                            'OTP Validate For ${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} Minutes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          //MARK: Resend OTP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /* const Text('Didn\'t receive OTP? ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          )), */
                              TextButton(
                                onPressed: () {
                                  resendOtp(context);
                                },
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Outfit",
                                    color: Color(0xFF0f75bc),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Back to Login?',
                                  style: CommonUtils.Mediumtext_14),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(' Click Here!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0f75bc),
                                    )),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 */

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/hfz_bg.svg',
              fit: BoxFit.cover,
              // width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height,
            ),
          ),
          Container(
            height: size.height * 0.4,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, left: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hair Fixing Zone..!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),

          // Content
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Login With OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/hfz_logo.png',
                            // 'assets/hairfixing_logo.png',
                            height: 100,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Enter OTP to Verify',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'A verification code will be sent to the mobile number ${widget.contactNumber} for your account verification process.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'OTP Validate For ${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} Minutes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 30),
                          PinCodeTextField(
                            appContext: context,
                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(10),
                              fieldHeight: 50,
                              fieldWidth: 45,
                              activeColor: _isOtpValid
                                  ? const Color.fromARGB(255, 63, 3, 109)
                                  : Colors.red, // Red border if invalid
                              selectedColor: _isOtpValid
                                  ? const Color.fromARGB(255, 63, 3, 109)
                                  : Colors.red,
                              selectedFillColor: Colors.white,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              inactiveColor: _isOtpValid
                                  ? CommonUtils.primaryTextColor
                                  : Colors.red,
                              errorBorderColor: Colors.red,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            controller: _otpController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            onCompleted: (v) {
                              print("Completed");
                            },
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                currentText = value;
                                _isOtpValid = true; // Reset validation state
                              });
                            },
                            beforeTextPaste: (text) {
                              print("Allowing to paste $text");
                              return true;
                            },
                          ),
                          if (!_isOtpValid) // Show error message if invalid
                            const Text(
                              'Please Enter Valid OTP',
                              style: TextStyle(color: Colors.red),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Haven\'t received OTP?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Outfit",
                                  color: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  resendOtp(context);
                                },
                                child: const Text(
                                  'Resend OTP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Outfit",
                                    color: Color(0xFF8E2DE2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_otpController.text.length != 6) {
                                  setState(() {
                                    _isOtpValid = false;
                                  });
                                } else {
                                  setState(() {
                                    _isOtpValid = true;
                                  });
                                  checkInternetConnection();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8E2DE2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Verify OTP',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      CommonUtils.showCustomToastMessageLongbottom(
          'Please Enter OTP', context, 1, 4);
      return false;
    }
    if (value.length != 6) {
      CommonUtils.showCustomToastMessageLongbottom(
          'Invalid OTP', context, 1, 4);
      return false;
    }
    return true;
  }

  void checkInternetConnection() {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        // if (_formKey.currentState!.validate()) {
        if (validateOtp(_otpController.text.trim())) {
          customerLoginOtp(context);
        }
      } else {
        CommonUtils.showCustomToastMessageLongbottom(
            'Please Check Your Internet Connection', context, 1, 4);
      }
    });
  }

  Future<void> customerLoginOtp(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final apiUrl = '$baseUrl$validateCustomerOTP';

      progressDialog.show();

      final requestBody = jsonEncode({
        "contactNumber": widget.contactNumber,
        "otp": _otpController.text.trim(),
        "isExisting": widget.isExisting
      });
      print('resendOtp: $apiUrl | $requestBody');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      progressDialog.dismiss();
      if (jsonResponse.statusCode == 200) {
        String? deviceTokens = await FirebaseMessaging.instance.getToken();
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess'] == true) {
          CommonUtils.showCustomToastMessageLong(
              response['statusMessage'] ?? "OTP Verified Successfully.",
              context,
              0,
              4);
          print('www: ${widget.isExisting}');
          if (widget.isExisting) {
            prefs.setBool('isLoggedIn', true);
            prefs.setBool('isLoggedIn', true);

            addCustomerNotification(widget.userId, widget.roleId, deviceTokens);
            // existing user
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(boolflagpopup: true),
              ),
              (route) => false,
            );
          } else {
            // new user
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CustomerRegisterScreen(
                  contactNumber: widget.contactNumber,
                ),
              ),
            );
            /* Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerRegisterScreen(
                  contactNumber: widget.contactNumber,
                ),
              ),
            ); */
          }
        } else {
          CommonUtils.showCustomToastMessageLong('Invalid OTP', context, 1, 4);
        }
      } else {
        CommonUtils.showCustomToastMessageLong(
            jsonResponse.body, context, 1, 4);
      }
    } catch (e) {
      progressDialog.dismiss();
      rethrow;
    }
  }

  Future<void> addCustomerNotification(
      int? userId, int? roleid, String? deviceTokens) async {
    final url = Uri.parse(baseUrl + AddCustomerNotification);

    final request = {
      "id": null,
      "userId": userId,
      "roleId": roleid,
      "deviceToken": deviceTokens
    };

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
        bool isSuccess = data['isSuccess'];
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // ProgressManager.stopProgress();
      print('Error slot: $e');
    }
  }

  Future<void> resendOtp(BuildContext context) async {
    try {
      final apiUrl = baseUrl + validateCustomer;

      String? deviceTokens = await FirebaseMessaging.instance.getToken();

      final requestBody = jsonEncode({
        'userName': widget.contactNumber,
        'deviceTokens': [deviceTokens]
      });
      print('resendOtp: $apiUrl | $requestBody');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (jsonResponse.statusCode == 200) {
        restartTimer();
        final response = jsonDecode(jsonResponse.body);

        CommonUtils.showCustomToastMessageLong(
            'OTP Resent Successfully', context, 0, 4);
      } else {
        CommonUtils.showCustomToastMessageLong(
            jsonResponse.body, context, 1, 4);
      }
    } catch (e) {
      rethrow;
    }
  }

  SizedBox header(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.height * 0.2,
                // width: MediaQuery.of(context).size.height / 4.7,
                child: Image.asset('assets/hfz_logo.png'),
              ),
              const Text(
                'Customer Login Otp',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Color(0xFF662d91),
                ),
              ),
              const SizedBox(height: 20),
              const Text('We Just Sent Your Otp to ',
                  style: CommonUtils.Sub_header_Styles),
              Text(widget.contactNumber ?? '',
                  style: CommonUtils.Sub_header_Styles),
              /* const Text('Login Your Account',
                  style: CommonUtils.Sub_header_Styles),
              const Text('to Access Our Services',
                  style: CommonUtils.Sub_header_Styles), */
            ],
          ),
        ),
      ),
    );
  }

  String? validateotp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter OTP';
    }
    if (value.length != 6) {
      return 'OTP Must Have 6 Digits';
    }
    return null;
  }
}
