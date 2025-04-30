import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/Common/custome_form_field.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/screens/auth/customer__login_otp.dart';
import 'package:http/http.dart' as http;

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
                          // const SizedBox(height: 30),
                          /* 
                          Upgraded digital_signature and Qr code scanner packages
                          Implemented functionality to capture digital signature and QR code scanning
                           */
                          CustomeFormField(
                            label: 'Mobile Number',
                            isMandatory: false,
                            validator: validateMobileNumber,
                            controller: mobileNumberController,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[6-9]\d{0,9}')),
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

        if (response['isSuccess'] == true) {
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
              response['statusMessage'], context, 1, 4);
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
