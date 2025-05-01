import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/CustomerLoginScreen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/slotbookingscreen.dart';
import 'package:loading_progress/loading_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Common/custom_button.dart';
import 'Common/custome_form_field.dart';
import 'ForgotPasswordscreen.dart';
import 'HomeScreen.dart';
import 'package:http/http.dart' as http;

class CustomerRegisterScreen extends StatefulWidget {
  final String? contactNumber;
  const CustomerRegisterScreen({super.key, this.contactNumber});

  @override
  State<CustomerRegisterScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<CustomerRegisterScreen> {
  bool isTextFieldFocused = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController alernateMobileNumberController =
      TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  List<RadioButtonOption> options = [];
  final ScrollController _scrollController = ScrollController();
  FocusNode FullnameFocus = FocusNode();
  FocusNode DateofBirthdFocus = FocusNode();
  FocusNode GenderFocus = FocusNode();
  FocusNode MobilenumberFocus = FocusNode();
  FocusNode AlernateMobilenumFocus = FocusNode();
  FocusNode EmailFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  FocusNode PasswordFocus = FocusNode();
  FocusNode ConfrimPasswordFocus = FocusNode();
  DateTime selectedDate = DateTime.now();
  bool showPassword = true;
  bool showConfirmPassword = true;
  List<dynamic> dropdownItems = [];
  String? selectedName;
  String? invalidCredentials;
  String? _userNameErrorMsg;
  bool _userNameError = false;
  int? selectedValue;
  int selectedTypeCdId = -1;
  double keyboardHeight = 0.0;
  bool isGenderSelected = false;
  bool isPasswordValidate = false;
  String _passwordStrengthMessage = '';
  Color _passwordStrengthColor = Colors.transparent;

  bool _passwordError = false;
  String? _passwordErrorMsg;
  bool _confirmPasswordError = false;
  String? _confirmPasswordErrorMsg;

  bool _fullNameError = false;
  String? _fullNameErrorMsg;
  bool _dobError = false;
  String? _dobErrorMsg;
  bool _emailError = false;
  String? _emailErrorMsg;
  bool _mobileNumberError = false;
  String? _mobileNumberErrorMsg;
  bool _altNumberError = false;
  String? _altNumberErrorMsg;

  bool isFullNameValidate = false;
  bool isDobValidate = false;
  bool isGenderValidate = false;
  bool isMobileNumberValidate = false;
  bool isAltMobileNumberValidate = false;
  bool isEmailValidate = false;
  bool isUserNameValidate = false;
  bool isPswdValidate = false;
  bool isConfirmPswdValidate = false;

  // test() {
  //   //MARK: Here
  //   if (isFullNameValidate &&
  //       isDobValidate &&
  //       isGenderValidate &&
  //       isMobileNumberValidate &&
  //       isAltMobileNumberValidate &&
  //       isEmailValidate &&
  //       isUserNameValidate &&
  //       isPswdValidate &&
  //       isConfirmPswdValidate) {}
  // }

  @override
  void initState() {
    super.initState();
    fetchRadioButtonOptions();
    // DateofBirth.text = _formatDate(selectedDate);
  }

  String _formatDate(DateTime date) {
    // Format the date in "dd MMM yyyy" format
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime oldestDate = DateTime(
        currentDate.year - 100); // Example: Allow selection from 100 years ago
    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: oldestDate,
      // Allow selection from oldestDate (e.g., 100 years ago)
      lastDate: currentDate,
      // Restrict to current date
      initialDatePickerMode: DatePickerMode.day,
    );
    if (pickedDay != null) {
      // Check if pickedDay is not in the future
      setState(() {
        selectedDate = pickedDay;
        dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
      });
    }
  }

  void _scrollToAndFocus(FocusNode focusNode, int index) {
    _scrollController.animateTo(
      index * 100.0, // Adjust as per the position of the field
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonUtils.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
/*       appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: CommonUtils.primaryTextColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CustomerLoginScreen()),
            );
          },
        ),
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
      ), */
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 5.7,
            decoration: const BoxDecoration(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // height: MediaQuery.of(context).size.height / 5.7,
                    width: MediaQuery.of(context).size.height / 4.2,
                    child: Image.asset('assets/hfz_logo.png'),
                  ),
                  const Text('Customer Registration',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: "Outfit",
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: Color(0xFF11528f),
                      )),
                ],
              ),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      //MARK: Full Name
                      CustomeFormField(
                        label: 'Full Name',
                        maxLength: 50,
                        validator: validatefullname,
                        focusNode: FullnameFocus,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(
                              r'[a-zA-Z\s]')), // Including '\s' for space
                        ],
                        controller: fullNameController,
                        keyboardType: TextInputType.name,
                        errorText: _fullNameError ? _fullNameErrorMsg : null,
                        errorStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: CommonStyles.errorColor,
                        ),
                        onChanged: (value) {
                          //MARK: Space restrict
                          setState(() {
                            if (value.startsWith(' ')) {
                              fullNameController.value = TextEditingValue(
                                text: value.trimLeft(),
                                selection: TextSelection.collapsed(
                                    offset: value.trimLeft().length),
                              );
                            }
                            _fullNameError = false;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      const Row(
                        children: [
                          Text(
                            'Gender ',
                            style: CommonUtils.txSty_12b_fb,
                          ),
                          Text(
                            ' *',
                            style: TextStyle(
                                color: Color.fromARGB(255, 175, 15, 4)),
                          ),
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: 5.0, right: 0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isGenderSelected
                                  ? const Color.fromARGB(255, 175, 15, 4)
                                  : CommonUtils.primaryTextColor,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<int>(
                                  value: selectedTypeCdId,
                                  iconSize: 30,
                                  icon: null,
                                  style: CommonUtils.txSty_12b_fb,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedTypeCdId = value!;
                                      if (selectedTypeCdId != -1) {
                                        selectedValue =
                                            dropdownItems[selectedTypeCdId]
                                                ['typeCdId'];
                                        selectedName =
                                            dropdownItems[selectedTypeCdId]
                                                ['desc'];

                                        print("selectedValue:$selectedValue");
                                        print("selectedName:$selectedName");
                                        isGenderSelected = false;
                                      } else {
                                        print("==========");
                                        print(selectedValue);
                                        print(selectedName);
                                      }
                                      // isDropdownValid = selectedTypeCdId != -1;
                                      isGenderSelected = false;
                                    });
                                  },
                                  items: [
                                    const DropdownMenuItem<int>(
                                        value: -1,
                                        child: Text(
                                          'Select Gender',
                                          style: CommonStyles.texthintstyle,
                                        )),
                                    ...dropdownItems
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      return DropdownMenuItem<int>(
                                        value: index,
                                        child: Text(item['desc']),
                                      );
                                    }).toList(),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      //MARK: Gender condition
                      if (isGenderSelected)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              child: Text(
                                'Please Select Gender',
                                // style: CommonStyles.texthintstyle,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: CommonStyles.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(
                        height: 10,
                      ),
                      //MARK: Email
                      ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 5),
                          const Row(
                            children: [
                              Text(
                                'Email',
                                style: CommonStyles.txSty_12b_fb,
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
                            controller: emailController,
                            maxLength: 60,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            keyboardType: TextInputType.emailAddress,
                            onTap: () {
                              setState(() {
                                EmailFocus.addListener(() {
                                  if (EmailFocus.hasFocus) {
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      Scrollable.ensureVisible(
                                        EmailFocus.context!,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    });
                                  }
                                });
                              });
                            },
                            focusNode: EmailFocus,
                            decoration: InputDecoration(
                              errorText: _emailError ? _emailErrorMsg : null,
                              // errorStyle: CommonStyles.texterrorstyle,
                              contentPadding: const EdgeInsets.only(
                                  top: 15, bottom: 10, left: 15, right: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF0f75bc),
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
                                  Radius.circular(6.0),
                                ),
                              ),
                              hintText: 'Enter Email',
                              counterText: "",
                              hintStyle: CommonStyles.texthintstyle,
                            ),
                            validator: validateEmail,
                            onChanged: (value) {
                              setState(() {
                                _emailError = false;
                              });
                            },
                            style: CommonStyles.txSty_14b_fb,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      //MARK: Register
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              buttonText: 'Register',
                              color: CommonUtils.primaryTextColor,
                              onPressed: checkInternetConnection,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Future<void> fetchRadioButtonOptions() async {
    print('baseUrl: $baseUrl');
    print('getgender: $getgender');

    final url = Uri.parse(baseUrl + getgender);
    print('url==>946: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        final data = json.decode(response.body);
        setState(() {
          dropdownItems = data['listResult'];
        });
      } else {
        throw Exception('Failed to fetch radio button options');
      }
    } catch (e) {
      print('Error Radio: $e');
      throw Exception('Error Radio: $e');
    }
  }

//MARK: Validations
  String? validatefullname(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Please Enter Full Name';
        _scrollToAndFocus(FullnameFocus, 0);
      });
      isFullNameValidate = false;
      return null;
    }
    if (value.length < 2) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Full Name Should Contains Minimum 2 Characters';
        _scrollToAndFocus(FullnameFocus, 0);
      });
      isFullNameValidate = false;
      return null;
    }

    if (!RegExp(r'[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Full Name Should Only Contain Alphabetic Characters';
    }
    if (!RegExp(r'[a-zA-Z\s]+$').hasMatch(value)) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Full Name Should Only Contain Alphabets';
        _scrollToAndFocus(FullnameFocus, 0);
      });
      isFullNameValidate = false;
      return null;
    }
    isFullNameValidate = true;
    return null;
  }

  String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _dobError = true;
        _dobErrorMsg = 'Please Select Date of Birth';
        _scrollToAndFocus(DateofBirthdFocus, 0);
      });
      isDobValidate = false;
      return null;
    } else {
      setState(() {
        _dobError = false;
      });
    }
    isDobValidate = true;
    return null;
  }

  void validateGender(String? value) {
    if (value == null || value.isEmpty || selectedTypeCdId == -1) {
      isGenderSelected = true;
      isGenderValidate = false;
    } else {
      isGenderSelected = false;
      isGenderValidate = true;
    }
    setState(() {});
  }

  String? validateMobilenum(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Please Enter Mobile Number';
        _scrollToAndFocus(MobilenumberFocus, 1);
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.startsWith(RegExp('[1-4]'))) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number Should Not Start with 1-4';
        _scrollToAndFocus(MobilenumberFocus, 2);
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.contains(RegExp(r'[a-zA-Z]'))) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number Should Contain Only Digits';
        _scrollToAndFocus(MobilenumberFocus, 3);
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.length != 10) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number Must Have 10 Digits';
        _scrollToAndFocus(MobilenumberFocus, 4);
      });
      isMobileNumberValidate = false;
      return null;
    }
    isMobileNumberValidate = true;
    return null;
  }

  String? validateAlterMobilenum(String? value) {
    if (value!.isEmpty) {
      return null;
    }
    if (value.startsWith(RegExp('[1-4]'))) {
      setState(() {
        _altNumberError = true;
        _altNumberErrorMsg =
            'Alternate Mobile Number Should Not Start with 1-4';
      });
      isAltMobileNumberValidate = false;
      return null;
    }
    if (value.contains(RegExp(r'[a-zA-Z]'))) {
      setState(() {
        _altNumberError = true;
        _altNumberErrorMsg =
            'Alternate Mobile Number Should Contain Only Digits';
      });
      isAltMobileNumberValidate = false;
      return null;
    }
    if (value.length != 10) {
      setState(() {
        _altNumberError = true;
        _altNumberErrorMsg = 'Alternate Mobile Number Must Have 10 Digits';
      });
      isAltMobileNumberValidate = false;
      return null;
    }
    isAltMobileNumberValidate = true;
    return null;
    // if (value!.isEmpty) {
    //   setState(() {
    //     _altNumberError = true;
    //     _altNumberErrorMsg = 'Please Enter Mobile Number';
    //   });
    //   isAltMobileNumberValidate = false;
    //   return null;
    // }
    // if (value.startsWith(RegExp('[1-4]'))) {
    //   setState(() {
    //     _mobileNumberError = true;
    //     _mobileNumberErrorMsg = 'Mobile Number Should Not Start with 1-4';
    //   });
    //   isMobileNumberValidate = false;
    //   return null;
    // }
    // if (value.contains(RegExp(r'[a-zA-Z]'))) {
    //   setState(() {
    //     _mobileNumberError = true;
    //     _mobileNumberErrorMsg = 'Mobile Number Should Contain Only Digits';
    //   });
    //   isMobileNumberValidate = false;
    //   return null;
    // }
    // if (value.length != 10) {
    //   setState(() {
    //     _mobileNumberError = true;
    //     _mobileNumberErrorMsg = 'Mobile Number Must Have 10 Digits';
    //   });
    //   isMobileNumberValidate = false;
    //   return null;
    // }
    // isMobileNumberValidate = true;
    // return null;
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _emailError = true;
        _emailErrorMsg = 'Please Enter Email';
      });
      isEmailValidate = false;
      return null;
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      setState(() {
        _emailError = true;
        _emailErrorMsg = 'Please Enter Valid Email';
      });
      isEmailValidate = false;
      return null;
    }
    isEmailValidate = true;
    return null;
  }

  String? validateUserName(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _userNameError = true;
        _userNameErrorMsg = 'Please Enter User Name';
      });
      print('xxx: 1');
      isUserNameValidate = false;
      return null;
    }
    if (value.length < 2) {
      setState(() {
        _userNameError = true;
        _userNameErrorMsg = 'User Name Should Contains Minimum 2 Characters';
      });
      print('xxx: 2');
      isUserNameValidate = false;
      return null;
    }
    if (invalidCredentials != null) {
      setState(() {
        _userNameError = true;
        _userNameErrorMsg = null;
      });
      print('xxx: 3');
      isUserNameValidate = true;
      return null;
    }
    isUserNameValidate = true;
    return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) {
      setState(() {
        isPasswordValidate = false;
        _passwordError = true;
        _passwordErrorMsg = 'Please Enter Password';
      });
      isPswdValidate = false;
      return null;
    } else if (value.length < 8) {
      setState(() {
        isPasswordValidate = false;
        _passwordError = true;
        _passwordErrorMsg = 'Password Must be 8 Characters or Above';
      });
      isPswdValidate = false;
      return null;
    }

    final hasAlphabets = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumbers = RegExp(r'\d').hasMatch(value);
    final hasSpecialCharacters =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    final hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(value);

    // if (!hasAlphabets || !hasNumbers || !hasSpecialCharacters || !hasCapitalLetter) {
    //   setState(() {
    //     isPasswordValidate = false;
    //     _passwordError = true;
    //     _passwordErrorMsg = 'Password Must Include One Uppercase, One Lowercase, One Digit, One Special Character, No Spaces, And be 08-25 Characters Long';
    //   });
    //   isPswdValidate = false;
    //   return null;
    // }
    setState(() {
      isPasswordValidate = true;
      isPswdValidate = true;
    });
    return null;
  }

  void _updatePasswordStrengthMessage(String password) {
    setState(() {
      if (password.isEmpty || password.length < 8) {
        isPasswordValidate = false;
      } else {
        if (_containsSpecialCharacters(password) &&
            _containsCharacters(password) &&
            _containsNumbers(password)) {
          _passwordStrengthMessage = 'Strong Password';
          _passwordStrengthColor = const Color.fromARGB(255, 2, 131, 68);
        } else if (_containsNumbers(password) &&
            _containsCharacters(password)) {
          _passwordStrengthMessage = 'Good password';
          _passwordStrengthColor = const Color.fromARGB(255, 161, 97, 0);
        } else {
          _passwordStrengthMessage = 'Weak password';
          _passwordStrengthColor = const Color.fromARGB(255, 181, 211, 15);
        }
      }
    });
  }

  bool _containsNumbers(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  bool _containsCharacters(String value) {
    return RegExp(r'[a-zA-Z]').hasMatch(value);
  }

  bool _containsSpecialCharacters(String value) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
  }

  String? validateconfirmpassword(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _confirmPasswordError = true;
        _confirmPasswordErrorMsg = 'Please Enter Confirm Password';
      });
      isConfirmPswdValidate = false;
      return null;
    } else if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = true;
        _confirmPasswordErrorMsg = 'Confirm Password Must be Same as Password';
      });
      isConfirmPswdValidate = false;
      return null;
    }
    isConfirmPswdValidate = true;
    return null;
  }

  void endUserMessageFromApi(String endUserMessage) {
    setState(() {
      _userNameError = true;
      _userNameErrorMsg = endUserMessage;
      //'User with this name is already exits';
      FocusScope.of(context).requestFocus(usernameFocus);
      // isUserNameValidate = true;
    });
    print('xxx: 4');
  }

  void endUserMessageFromApiforemail(String endUserMessage) {
    setState(() {
      _emailError = true;
      _emailErrorMsg = endUserMessage;
      //'User with this name is already exits';
      FocusScope.of(context).requestFocus(EmailFocus);
      // isUserNameValidate = true;
    });
    print('xxx: 4');
  }

  void endUserMessageFromApiformobilenum(String endUserMessage) {
    setState(() {
      _mobileNumberError = true;
      _mobileNumberErrorMsg = endUserMessage;
      //'User with this name is already exits';
      FocusScope.of(context).requestFocus(MobilenumberFocus);
      // isUserNameValidate = true;
    });
    print('xxx: 4');
  }

  void checkInternetConnection() {
    FocusManager.instance.primaryFocus?.unfocus();
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        validating();
      } else {
        CommonUtils.showCustomToastMessageLong(
            'Please Check Your Internet Connection', context, 1, 4);
      }
    });
  }

  Future<void> validating() async {
    FocusScope.of(context).unfocus();
    print('isFullNameValidate $isFullNameValidate');
    print('isDobValidate $isDobValidate');
    print('isGenderValidate $isGenderValidate');
    print('isMobileNumberValidate $isMobileNumberValidate');
    print('isEmailValidate $isEmailValidate');
    print('isUserNameValidate $isUserNameValidate');
    print('isPswdValidate $isPswdValidate');
    print('isConfirmPswdValidate $isConfirmPswdValidate');
    validateGender(selectedName);

    if (_formKey.currentState!.validate()) {
      if (isFullNameValidate &&
              // isDobValidate &&
              isGenderValidate &&
              // isMobileNumberValidate &&
              isEmailValidate
          // isUserNameValidate &&
          // isPswdValidate &&
          // isConfirmPswdValidate
          ) {
        FocusScope.of(context).unfocus();
        CommonStyles.startProgress(context);
        String? fullName = fullNameController.text.trim();
        String dob = dobController.text;
        //  String? gender = Gender.text;
        String? mobileNum = mobileNumberController.text.trim();
        String? alternateMobileNum = alernateMobileNumberController.text;
        String? email = emailController.text.trim();
        String? userName = userNameController.text;
        String? password = passwordController.text;
        String? confirmPassword = confirmPasswordController.text;

        String formattedDOB = '';
        print('Formatted Date of Birth: $formattedDOB');
        formattedDOB = DateFormat('yyyy-MM-dd').format(selectedDate); //

        final url = Uri.parse(baseUrl + customeregisration);
        print('apiData: $url');

        DateTime now = DateTime.now();
        // Using toString() method

/*         final request = {
          "id": null,
          "firstName": fullName.toString(),
          "middleName": null,
          "lastName": null,
          "contactNumber": widget.contactNumber,
          "mobileNumber": null,
          "userName": fullName.toString(),
          "password": 'Abcd@123',
          "confirmPassword": 'Abcd@123',
          "email": email.toString(),
          "isActive": true,
          "createdDate": "$now",
          "updatedByUserId": null,
          "updatedDate": "$now",
          "roleId": 2,
          "gender": selectedValue,
          "dateOfBirth": "2025-04-29",
          "branchIds": "null"
        }; */

        final request = {
          "id": null,
          "firstName": fullName.toString(),
          "middleName": null,
          "lastName": null,
          "contactNumber": widget.contactNumber,
          "mobileNumber": null,
          "userName": null,
          "password": null,
          "confirmPassword": null,
          "email": email.toString(),
          "isActive": true,
          "createdDate": "$now",
          "updatedByUserId": null,
          "updatedDate": "$now",
          "roleId": 2,
          "gender": selectedValue,
          "dateOfBirth": null,
          "branchIds": null
        };

        print('apiData: ${json.encode(request)}');
        try {
          // Send the POST request
          final response = await http.post(
            url,
            body: json.encode(request),
            headers: {
              'Content-Type': 'application/json',
            },
          );

          CommonStyles.stopProgress(context);
          if (response.statusCode == 200) {
            Map<String, dynamic> data = json.decode(response.body);
            FocusScope.of(context).unfocus();
            // Extract the necessary information
            bool isSuccess = data['isSuccess'];
            if (isSuccess == true) {
              CommonUtils.showCustomToastMessageLong(
                  'Customer Registered Sucessfully', context, 0, 5);
              FocusScope.of(context).unfocus();

              Map<String, dynamic> user = data['response'];
              await saveUserDataToSharedPreferences(user);

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(boolflagpopup: true),
                ),
                (route) => false,
              );
            } else {
              FocusScope.of(context).unfocus();

              /*  invalidCredentials = data['statusMessage'];
              String status_message = data['statusMessage'];
              if (status_message.contains('Email')) {
                endUserMessageFromApiforemail(data['statusMessage']);
                endUserMessageFromApiformobilenum(data['statusMessage']);
              }
              if (status_message.contains('User')) {
                endUserMessageFromApi(data['statusMessage']);
              }
 */
              CommonUtils.showCustomToastMessageLong(
                  '${data['statusMessage']}', context, 1, 5);
            }
          } else {
            FocusScope.of(context).unfocus();
            CommonUtils.showCustomToastMessageLong(
                'Something went wrong', context, 1, 5);
            print(
                'Failed to send the request. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error slot: $e');
          rethrow;
        }
      }
    }
  }

  Future<void> saveUserDataToSharedPreferences(
      Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('isLoggedIn', true);
    // Save user data using unique keys
    final genderTypeId = userData['gender'];
    final gender = getGender(genderTypeId);
    await prefs.setInt('userId', userData['id']);
    await prefs.setString('userFullName', userData['firstName'] ?? '');
    await prefs.setString('username', userData['userName'] ?? '');
    await prefs.setInt('userRoleId', userData['roleID'] ?? 0);
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('contactNumber', userData['contactNumber'] ?? '');
    await prefs.setString('gender', gender);
    // await prefs.setString('gender', userData['gender']);
    await prefs.setString('dateofbirth', userData['dateofbirth'] ?? '');
    await prefs.setString('password', userData['password'] ?? '');
    await prefs.setInt('genderTypeId', genderTypeId);
    prefs.setBool('isLoggedIn', true);
  }

  String getGender(int? genderTypeId) {
    if (genderTypeId == 1) {
      return 'Male';
    } else if (genderTypeId == 2) {
      return 'Female';
    } else {
      return '';
    }
  }

  void loginUser() {
    if (_formKey.currentState!.validate()) {
      print('login: Login success!');
    }
  }

  bool isValidDateFormat(String date) {
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class CustomDatePicker extends StatelessWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime?>? onDateSelected;

  const CustomDatePicker({
    Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.blue, // Change this to your desired color
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null && onDateSelected != null) {
          onDateSelected!(pickedDate);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: initialDate.toLocal().toString().split(' ')[0],
          ),
          decoration: const InputDecoration(
            labelText: 'Date',
            suffixIcon: Icon(Icons.calendar_today),
          ),
        ),
      ),
    );
  }
}
