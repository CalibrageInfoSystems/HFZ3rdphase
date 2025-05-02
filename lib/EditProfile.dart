import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:hairfixingzone/CustomerLoginScreen.dart';
import 'package:hairfixingzone/NewScreen.dart';
import 'package:hairfixingzone/startingscreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChangePasswordScreen.dart';
import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'Common/custome_form_field.dart';
import 'CommonUtils.dart';
import 'package:intl/intl.dart';

import 'HomeScreen.dart';
import 'api_config.dart';

class EditProfile extends StatefulWidget {
  final String createdDate;

  const EditProfile({super.key, required this.createdDate});

  @override
  EditProfile_screenState createState() => EditProfile_screenState();
}

class EditProfile_screenState extends State<EditProfile> {
  List<dynamic> dropdownItems = [];

  String? selectedName;
  late int selectedValue;
  int selectedTypeCdId = -1;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController alernateMobileNumberController =
      TextEditingController();
  TextEditingController emailController = TextEditingController();

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
  String? selectedGender;
  bool isFullNameValidate = false;
  bool isDobValidate = false;
  bool isGenderValidate = false;
  bool isMobileNumberValidate = false;
  bool isAltMobileNumberValidate = false;
  bool isEmailValidate = false;
  bool isGenderSelected = false;

  // int? Id;
  int? createdByUserId;
  int? userId;
  String? createdDate;
  String? phoneNumber;
  String? username;
  int? loginUserId;
  String? loginUserEmail;
  String? loginUserContactNumber;
  String? loginUserAlternerNumber;
  String? loginUserGender;
  String? loginUserDob;
  String? formattedDate;
  String? dobDate;
  String? roleName;
  String? loginUserPassword;
  String? loginUserFullName;
  String? loginUserUserName;
  int? loginUserRoleID;
  String? loginUserRolename;

  late Future<void> _fetchUserDataFuture;

  DateTime? selectedDate;
  late SharedPreferences prefs;
  int? gendertypeid;

  int Id = 0;

  @override
  void initState() {
    _fetchUserDataFuture = fetchLoginUserData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    selectedDate = DateTime
        .now(); // Initialize selectedDate with a non-null value, if needed

    CommonUtils.checkInternetConnectivity().then((isConnected) async {
      if (isConnected) {
        fetchRadioButtonOptions();

        // fetchMyAppointments(userId);
      } else {
        CommonUtils.showCustomToastMessageLong(
            'Please Check Your Internet Connection', context, 1, 4);
        print('The Internet Is not  Connected');
      }
    });
    super.initState();
  }

  //MARK: fetch loginuser

  Future<void> fetchLoginUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getInt('userId') ?? 0;
    //String apiUrl = 'http://182.18.157.215/SaloonApp/API/GetCustomerData?id=$id';
    String apiUrl = '$baseUrl$getCustomerDatabyid$loginUserId';
    print('loginUserId: $loginUserId');
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
        loginUserUserName = customerData['userName'] ?? '';
        loginUserRoleID = customerData['roleID'] ?? 0;
        loginUserRolename = customerData['rolename'] ?? '';
        loginUserContactNumber = customerData['contactNumber'] ?? '';
        loginUserEmail = customerData['email'] ?? '';
        loginUserGender = customerData['gender'] ?? '';
        loginUserRolename = customerData['rolename'] ?? '';
        loginUserAlternerNumber = customerData['mobileNumber'] ?? '';
        loginUserPassword = customerData['password'] ?? '';
        loginUserDob = customerData['dateofbirth'] ?? '';
        gendertypeid = customerData['genderId'] ?? 0;
        // createdByUserId = prefs.getInt('profilecreatedId');
        createdByUserId = customerData['createdByUserId'];
        print('createdByUserId ${createdByUserId}');
        //  formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dob));

        fullNameController.text = "$loginUserFullName";
        dobController.text = (loginUserDob != null && loginUserDob!.isNotEmpty)
            ? DateFormat('dd-MM-yyyy').format(DateTime.parse('$loginUserDob'))
            : '';
        emailController.text = '$loginUserEmail';
        mobileNumberController.text = '$loginUserContactNumber';
        alernateMobileNumberController.text = '$loginUserAlternerNumber';
        selectedGender = loginUserGender;
        isGenderSelected = true;
        isGenderValidate = false;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime oldestDate =
        DateTime(currentDate.year - 100); // Allow selection from 100 years ago
    final DateTime initialDate =
        selectedDate ?? currentDate; // Use currentDate if selectedDate is null

    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate,
      // initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: oldestDate,
      lastDate: currentDate,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      setState(() {
        selectedDate = pickedDay;
        dobController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      });
    }
  }

  Future<void> fetchRadioButtonOptions() async {
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
        // if (responseData != null && responseData['listResult'] is List<dynamic>) {
        //   List<dynamic> optionsData = responseData['listResult'];
        //   setState(() {
        //     dropdownItems = optionsData['listResult'];
        //     //  options = optionsData.map((data) => RadioButtonOption.fromJson(data)).toList();
        //   });
        // } else {
        //   throw Exception('Invalid response format');
        // }
      } else {
        throw Exception('Failed to fetch radio button options');
      }
    } catch (e) {
      throw Exception('Error Radio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xffe2f0fd),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                  color: Color(0xFF0f75bc),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: CommonUtils.primaryTextColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: _fetchUserDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: const Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return editProfileFormData(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Form editProfileFormData(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                CustomeFormField(
                  //MARK: Full Name
                  label: 'Full Name ',
                  maxLength: 50,

                  validator: validatefullname,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\s]')), // Including '\s' for space
                  ],
                  controller: fullNameController,
                  keyboardType: TextInputType.name,
                  errorText: _fullNameError ? _fullNameErrorMsg : null,
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
                const SizedBox(
                  height: 10,
                ),

                const Row(
                  children: [
                    Text(
                      'Gender ',
                      style: CommonStyles.txSty_12b_fb,
                    ),
                    Text(
                      '*',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0, top: 5.0, right: 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CommonUtils.primaryTextColor,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButton<String>(
                            value: selectedGender,
                            iconSize: 30,
                            icon: null,
                            style: CommonUtils.txSty_12b_fb,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;

                                gendertypeid = dropdownItems.firstWhere(
                                    (item) =>
                                        item['desc'] ==
                                        selectedGender)['typeCdId'];
                                print("gendertypeid:$gendertypeid");
                                // if (selectedTypeCdId != -1) {
                                //   selectedValue = dropdownItems[selectedTypeCdId]['typeCdId'];
                                //   selectedName = dropdownItems[selectedTypeCdId]['desc'];
                                //
                                //   print("selectedValue:$selectedValue");
                                //   print("selectedName:$selectedName");
                                // } else {
                                //   print("==========");
                                //   print(selectedValue);
                                //   print(selectedName);
                                // }
                                // isDropdownValid = selectedTypeCdId != -1;
                                //    isGenderSelected = false;
                              });
                            },
                            items: [
                              // const DropdownMenuItem<String>(
                              //   value: -1,
                              //   child: Text(
                              //     'Select Gender',
                              //     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                              //   ),
                              // ),
                              ...dropdownItems.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['desc'],
                                  child: Text(
                                    item['desc'],
                                    style: CommonStyles.txSty_14b_fb,
                                  ),
                                );
                              }).toList(),
                            ]),
                      ),
                    ),
                  ),
                ),
                //
                // Padding(
                //   padding: const EdgeInsets.only(left: 0, top: 5.0, right: 0),
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     decoration: BoxDecoration(
                //       border: Border.all(
                //         color: isGenderSelected ? const Color.fromARGB(255, 175, 15, 4) : CommonUtils.primaryTextColor,
                //       ),
                //       borderRadius: BorderRadius.circular(5.0),
                //       color: Colors.white,
                //     ),
                //     child: DropdownButtonHideUnderline(
                //       child: ButtonTheme(
                //         alignedDropdown: true,
                //         child: DropdownButton<String>(
                //           value: selectedGender,
                //           iconSize: 30,
                //           icon: null,
                //           style: const TextStyle(
                //             color: Colors.black,
                //           ),
                //           onChanged: (value) {
                //             setState(() {
                //               // selectedTypeCdId = value!;
                //               // if (selectedTypeCdId != -1) {
                //               //   selectedValue = dropdownItems[selectedTypeCdId]['typeCdId'];
                //               //   selectedName = dropdownItems[selectedTypeCdId]['desc'];
                //               //
                //               //   print("selectedValue:$selectedValue");
                //               //   print("selectedName:$selectedName");
                //               // } else {
                //               //   print("==========");
                //               //   print(selectedValue);
                //               //   print(selectedName);
                //               // }
                //               // // isDropdownValid = selectedTypeCdId != -1;
                //               // isGenderSelected = false;
                //
                //               selectedGender = value!;
                //               selectedTypeCdId = dropdownItems.indexWhere((item) => item['desc'] == selectedGender);
                //               isGenderSelected = false;
                //               prefs.setString('gender', selectedGender!);
                //
                //               // selectedGender = value!; // Update the selectedGender variable
                //               // selectedTypeCdId = dropdownItems.indexWhere((item) => item['desc'] == selectedGender);
                //               // isGenderSelected = false;
                //               // // Save the selected gender to SharedPreferences
                //               // prefs.setString('gender', selectedGender!);
                //             });
                //             print('Selected TypeCdId: $selectedTypeCdId');
                //             isGenderSelected = false;
                //             prefs.setString('gender', selectedGender!);
                //           },
                //           items: [
                //             // const DropdownMenuItem<String>(
                //             //   value: '',
                //             //   child: Text(
                //             //     'Select Gender',
                //             //     style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                //             //   ),
                //             // ),
                //             ...dropdownItems.map((item) {
                //               return DropdownMenuItem<String>(
                //                 value: item['desc'],
                //                 child: Text(item['desc']),
                //               );
                //             }).toList(),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // //MARK: Gender condition
                // if (isGenderSelected)
                //   const Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                //         child: Text(
                //           'Please Select Gender',
                //           style: TextStyle(
                //             color: Color.fromARGB(255, 175, 15, 4),
                //             fontSize: 12,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),

                const SizedBox(
                  height: 10,
                ),

                const Row(
                  children: [
                    Text(
                      'Email ',
                      style: CommonStyles.txSty_12b_fb,
                    ),
                    Text(
                      '*',
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
                  onTap: () {},
                  decoration: InputDecoration(
                      errorText: _emailError ? _emailErrorMsg : null,
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
                          Radius.circular(10),
                        ),
                      ),
                      hintText: 'Enter Email',
                      counterText: "",
                      hintStyle: CommonStyles.texthintstyle),
                  validator: validateEmail,
                  style: CommonStyles.txSty_14b_fb,
                  onChanged: (value) {
                    setState(() {
                      _emailError = false;
                    });
                  },
                ),

                const SizedBox(
                  height: 10,
                ),

                //MARK: Mobile Number
                CustomeFormField(
                  label: 'Mobile Number ',
                  validator: validateMobilenum,
                  controller: mobileNumberController,
                  maxLength: 10,
                  readOnly: true,
                  borderColor: Colors.grey.shade200,
                  screenForReschedule: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  keyboardType: TextInputType.phone,
                  errorText: _mobileNumberError ? _mobileNumberErrorMsg : null,
                  onChanged: (value) {
                    setState(() {
                      if (value.length == 1 &&
                          ['0', '1', '2', '3', '4'].contains(value)) {
                        mobileNumberController.clear();
                      }
                      if (value.startsWith(' ')) {
                        mobileNumberController.value = TextEditingValue(
                          text: value.trimLeft(),
                          selection: TextSelection.collapsed(
                              offset: value.trimLeft().length),
                        );
                      }
                      _mobileNumberError = false;
                    });
                  },
                ),

                const SizedBox(
                  height: 10,
                ),

                ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Date of Birth ',
                          style: CommonUtils.txSty_12b_fb,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    //MARK: DOB
                    TextFormField(
                      controller: dobController,
                      onTap: () {
                        _selectDate(context);
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        errorText: _dobError ? _dobErrorMsg : null,
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
                        hintText: 'Enter Date of Birth',
                        counterText: "",
                        hintStyle: CommonStyles.texthintstyle,
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      // validator: validateDOB,
                      style: CommonStyles.txSty_14b_fb,
                      onChanged: (value) {
                        setState(() {
                          _dobError = false;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    const Row(
                      children: [
                        Text(
                          'Alternate Mobile Number ',
                          style: CommonStyles.txSty_12b_fb,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    TextFormField(
                      controller: alernateMobileNumberController,
                      keyboardType: TextInputType.phone,
                      onTap: () {
                        // setState(() {
                        //   AlernateMobilenumFocus.addListener(
                        //       () {
                        //     if (AlernateMobilenumFocus
                        //         .hasFocus) {
                        //       Future.delayed(
                        //           const Duration(
                        //               milliseconds: 300), () {
                        //         Scrollable.ensureVisible(
                        //           AlernateMobilenumFocus
                        //               .context!,
                        //           duration: const Duration(
                        //               milliseconds: 300),
                        //           curve: Curves.easeInOut,
                        //         );
                        //       });
                        //     }
                        //   });
                        // });
                      },
                      decoration: InputDecoration(
                        counterText: '',
                        errorText: _altNumberError ? _altNumberErrorMsg : null,
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
                            Radius.circular(10),
                          ),
                        ),
                        hintText: 'Enter Alternate Mobile Number',
                        hintStyle: CommonStyles.texthintstyle,
                      ),
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      style: CommonStyles.txSty_14b_fb,
                      // validator: validateAlterMobilenum,
                      onChanged: (value) {
                        setState(() {
                          if (value.length == 1 &&
                              ['0', '1', '2', '3', '4'].contains(value)) {
                            alernateMobileNumberController.clear();
                          }
                          if (value.startsWith(' ')) {
                            alernateMobileNumberController.value =
                                TextEditingValue(
                              text: value.trimLeft(),
                              selection: TextSelection.collapsed(
                                  offset: value.trimLeft().length),
                            );
                          }
                          _altNumberError = false;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),
                // Row(
                //       children: [
                //         Expanded(
                //           child: CustomButton(
                //               buttonText: 'Change Password',
                //               textColor: CommonStyles.whiteColor,
                //               borderColor: CommonStyles.primaryTextColor,
                //               color: CommonStyles.primaryTextColor,
                //               onPressed: () {
                //                 Navigator.of(context).push(
                //                   MaterialPageRoute(
                //                     builder: (context) =>
                //                         ChangePasswordScreen(
                //                           id: loginUserId!,
                //                           password: loginUserPassword!,
                //                         ),
                //                   ),
                //                 );
                //               }),
                //         ),
                //       ],
                //     ),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'Update Details',
                        color: CommonUtils.primaryTextColor,
                        onPressed: validating,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'Delete Account',
                        color: CommonUtils.primaryTextColor,
                        onPressed: deleteaccount,
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }

  Future<void> deleteaccount() async {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.white,
            content: IntrinsicHeight(
                child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.7,
              padding:
                  EdgeInsets.only(left: 15.0, right: 10, top: 6, bottom: 10),
              child: Stack(
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Delete Confirmation',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.height / 8,
                        child: Image.asset('assets/hfz_logo.png'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Once you delete your account, all of your information and booking slots will be lost forever. We will not be able to restore your account. ',
                        style: TextStyle(
                            color: CommonUtils.primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit'),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //Are you sure you want to proceed?
                      Text(
                        'Are you sure you want to proceed?',
                        style: TextStyle(
                            color: CommonUtils.primaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit'),
                      ),
                      // SizedBox(height: 15,),
                    ],
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  //SizedBox(height: 15,),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonText: 'Yes',
                            color: CommonUtils.primaryTextColor,
                            onPressed: apihit,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: CustomButton(
                            buttonText: 'No',
                            color: CommonUtils.primaryTextColor,
                            onPressed: closepopup,
                          ),
                        ),
                      ],
                    ),
                  )

                  // Image inside the dialog
                ],
              ),
            )));
      },
    );
  }

  Future<void> validating() async {
    validateGender(selectedName);
    if (_formKey.currentState!.validate()) {
      print(isFullNameValidate);
      print(isMobileNumberValidate);
      print(isEmailValidate);
      // print(isDobValidate);
      print(alernateMobileNumberController.text);

      if (isFullNameValidate && isMobileNumberValidate && isEmailValidate) {
        String? alternateMobile = alernateMobileNumberController.text.isNotEmpty
            ? alernateMobileNumberController.text
            : null;

        if (alternateMobile != null && isAltMobileNumberValidate) {
          updateUser();
        } else if (alternateMobile == null) {
          updateUser();
        }
      } else {
        print('validation failed');
      }
    }
  }

  Future<void> apihit() async {
    final url = Uri.parse(baseUrl + deleteuser);
    DateTime now = DateTime.now();
    ProgressDialog progressDialog = ProgressDialog(context);
    print('url$url');

    // Show the progress dialog
    progressDialog.show();
    final request = {
      "id": loginUserId,
      "updatedByUserId": loginUserId,
      "updatedDate": "$now"
    };

    print('DeleteAccountObject: ${json.encode(request)}');
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

        // Extract the necessary information
        bool isSuccess = data['isSuccess'];
        if (isSuccess == true) {
          progressDialog.dismiss();
          print('Request sent successfully');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                boolflagpopup: false,
              ),
            ),
          );

          print('statusmesssage:${data['statusMessage']}');
          //CommonUtils.showCustomToastMessageLong('${data['statusMessage']}', context, 0, 5);
          setState(() async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('isLoggedIn', false);
            prefs.remove('userId');
            prefs.remove('userFullName');
            prefs.remove('username');
            prefs.remove('userRoleId');
            prefs.remove('email');
            prefs.remove('contactNumber');
            prefs.remove('gender');
            prefs.remove('dateofbirth');
            prefs.remove('password');
            prefs.remove('genderTypeId');
            // Remove roleId from SharedPreferences

            CommonUtils.showCustomToastMessageLong(
                'Profile Delete Successfully', context, 0, 5);
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(builder: (context) => CustomerLoginScreen()),
            // );
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (context) => CustomerLoginScreen()),
            //   (Route<dynamic> route) => false, // This removes all previous routes.
            // );
            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(builder: (context) =>  startingscreen()),
            //       (route) => false,
            // );
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => startingscreen()),
              (route) => false, // Clear all previous routes
            );
          });

          // Success case11.Customer Updated Sucessfully
          // Handle success scenario here
        } else {
          progressDialog.dismiss();
          // Failure case
          // Handle failure scenario here
          print('statusmesssage${data['statusMessage']}');
          CommonUtils.showCustomToastMessageLong(
              '${data['statusMessage']}', context, 1, 5);
        }
      } else {
        progressDialog.dismiss();
        //showCustomToastMessageLong(
        // 'Failed to send the request', context, 1, 2);
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      progressDialog.dismiss();
      print('Error slot: $e');
    }
  }

  void closepopup() {
    Navigator.pop(context);
  }

//MARK: Validations

  String? validatefullname(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Please Enter Full Name';
      });
      isFullNameValidate = false;
      return null;
    }
    if (value.length < 2) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Full Name Should Contains Minimum 2 Characters';
      });
      isFullNameValidate = false;
      return null;
    }
    if (!RegExp(r'[a-zA-Z\s]').hasMatch(value)) {
      return 'Full Name Should be Contains Alphabetic Characters';
    }
    if (!RegExp(r'[a-zA-Z\s]').hasMatch(value)) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Full Name Should Only Contain Alphabets';
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
      });
      isDobValidate = false;
      return null;
    }
    isDobValidate = true;
    return null;
  }

  // void validateGender(String? value) {
  //   if (value == null || value.isEmpty) {
  //     isGenderSelected = true;
  //     isGenderValidate = false;
  //   } else {
  //     isGenderSelected = false;
  //     isGenderValidate = true;
  //   }
  //   //setState(() {});
  // }
  void validateGender(String? value) {
    if (value == null || value.isEmpty) {
      isGenderSelected = true;
      isGenderValidate = false;
    } else {
      isGenderSelected = false;
      isGenderValidate = true;
    }
    //   setState(() {});
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _emailError = true;
        _emailErrorMsg = 'Please Enter Email';
      });
      isEmailValidate = false;
      return null;
      //} else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$')
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

  String? validateMobilenum(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Please Enter Mobile Number';
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.startsWith(RegExp('[1-4]'))) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number Should Not Start with 1-4';
      });
      isMobileNumberValidate = false;
      return null;
    }
    if (value.contains(RegExp(r'[a-zA-Z]'))) {
      setState(() {
        _mobileNumberError = true;
        _mobileNumberErrorMsg = 'Mobile Number should contain only digits';
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
  }

//MARK: Update user
  Future<void> updateUser() async {
    validateGender(selectedName);
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(baseUrl + updateuser);
      DateTime now = DateTime.now();
      ProgressDialog progressDialog = ProgressDialog(context);
      print('url$url');

      String? formattedDob;
      //'$formattedDate';

      // Format the date of birth
      DateTime? dob;
      dob = dobController.text == ''
          ? null
          : DateFormat('dd-MM-yyyy').parse(dobController.text);

      String dOBobject =
          dobController.text == '' ? '' : DateFormat('yyyy-MM-dd').format(dob!);
      // Show the progress dialog
      progressDialog.show();
      final request = {
        "id": loginUserId,
        "userId": null, //null
        "firstName": fullNameController.text,
        "middleName": "",
        "lastName": "",
        "contactNumber": mobileNumberController.text,
        "mobileNumber": alernateMobileNumberController.text,
        "userName": "$loginUserUserName",
        "password": "$loginUserPassword",
        "confirmPassword": "$loginUserPassword",
        "email": emailController.text,
        "isActive": true,
        "createdByUserId": loginUserId,
        "createdDate": "$now",
        "updatedByUserId": loginUserId,
        "updatedDate": "$now",
        "roleId": loginUserRoleID,
        "gender": gendertypeid,
        "dateofbirth": dOBobject,
        "branchIds": "null"
      };

      print('Editprofileapi: ${json.encode(request)}');
      try {
        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        progressDialog.dismiss();
        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);

          // Extract the necessary information
          bool isSuccess = data['isSuccess'];
          if (isSuccess == true) {
            progressDialog.dismiss();
            print('Request sent successfully');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) =>
                      EditProfile(createdDate: widget.createdDate)),
            );
            // showCustomToastMessageLong('Slot booked successfully', context, 0, 2);
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) =>  NewScreen(userName: loginUserFullName!, email: loginUserEmail!),
            //   ),
            // );
            print('statusmesssage:${data['statusMessage']}');
            //CommonUtils.showCustomToastMessageLong('${data['statusMessage']}', context, 0, 5);
            CommonUtils.showCustomToastMessageLong(
                'Customer Updated Successfully', context, 0, 5);
            //  CommonUtils.showCustomToastMessageLong('${data['statusMessage']}', context, 0, 5);

            // Success case11.Customer Updated Sucessfully
            // Handle success scenario here
          } else {
            progressDialog.dismiss();
            // Failure case
            // Handle failure scenario here
            print('statusmesssage${data['statusMessage']}');
            CommonUtils.showCustomToastMessageLong(
                '${data['statusMessage']}', context, 1, 5);
          }
        } else {
          progressDialog.dismiss();
          //showCustomToastMessageLong(
          // 'Failed to send the request', context, 1, 2);
          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        progressDialog.dismiss();
        print('progressDialog Error slot: $e');
      }
    }
  }
}
