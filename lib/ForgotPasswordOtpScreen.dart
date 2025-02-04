import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/ForgotChangePassword.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'Common/common_styles.dart';
import 'CustomerLoginScreen.dart';
import 'api_config.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  final int id;
  final String userName;

  const ForgotPasswordOtpScreen(
      {super.key, required this.id, required this.userName});

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _secondsRemaining = 600;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isloading = false;
  @override
  void initState() {
    // TODO: implement initState
    startTimer();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _otpController.dispose();
  // }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          // Handle timeout here
        }
      });
    });
  }

  void restartTimer() {
    _timer.cancel(); // Cancel the current timer if it's running
    _secondsRemaining = 600; // Reset seconds remaining to 10 minutes
    startTimer(); // Start a new timer
  }

  String? currentText;

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
        backgroundColor: CommonUtils.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2.2,
                decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(20.0),
                    //   bottomRight: Radius.circular(20.0),
                    // ),
                    // image: DecorationImage(
                    //   image: AssetImage('assets/befor_login_illustration.png'),
                    //   fit: BoxFit.cover,
                    //   alignment: Alignment.center,
                    // ),
                    ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.height / 4.5,
                        child: Image.asset('assets/hfz_logo.png'),
                      ),
                      const Text('Forgot Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: Color(0xFF662d91),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Please Enter 6 Digits OTP sent',
                          style: CommonUtils
                              .Sub_header_Styles), //Please enter 6 digits OTP sent to your email to continue
                      const Text('to Your Email to Continue ',
                          style: CommonUtils.Sub_header_Styles),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height /
                          2, // Adjust the height here
                  child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30.0),
                              topRight: Radius.circular(30.0),
                            ),
                          ),
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(),
                              Column(
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
                                      inactiveColor:
                                          CommonUtils.primaryTextColor,
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
                                    validator: validateotp,
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

                                  // OTPTextField(
                                  //   length: 6,
                                  //   spaceBetween: 10,
                                  //   width: MediaQuery.of(context).size.width,
                                  //   fieldWidth: 40,
                                  //   style: const TextStyle(fontSize: 20),
                                  //   textFieldAlignment:
                                  //       MainAxisAlignment.center,
                                  //   fieldStyle: FieldStyle.box,
                                  //   otpFieldStyle: OtpFieldStyle(
                                  //     borderColor: CommonUtils.primaryTextColor,
                                  //     enabledBorderColor:
                                  //         CommonUtils.primaryTextColor,
                                  //   ),
                                  //   onCompleted: (pin) {
                                  //     print("Completed: ");
                                  //   },
                                  // ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'OTP Validate For ${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')} Minutes',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Didn\'t receive OTP? ',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          )),

                                      GestureDetector(
                                        onTap: () {
                                          // Handle the click event for the "Click here!" text
                                          print('Click here! clicked');
                                          // Add your custom logic or navigation code here
                                          Resendotpmethod();
                                        },
                                        child: const Text('Resend OTP',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: "Outfit",
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF662e91))),
                                      )
                                      // Text(
                                      //   ' Resend code',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     fontFamily: "Outfit",
                                      //     fontWeight: FontWeight.w700,
                                      //     color:CommonUtils.primaryTextColor,
                                      //   )
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: CustomButton(
                                      buttonText: 'Validate OTP',
                                      color: CommonUtils.primaryTextColor,
                                      onPressed: checkInternetConnection,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Back to Login?',
                                          style: CommonUtils.Mediumtext_14),
                                      GestureDetector(
                                        onTap: () {
                                          // Handle the click event for the "Click here!" text
                                          print('Click here! clicked');
                                          // Add your custom logic or navigation code here
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const CustomerLoginScreen(),
                                            ),
                                          );
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
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    ' ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: CommonUtils.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )))
            ],
          )),
    );
  }

  String? validateotp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Enter OTP';
    }
    // if (value.length != 6) {
    //   return 'OTP should be exactly 6 characters long';
    // }
    return null;
  }

  void checkInternetConnection() {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        validateOtp();
        print('The Internet Is Connected');
      } else {
        // CommonUtils.showCustomToastMessageLong(
        //     'Please Check Your Internet Connection', context, 1, 4);
        CommonUtils.showCustomToastMessageLongbottom( 'Please Check Your Internet Connection',  context, 1, 4);

        print('The Internet Is not Connected');
      }
    });
  }

  Future<void> validateOtp() async {
    print('OTP: ${_otpController.text}');
    if (_formKey.currentState!.validate()) {
      String otpentered = _otpController.text;
      print('otpentered: $otpentered');

      Map<String, String> requestBody = {
        "id": widget.id.toString(),
        "otp": otpentered
      };
      ///CommonStyles.progressBar(context);

      ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      progressDialog.show();
      final String apiUrl = baseUrl + validateusernameotp;
      final response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> data = json.decode(response.body);

        // Extract the necessary information
        bool isSuccess = data['isSuccess'];
        String statusMessage = data['statusMessage'];

        // Print the result
        print('Is Success: $isSuccess');
        print('Status Message: $statusMessage');
        progressDialog.dismiss();
       // LoadingProgress.stop(context);
        // Handle the data accordingly
        if (isSuccess) {
          // If the user is valid, you can extract more data from 'listResult'
          progressDialog.dismiss();
          if (data['listResult'] != null) {
            List<dynamic> listResult = data['listResult'];
            Map<String, dynamic> user = listResult.first;
            print('userid: ${user['id']}');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ForgotChangePassword(
                  id: widget.id,
                ),
              ),
            );
            // LoadingProgress.stop(context);
            // CommonUtils.showCustomToastMessageLong(
            //     '${data["statusMessage"]}', context, 0, 3,
            //     toastPosition: MediaQuery.of(context).size.height / 2);

            CommonUtils.showCustomToastMessageLongbottom('${data["statusMessage"]}', context, 0, 4);
          } else {
           // LoadingProgress.stop(context);
            FocusScope.of(context).unfocus();
            // CommonUtils.showCustomToastMessageLong(
            //     '${data["statusMessage"]}', context, 1, 3,
            //     toastPosition: MediaQuery.of(context).size.height / 2);


            CommonUtils.showCustomToastMessageLongbottom('${data["statusMessage"]}', context, 1, 4);
          }
          // LoadingProgress.stop(context);
        } else {
        //  LoadingProgress.stop(context);
          progressDialog.dismiss();
          FocusScope.of(context).unfocus();
          // CommonUtils.showCustomToastMessageLong(
          //     "${data["statusMessage"]}", context, 1, 3,
          //     toastPosition: MediaQuery.of(context).size.height / 2);
          CommonUtils.showCustomToastMessageLongbottom('${data["statusMessage"]}', context, 1, 4);

          // Handle the case where the user is not valid
          List<dynamic> validationErrors = data['validationErrors'];
          if (validationErrors.isNotEmpty) {
            // Print or handle validation errors if any
          }
        }
      } else {
        progressDialog.dismiss();
        // Handle any error cases here
        print(
            'Failed to connect to the API. Status code: ${response.statusCode}');
      }
    }
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const ForgotChangePassword(),
    //   ),
    // );
  }

  Future<void> Resendotpmethod() async {
    // Print the username and password
    //  print('Username: $email');
    print('userName: ${widget.userName}');
    setState(() {
      _isloading = true; //Enable loading before getQuestions
    });
    final String apiUrl = baseUrl + validateusername;
    ProgressDialog progressDialog = ProgressDialog(context);

    // Show the progress dialog
    progressDialog.show();
    // Prepare the request body
    Map<String, String> requestBody = {
      'userName': widget.userName,
    };

    // Make the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      body: requestBody,
    );

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
      setState(() {
        _isloading = false; //Enable loading before getQuestions
      });
      // Handle the data accordingly
      if (isSuccess) {
        // If the user is valid, you can extract more data from 'listResult'

        if (data['listResult'] != null) {
          List<dynamic> listResult = data['listResult'];
          Map<String, dynamic> user = listResult.first;
          print('userid: ${user['id']}');
          _otpController.clear();
         // LoadingProgress.stop(context);

          progressDialog.dismiss();
          // CommonUtils.showCustomToastMessageLong(
          //     'OTP Has Sent To Your Email', context, 0, 3,
          //     toastPosition: MediaQuery.of(context).size.height / 2);
          CommonUtils.showCustomToastMessageLongbottom('OTP Has Sent To Your Email', context, 0, 4);
          restartTimer();
        } else {
          FocusScope.of(context).unfocus();
          //LoadingProgress.stop(context);
          progressDialog.dismiss();
          // CommonUtils.showCustomToastMessageLong('Invalid User ', context, 1, 3,
            //  toastPosition: MediaQuery.of(context).size.height / 2);
          CommonUtils.showCustomToastMessageLongbottom('Invalid User ', context, 1, 4);
        }
      } else {
        //LoadingProgress.stop(context);
        progressDialog.dismiss();
        FocusScope.of(context).unfocus();
        // CommonUtils.showCustomToastMessageLong(
        //     "${data["statusMessage"]}", context, 1, 3,
        //     toastPosition: MediaQuery.of(context).size.height / 2);
        CommonUtils.showCustomToastMessageLongbottom("${data["statusMessage"]}", context, 1, 4);
        // Handle the case where the user is not valid
        setState(() {
          _isloading = false; //Enable loading before getQuestions
        });
        List<dynamic> validationErrors = data['validationErrors'];
        if (validationErrors.isNotEmpty) {
          // Print or handle validation errors if any
        }
      }
    } else {
      setState(() {
        _isloading = false; //Enable loading before getQuestions
      });
    //  LoadingProgress.stop(context);
      progressDialog.dismiss();
      // Handle any error cases here
      print(
          'Failed to connect to the API. Status code: ${response.statusCode}');
    }
  }
}
