import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/CustomerLoginScreen.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loading_progress/loading_progress.dart';
import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'Common/custome_form_field.dart';
import 'ForgotPasswordOtpScreen.dart';
import 'api_config.dart';

class ForgotPasswordscreen extends StatefulWidget {
  const ForgotPasswordscreen({super.key});

  @override
  State<ForgotPasswordscreen> createState() => _ForgotPasswordscreen();
}

class _ForgotPasswordscreen extends State<ForgotPasswordscreen> {
  final TextEditingController username = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isloading = false;
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
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
      ),
      body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Form(
              //   key: _formKey,
              //   child:
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
                  child: Container(
                      padding: EdgeInsets.all(12),
                      child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      const Text('Enter Your User Name / Email',
                          style: CommonUtils.Sub_header_Styles),
                      const Text(' / Mobile Number',
                          style: CommonUtils.Sub_header_Styles),
                      const Text('to Get an OTP on Your Email',
                          style: CommonUtils.Sub_header_Styles),
                    ],
                  )),
                ),
              ),
              // ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child:
              //
              // ),
              // _isloading
              //     ? LoadingAnimationWidget.fourRotatingDots(
              //         color: Color(0xFF662e91),
              //         size: 40.0,
              //       )
              //     :
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
                              vertical: 20, horizontal: 40),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //  SizedBox(),
                              // Form(
                              //   key: _formKey,
                              //   child:
                              Column(
                                children: [
                                  // CustomeFormField(
                                  //   label: 'Email / User Name / Mobile Number',
                                  //   validator: validateEmail,
                                  //   controller: username,
                                  //   maxLength: 60,
                                  // ),
                                  Row(
                                    children: [
                                      Text(
                                        'User Name / Email / Mobile Number',
                                        style:  CommonStyles.txSty_12b_f5,),
                                      Text(
                                          ' *',
                                          style:  TextStyle(
                                            fontSize: 12,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          )
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  TextFormField(
                                    controller: username, // Assigning the controller
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
                                      hintStyle:  CommonStyles.texthintstyle ,
                                    ),
                                    validator: validateEmail,
                                    style: CommonStyles.txSty_14b_fb,
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: CustomButton(
                                      buttonText: 'Send OTP',
                                      color: CommonUtils.primaryTextColor,
                                      onPressed: checkInternetConnection,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
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
                              // ),
                            ],
                          ),
                        )),
                  )),
            ],
          )),
    );
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

  void checkInternetConnection() {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        forgotUser();
        print('The Internet Is Connected');
      } else {
        // CommonUtils.showCustomToastMessageLong(
        //     'Please Check Your Internet Connection', context, 1, 4);
        CommonUtils.showCustomToastMessageLongbottom('Please Check Your Internet Connection', context, 1, 4);
        print('The Internet Is not Connected');
      }
    });
  }

  Future<void> forgotUser() async {
    if (_formKey.currentState!.validate()) {
      print('login: Login success!');
      String? userName = username.text.toString();

      // Print the username and password
      //  print('Username: $email');
      print('Password: $userName');
      setState(() {
        _isloading = true; //Enable loading before getQuestions
      });
      final String apiUrl = baseUrl + validateusername;
      //CommonStyles.progressBar(context);
      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'userName': userName,
        'isMobileApp': true.toString(),
      };
      ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      progressDialog.show();

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
        progressDialog.dismiss();
        // Print the result
        print('Is Success: $isSuccess');
        print('Status Message: $statusMessage');
        setState(() {
          _isloading = false; //Enable loading before getQuestions
        });
        //LoadingProgress.stop(context);
        // Handle the data accordingly
        if (isSuccess) {
          // If the user is valid, you can extract more data from 'listResult'
          progressDialog.dismiss();
          if (data['listResult'] != null) {
            List<dynamic> listResult = data['listResult'];
            Map<String, dynamic> user = listResult.first;
            print('userid: ${user['id']}');
            print('roleID: ${user['roleID']}');

            if (user['roleID'] == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ForgotPasswordOtpScreen(
                        id: user['id'], userName: user['userName'])),
              );
              CommonUtils.showCustomToastMessageLongbottom('OTP Has Sent To Your Email', context, 0, 4);
              // CommonUtils.showCustomToastMessageLong(
              //     'OTP Has Sent To Your Email', context, 0, 3,
              //     toastPosition: MediaQuery.of(context).size.height / 2);
              progressDialog.dismiss();
            } else {
              // Show toast for invalid user
              FocusScope.of(context).unfocus();
              progressDialog.dismiss();
              CommonUtils.showCustomToastMessageLongbottom("Invalid User", context, 1, 4);
              // CommonUtils.showCustomToastMessageLong(
              //     "Invalid User", context, 1, 3,
              //     toastPosition: MediaQuery.of(context).size.height / 2);
              // showToast('Invalid user');
            }
          } else {
            progressDialog.dismiss();
            FocusScope.of(context).unfocus();
            // CommonUtils.showCustomToastMessageLong(
            //     'Invalid User ', context, 1, 3,
            //     toastPosition: MediaQuery.of(context).size.height / 2);
            CommonUtils.showCustomToastMessageLongbottom("Invalid User", context, 1, 4);
          }
        } else {
          progressDialog.dismiss();
          FocusScope.of(context).unfocus();
          //LoadingProgress.stop(context);
          // CommonUtils.showCustomToastMessageLong(
          //     "${data["statusMessage"]}", context, 1, 3,
          //     toastPosition: MediaQuery.of(context).size.height / 2);
         // CommonUtils.showCustomToastMessageLongbottom("${data["statusMessage"]}", context, 1, 4);
          CommonUtils.showCustomToastMessageLongbottom("Invalid User Name / Email / Mobile Number", context, 1, 4);
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
        progressDialog.dismiss();
        ///LoadingProgress.stop(context);
        setState(() {
          _isloading = false; //Enable loading before getQuestions
        });
        // Handle any error cases here
        print(
            'Failed to connect to the API. Status code: ${response.statusCode}');
      }
    }
  }
}
