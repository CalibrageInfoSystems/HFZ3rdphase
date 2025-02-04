import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/Common/custome_form_field.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:http/http.dart' as http;

import 'CustomerLoginScreen.dart';

class ForgotChangePassword extends StatefulWidget {
  final int id;

  const ForgotChangePassword({super.key, required this.id});

  @override
  State<ForgotChangePassword> createState() => _ForgotChangePasswordState();
}

class _ForgotChangePasswordState extends State<ForgotChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordValidate = false;
  bool isConfirmPasswordValidate = false;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _password_obscureText = true;
  bool confirmpassword_obscuretext = true;
  final String _passwordStrengthMessage = '';
  final Color _passwordStrengthColor = Colors.transparent;
  bool _passwordError = false;
  String? _passwordErrorMsg;
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2.2,
              decoration: const BoxDecoration(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.height / 4.5,
                      child: Image.asset('assets/hfz_logo.png'),
                    ),
                    const SizedBox(
                      height: 5.0,
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
                    const Text('Reset Your Password for Recovery ',
                        style: CommonUtils
                            .Sub_header_Styles), // Reset your password for recovery and login to your account
                    const Text('And Login to Your Account ',
                        style: CommonUtils.Sub_header_Styles),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).size.height / 2,
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
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            // CustomeFormField(
                            //   label: 'New Password',
                            //   validator: validatePassword,
                            //   controller: _passwordController,
                            // ),
                            // const SizedBox(
                            //   height: 10,
                            // ),
                            // CustomeFormField(
                            //   label: 'Confirm Password',
                            //   validator: validateConfirmPassword,
                            //   controller: _confirmPasswordController,
                            //   maxLength: 30,
                            //   maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            // ),
                            const Row(
                              children: [
                                Text(
                                  'New Password',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              obscureText: _password_obscureText,
                              maxLength: 25,
                              controller:
                                  _passwordController, // Assigning the controller
                              keyboardType: TextInputType.visiblePassword,
                              // obscureText: true,
                              onChanged: (value) {
                                //   _passwordError = false;
                                setState(() {
                                  if (value.startsWith(' ')) {
                                    _passwordController.value =
                                        TextEditingValue(
                                      text: value.trimLeft(),
                                      selection: TextSelection.collapsed(
                                          offset: value.trimLeft().length),
                                    );
                                  }
                                  _passwordError = false;
                                });
                              },
                              decoration: InputDecoration(
                                errorMaxLines: 5,
                                contentPadding: const EdgeInsets.only(
                                    top: 15, bottom: 10, left: 15, right: 15),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: CommonUtils.primaryTextColor,
                                  ),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                errorText:
                                    _passwordError ? _passwordErrorMsg : null,
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
                                    _password_obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    // Toggle the password visibility
                                    setState(() {
                                      _password_obscureText =
                                          !_password_obscureText;
                                    });
                                  },
                                ),
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400),
                              ),
                              validator: validatePassword,
                            ),
                            if (isPasswordValidate)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 5, left: 12),
                                    child: Text(
                                      _passwordStrengthMessage,
                                      style: TextStyle(
                                          color: _passwordStrengthColor,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              children: [
                                Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            TextFormField(
                              obscureText: confirmpassword_obscuretext,
                              maxLength: 25,
                              controller:
                                  _confirmPasswordController, // Assigning the controller
                              keyboardType: TextInputType.visiblePassword,
                              // obscureText: true,
                              onTap: () {},
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
                                hintText: 'Enter Confirm Password',
                                counterText: "",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    confirmpassword_obscuretext
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    // Toggle the password visibility
                                    setState(() {
                                      confirmpassword_obscuretext =
                                          !confirmpassword_obscuretext;
                                    });
                                  },
                                ),
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400),
                              ),
                              validator: validateConfirmPassword,
                            ),

                            const SizedBox(
                              height: 5,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    buttonText: 'Change Password',
                                    color: CommonUtils.primaryTextColor,
                                    onPressed: checkInternetConnection,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
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
                            // const Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     Text(
                            //       'Back to login?',
                            //       style: TextStyle(
                            //         fontSize: 15,
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //     Text(
                            //       ' Click Here',
                            //       style: TextStyle(
                            //         fontSize: 15,
                            //         color: CommonUtils.primaryTextColor,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
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

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      setState(() {
        isPasswordValidate = false;
        _passwordError = true;
        _passwordErrorMsg = 'Please Enter Password';
      });
      return null;
    } else if (value.length < 8) {
      setState(() {
        isPasswordValidate = false;
        _passwordError = true;
        _passwordErrorMsg = 'Password Must be 8 Characters or Above';
      });
      return null;
    }
    // else if (value.length > 30) {
    //   setState(() {
    //     isPasswordValidate = false;
    //     _passwordError = true;
    //     _passwordErrorMsg = 'Password must be below 25 characters';
    //   });
    //   isPasswordValidate = true;
    //   return null;
    // }

    final hasAlphabets = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumbers = RegExp(r'\d').hasMatch(value);
    final hasSpecialCharacters =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    final hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(value);

    // if (!hasAlphabets ||
    //     !hasNumbers ||
    //     !hasSpecialCharacters ||
    //     !hasCapitalLetter) {
    //   setState(() {
    //     isPasswordValidate = false;
    //     _passwordError = true;
    //     _passwordErrorMsg =
    //         'Password Must Include One Uppercase, One Lowercase, One Digit,One Special Character,No Spaces, And be 08-25 Characters Long';
    //   });
    //   return null;
    // }
    setState(() {
      isPasswordValidate = true;
    });
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      isConfirmPasswordValidate = false;
      return 'Please Enter Confirm Password';
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      isConfirmPasswordValidate = false;
      return 'Confirm Password Must Be Same As Password';
    }
    isConfirmPasswordValidate = true;
    return null;
  }

  void checkInternetConnection() {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        loginUser();
        print('The Internet Is Connected');
      } else {
        CommonUtils.showCustomToastMessageLong(
            'Please Check Your Internet Connection', context, 1, 4);
        print('The Internet Is not Connected');
      }
    });
  }

  void loginUser() {
    if (_formKey.currentState!.validate()) {
      if (isPasswordValidate && isConfirmPasswordValidate) {
        print(
            '${_passwordController.text} and ${_confirmPasswordController.text}');

        changePassword(
            _passwordController.text, _confirmPasswordController.text);
      }
    }
  }

  Future<void> changePassword(
      String newPassword, String confirmPassword) async {
    try {
      final apiUrl = baseUrl + resetpassword;

      final Map<String, dynamic> requestObject = {
        "id": widget.id, //userid
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
      };
print('==object ${jsonEncode(requestObject)}');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestObject),
      );
     // {"id":140,"newPassword":"Likky@123","confirmPassword":"Likky@123"}
      if (jsonResponse.statusCode == 200) {
        final Map<String, dynamic> response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          print('Password Reset Successfully');
          openDialog();
        } else {
          print('Failed');
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  void openDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 150,
                child: Image.asset('assets/password_success.png'),
              ),
              const SizedBox(
                height: 50,
              ),
              const Center(
                // Center the text
                child: Text(
                  'Your Password Has Been Successfully Changed',
                  style: CommonUtils.txSty_18b_fb,
                  textAlign:
                      TextAlign.center, // Optionally, align the text center
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CustomButton(
                buttonText: 'Done',
                color: CommonUtils.primaryTextColor,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CustomerLoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
