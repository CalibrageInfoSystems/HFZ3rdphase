import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/Common/custome_form_field.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

/* 
class CustomerLogin extends StatefulWidget {
  const CustomerLogin({super.key});

  @override
  State<CustomerLogin> createState() => _CustomerLoginState();
}

class _CustomerLoginState extends State<CustomerLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController mobileNumberController = TextEditingController();

  bool _mobileNumberError = false;
  String? _mobileNumberErrorMsg;
  bool isMobileNumberValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonUtils.primaryColor,
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
                          // const SizedBox(height: 30),
                          CustomeFormField(
                            label: 'Mobile Number',
                            isMandatory: false,
                            validator: validateMobileNumber,
                            controller: mobileNumberController,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            keyboardType: TextInputType.phone,
                            errorText: _mobileNumberError
                                ? _mobileNumberErrorMsg
                                : null,
                            onChanged: (value) {
                              setState(() {
                                if (value.startsWith(' ')) {
                                  mobileNumberController.value =
                                      TextEditingValue(
                                    text: value.trimLeft(),
                                    selection: TextSelection.collapsed(
                                        offset: value.trimLeft().length),
                                  );
                                }
                                _mobileNumberError = false;
                              });
                            },
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: CustomButton(
                              buttonText: 'Send OTP',
                              color: CommonUtils.primaryTextColor,
                              onPressed: checkInternetConnection,
                            ),
                          ),
                          const SizedBox(height: 20),
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
                  'Customer Login',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Color(0xFF662d91),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Login Your Account',
                    style: CommonUtils.Sub_header_Styles),
                const Text('to Access Our Services',
                    style: CommonUtils.Sub_header_Styles),
              ],
            )),
      ),
    );
  }

  void checkInternetConnection() {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        if (_formKey.currentState!.validate() && isMobileNumberValidate) {
          customerLogin(context);
        }
      } else {
        CommonUtils.showCustomToastMessageLongbottom(
            'Please Check Your Internet Connection', context, 1, 4);
      }
    });
  }

  Future<void> customerLogin(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    try {
      final apiUrl = baseUrl + validateCustomer;

      String? deviceTokens = await FirebaseMessaging.instance.getToken();

      progressDialog.show();

      final requestBody = jsonEncode({
        'userName': mobileNumberController.text.trim(),
        'deviceTokens': [deviceTokens]
      });
      print('customerLogin2: $apiUrl | $requestBody');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      progressDialog.dismiss();
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);

        if (response['listResult'] != null) {
          // existing user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerLoginOtp(
                isExisting: true,
                contactNumber: mobileNumberController.text.trim(),
              ),
            ),
          );
        } else {
          // new user
          /* CommonUtils.showCustomToastMessageLong(
              'You are not registered with us. Please register first.',
              context,
              1,
              4); */
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerLoginOtp(
                isExisting: false,
                contactNumber: mobileNumberController.text.trim(),
              ),
            ),
          );
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

  String? validateMobileNumber(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Please Enter Mobile Number';
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.contains(RegExp(r'[a-zA-Z]'))) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number Should Contain Only Digits';
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.length != 10) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number Must Have 10 Digits';
      });
      isMobileNumberValidate = false;
      return null;
    }
    isMobileNumberValidate = true;
    return null;
  }
}
 */
class CustomerLoginOtp extends StatefulWidget {
  final bool isExisting;
  final String? contactNumber;
  final String? deviceTokens;
  const CustomerLoginOtp(
      {super.key,
      required this.isExisting,
      this.contactNumber,
      this.deviceTokens});

  @override
  State<CustomerLoginOtp> createState() => _CustomerLoginOtpState();
}

class _CustomerLoginOtpState extends State<CustomerLoginOtp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  String? currentText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              activeColor:
                                  const Color.fromARGB(255, 63, 3, 109),
                              selectedColor:
                                  const Color.fromARGB(255, 63, 3, 109),
                              selectedFillColor: Colors.white,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              inactiveColor: CommonUtils.primaryTextColor,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            // backgroundColor: Colors
                            //     .blue.shade50, // Set background color
                            enableActiveFill: true,
                            controller: _otpController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            // validator: validateotp,
                            onCompleted: (v) {
                              print("Completed");
                            },
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                currentText = value;
                              });
                            },
                            beforeTextPaste: (text) {
                              print("Allowing to paste $text");
                              return true;
                            },
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: CustomButton(
                              buttonText: 'Verify OTP',
                              color: CommonUtils.primaryTextColor,
                              onPressed: () {
                                checkInternetConnection();
                                /* if (widget.isExisting) {
                                    
                                  } else {
                                   
                                  } */
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  resendOtp(context);
                                },
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: "Outfit",
                                    color: Colors.black,
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
    try {
      final apiUrl =
          '$baseUrl$validateusernameotp/${_otpController.text.trim()}';

      progressDialog.show();

      final requestBody = jsonEncode({
        "contactNumber": widget.contactNumber,
        "otp": _otpController.text.trim(),
        "isExisting": widget.isExisting
      });
      print('customerLogin2: $apiUrl | $requestBody');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      progressDialog.dismiss();
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);

        if (widget.isExisting) {
          // existing user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Test1(
                title: 'Existing User',
              ),
            ),
          );
        } else {
          // new user
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Test1(
                title: 'New User',
              ),
            ),
          );
        }
        CommonUtils.showCustomToastMessageLong(
            response['statusMessage'], context, 1, 4);
      } else {
        CommonUtils.showCustomToastMessageLong(
            jsonResponse.body, context, 1, 4);
      }
    } catch (e) {
      progressDialog.dismiss();
      rethrow;
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
      print('customerLogin2: $apiUrl | $requestBody');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);

        CommonUtils.showCustomToastMessageLong(
            response['statusMessage'], context, 1, 4);
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
              const Text('Login Your Account',
                  style: CommonUtils.Sub_header_Styles),
              const Text('to Access Our Services',
                  style: CommonUtils.Sub_header_Styles),
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

class Test1 extends StatelessWidget {
  final String title;
  const Test1({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(title),
      ),
    );
  }
}
