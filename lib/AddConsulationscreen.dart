import 'dart:convert';
import 'package:flutter/widgets.dart';

import 'package:hairfixingzone/AgentHome.dart';
import 'package:hairfixingzone/services/notifi_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AgentBranchModel.dart';
import 'BranchModel.dart';
import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'Common/custome_form_field.dart';
import 'CommonUtils.dart';
import 'package:intl/intl.dart';

import 'HomeScreen.dart';
import 'api_config.dart';

class AddConsulationscreen extends StatefulWidget {
  final int agentId;
  final AgentBranchModel  branch;

  const AddConsulationscreen({super.key, required this.agentId, required this.branch});

  @override
  AddConsulationscreen_screenState createState() => AddConsulationscreen_screenState();
}

class AddConsulationscreen_screenState extends State<AddConsulationscreen> {
  List<dynamic> dropdownItems = [];
  List<dynamic> BranchesdropdownItems = [];
  List<dynamic> cityDropdownItems = [];
  String? selectedName;
  late int selectedValue;
  FocusNode remarksFocus = FocusNode();
  String? branchName;
  int? branchValue;
  int selectedTypeCdId = -1;
  int branchselectedTypeCdId = -1;
  String formattedDate = '';
  String? cityName;
  int? cityValue;
  int citySelectedTypeCdId = -1;
  bool isCitySelected = false;
  bool isCityValidate = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController branchController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _fullNameError = false;
  String? _fullNameErrorMsg;
  bool _dobError = false;
  String? _dobErrorMsg;
  bool _emailError = false;
  String? _emailErrorMsg;

  bool _remarksError = false;
  String? _remarksErrorMsg;

  bool _mobileNumberError = false;
  String? _mobileNumberErrorMsg;
  final bool _altNumberError = false;
  String? _altNumberErrorMsg;
  bool isremarksValidate = false;
  bool isFullNameValidate = false;
  bool isDobValidate = false;
  bool isGenderValidate = false;
  bool isBranchValidate = false;
  bool isMobileNumberValidate = false;
  bool isAltMobileNumberValidate = false;
  bool isEmailValidate = false;
  bool isRemarksValidate = false;
  bool isGenderSelected = false;
  bool isBranchSelected = false;

  int? Id;
  String? phonenumber;
  String? username;
  String? email;
  String? contactNumber;
  String? gender;
  String? dob;
  String? formattedDateapi;
  int? roleId;
  String? password;
  String? fullname;
  late String visiteddate;
  //DateTime _selectedDate = DateTime.now();
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  late String slot_time;
  String? visitingDateTime;
  DateTime? VisitslotDateTime;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        setState(() {
          print('Branch Name: ${widget.branch.name}');
          print('city Name: ${widget.branch.city}');
          cityController.text = widget.branch.city;
          branchController.text = widget.branch.name;
          _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
          visiteddate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        });
        fetchRadioButtonOptions();
      } else {
        CommonUtils.showCustomToastMessageLong(
            'Please Check Your Internet Connection', context, 1, 4);
        print('The Internet Is not Connected');
      }
    });


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

  Future<void> _getBranchData(int userId, int cityid) async {
    // setState(() {
    //   _isLoading = true; // Set isLoading to true before making the API call
    // });

    String apiUrl = '$baseUrl$GetBranchByUserId$userId/$cityid';
    // const maxRetries = 1; // Set maximum number of retries
    // int retries = 0;

    //while (retries < maxRetries) {
    try {
      // Make the HTTP GET request with a timeout of 30 seconds
      final response = await http.get(Uri.parse(apiUrl));
      print('apiUrl: $apiUrl');
      if (response.statusCode == 200) {
        // final data = json.decode(response.body);
        final data = json.decode(response.body);
        setState(() {
          BranchesdropdownItems = data['listResult'];
        });

        return; // Exit the function after successful response
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AgentHome(userId: widget.agentId)),
          );
          return false;
        },
        child: Scaffold(
            backgroundColor: CommonStyles.whiteColor,
            appBar: AppBar(
              backgroundColor:  Color(0xffe2f0fd),
              automaticallyImplyLeading: false,
              title:Text(
                'Add Consultation',
                style: CommonStyles.txSty_20b_fb,

              ),
                titleSpacing:0.0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: CommonUtils.primaryTextColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
            ),
            body: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          CustomeFormField(
                            //MARK: Full Name
                            label: 'Full Name',
                            validator: validatefullname,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(
                                  r'[a-zA-Z\s]')), // Including '\s' for space
                            ],
                            controller: fullNameController,
                            maxLength: 50,
                            keyboardType: TextInputType.name,

                            errorText:
                                _fullNameError ? _fullNameErrorMsg : null,
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

                          // CustomeFormField(
                          //   label: 'Date of Birth',
                          //   validator: validatedob,
                          //   controller: DateofBirth,
                          //   focusNode: DateofBirthdFocus,
                          //   onTap: () => _selectDate(context),
                          // ),

                          // const SizedBox(
                          //   height: 10,
                          // ),
                          const Row(
                            children: [
                              Text(
                                'Gender ',
                                style:CommonUtils.txSty_12b_fb,
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
                            padding: const EdgeInsets.only(
                                left: 0, top: 0.0, right: 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isGenderSelected
                                      ? const Color.fromARGB(255, 175, 15, 4)
                                      : CommonUtils.primaryTextColor,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<int>(
                                      value: selectedTypeCdId,
                                      iconSize: 30,
                                      icon: null,
                                     style:CommonUtils.txSty_12b_fb,
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

                                            print(
                                                "selectedValue:$selectedValue");
                                            print("selectedName:$selectedName");
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
                                          ),
                                        ),
                                        ...dropdownItems
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final item = entry.value;
                                          return DropdownMenuItem<int>(
                                            value: index,
                                            child: Text(item['desc'],  style:CommonUtils.txSty_12b_fb,),
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
                                    style: CommonStyles.texterrorstyle
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(
                            height: 10,
                          ),

                          CustomeFormField(
                            //MARK: Mobile Number
                            label: 'Mobile Number',
                            validator: validateMobilenum,
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
                                if (value.length == 1 &&
                                    ['0', '1', '2', '3', '4'].contains(value)) {
                                  mobileNumberController.clear();
                                }
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
                          const SizedBox(
                            height: 10,
                          ),

                          const Row(
                            children: [
                              Text(
                                'Email',
                                style: CommonUtils.txSty_12b_fb)
                              // Text(
                              //   ' *',
                              //   style: TextStyle(color: Colors.red),
                              // ),
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
                              hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400),
                            ),
                            //  validator: validateEmail,
                            onChanged: (value) {
                              setState(() {
                                _emailError = false;
                              });
                            },
                            style: CommonStyles.txSty_14b_fb,
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          CustomeFormField(
                            label: 'City',
                            validator: (value) {
                              // Custom validation logic
                              if (value == null || value.isEmpty) {
                                return 'City cannot be empty';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                            ],
                            controller: cityController,
                            keyboardType: TextInputType.name,
                            readOnly: true,
                          ),
                          const SizedBox(height: 10),
                          CustomeFormField(
                            label: 'Branch',
                            validator: (value) {
                              // Custom validation logic
                              if (value == null || value.isEmpty) {
                                return 'Branch cannot be empty';
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                            ],
                            controller: branchController,
                            keyboardType: TextInputType.name,
                            readOnly: true,
                          ),


                          const SizedBox(
                            height: 10,
                          ),
                          const Row(
                            children: [
                              Text(
                                'Visiting Date ',
                                style:CommonUtils.txSty_12b_fb,
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
                            controller: _dateController,
                            keyboardType: TextInputType.visiblePassword,
                            onTap: () {
                              _openDatePicker();
                            },
                            // focusNode: DateofBirthdFocus,
                            readOnly: true,
                            validator: (value) {
                              if (value!.isEmpty || value.isEmpty) {
                                return 'Choose Date ';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(
                                  top: 15, bottom: 10, left: 15, right: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFF11528f),
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
                              hintText: 'Date',
                              counterText: "",
                              hintStyle: CommonStyles.texthintstyle,
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF11528f),
                              ),
                            ),
                            style: CommonStyles.txSty_14b_fb,
                            //          validator: validateDate,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Row(
                            children: [
                              Text(
                                'Visiting Time ',
                                style:CommonUtils.txSty_12b_fb,
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
                Form(
                    key: _formKey2,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _timeController,
                          keyboardType: TextInputType.visiblePassword,
                          onTap: () {
                            _openTimePicker();
                          },
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Choose Time';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                                top: 15, bottom: 10, left: 15, right: 15),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Color(0xFF11528f),
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
                            hintText: 'Time',
                            counterText: "",
                            hintStyle: CommonStyles.texthintstyle,
                            errorStyle: CommonStyles.texterrorstyle,
                            suffixIcon: const Icon(
                              Icons.access_time,
                              color: Color(0xFF11528f),
                            ),
                          ),
                          style: CommonStyles.txSty_14b_fb,
                        ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Row(
                            children: [
                              Text(
                                'Remark ',
                                style:CommonUtils.txSty_12b_fb,
                              ),
                              // Text(
                              //   '*',
                              //   style: TextStyle(color: Colors.red),
                              // ),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          TextFormField(
                            controller: remarksController,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            maxLength: 250,
                            maxLines: 6,
                            onTap: () {
                              setState(() {
                                remarksFocus.addListener(() {
                                  if (remarksFocus.hasFocus) {
                                    Future.delayed(
                                        const Duration(milliseconds: 300), () {
                                      // Scrollable.ensureVisible(
                                      //   EmailFocus.context!,
                                      //   duration: const Duration(
                                      //       milliseconds: 300),
                                      //   curve: Curves.easeInOut,
                                      // );
                                    });
                                  }
                                });
                              });
                            },
                            decoration: InputDecoration(
                              errorText:
                                  _remarksError ? _remarksErrorMsg : null,
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
                              hintText: 'Enter Remark ',
                              counterText: "",
                              // counterText: "",
                              hintStyle:CommonStyles.texthintstyle,
                              errorStyle: CommonStyles.texterrorstyle,
                            ),
                            //  validator: validateremarks,
                            onChanged: (value) {
                              setState(() {
                                if (value.startsWith(' ')) {
                                  remarksController.value = TextEditingValue(
                                    text: value.trimLeft(),
                                    selection: TextSelection.collapsed(
                                        offset: value.trimLeft().length),
                                  );
                                }
                                if (value.length > 250) {
                                  // Trim the text if it exceeds 256 characters
                                  remarksController.value = TextEditingValue(
                                    text: value.substring(0, 250),
                                    selection: const TextSelection.collapsed(
                                        offset: 250),
                                  );
                                }
                                _remarksError = false;

                              }); // Update the UI when text changes
                            },

                            style: CommonStyles.txSty_14b_fb,
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  buttonText: 'Add Consultation',
                                  color: CommonUtils.primaryTextColor,
                                  onPressed: validating,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ))]),
            )))));
  }

  Future<void> validating() async {
    validateGender(selectedName);
    // validateCity(cityName);
    // validatebranch(branchName);

    if (_formKey.currentState!.validate()  && _formKey2.currentState!.validate()) {
      _printVisitingDateTime();
      print(isFullNameValidate);
      print(isGenderValidate);
      print(isMobileNumberValidate);
      //  print(isEmailValidate);
      print(isBranchValidate);
      //  print(isRemarksValidate);

      if (isFullNameValidate &&
          isGenderValidate &&
          isMobileNumberValidate ) {
        updateUser();
      }
    }
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
        _fullNameErrorMsg = 'Full Name should contains minimum 2 Characters';
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
      });
      isFullNameValidate = false;
      return null;
    }
    isFullNameValidate = true;
    return null;
  }

  String? validateremarks(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _remarksError = true;
        _remarksErrorMsg = 'Please Enter Remark';
      });
      isRemarksValidate = false;
      return null;
    }
    if (value.length < 3) {
      setState(() {
        _remarksError = true;
        _remarksErrorMsg = 'Please Enter Remarks';
      });
      isRemarksValidate = false;
      return null;
    }
    isRemarksValidate = true;
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
    } else if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      setState(() {
        _emailError = true;
        _emailErrorMsg = 'Please Enter A Valid Email';
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

  Future<void> updateUser() async {
    validateGender(selectedName);
 //   validatebranch(branchName);
    if (_formKey.currentState!.validate()) {
      DateTime now = DateTime.now();
      String mobilenumber = mobileNumberController.text;
      String apiEmail = emailController.text.toString();
      String apiUsrname = fullNameController.text.toString();
      String apiRemarks = remarksController.text.toString();
      ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      progressDialog.show();
      final request = {
        "id": null,
        "name": apiUsrname,
        "genderTypeId": selectedValue,
        "phoneNumber": mobilenumber,
        "email": apiEmail,
        "branchId": widget.branch.id,
        "isActive": true,
        "remarks": apiRemarks,
        "createdByUserId": widget.agentId,
        "createdDate": '$now',
        "updatedByUserId": null,
        "updatedDate": null,
        "visitingDate": visitingDateTime
      };
      print('Object: ${json.encode(request)}');
      try {
      final String ee = baseUrl + addupdateconsulation;
        //const String ee = 'http://182.18.157.215/SaloonApp/API/api/Consultation/AddUpdateConsultation';
        print(ee);
        final url1 = Uri.parse(ee);

        // Send the POST request
        final response = await http.post(
          url1,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json', // Set the content type header
          },
        );
        final jsonResponse = json.decode(response.body);
        final statusMessage = jsonResponse['statusMessage'];
        // Check the response status code
        if (response.statusCode == 200) {
          final isSuccess = jsonResponse['isSuccess'];

          if (isSuccess) {
            DateTime testdate = DateTime.now();
            print('Request sent successfully');
            progressDialog.dismiss();
            CommonUtils.showCustomToastMessageLong(
                '$statusMessage', context, 0, 5);
            print(response.body);
            final int notificationId1 = UniqueKey().hashCode;
            // debugPrint('Notification Scheduled for $testdate with ID: $notificationId1');
            debugPrint(
                'Notification Scheduled for $VisitslotDateTime with ID: $notificationId1');
            await NotificationService().scheduleNotification(
              title: 'Reminder Notification',
              //An Consulatation has been booked by Manohar at 17th july 10.30 AM Marathahalli Branch. Please check with him once -- Consultation Reminder Notification
              body:
                  'An Consulatation has been booked by $apiUsrname at $formattedDateapi $slot_time ${widget.branch.name} Branch. Please check with him once ',
              //  body: 'Hey $userFullName, Today Your Appointment is Scheduled for  $_selectedTimeSlot at the ${widget.branchname} Branch, Located at ${widget.branchaddress}.',
              //  scheduledNotificationDateTime: testdate!,
              scheduledNotificationDateTime: VisitslotDateTime!,
              id: notificationId1,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AgentHome(userId: widget.agentId)),
            );
          }
          // Navigator.pop(context);
        } else {
          progressDialog.dismiss();
          CommonUtils.showCustomToastMessageLong(
              '$statusMessage', context, 1, 5);
          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        progressDialog.dismiss();
        print('Error slot: $e');
      }
    }
  }


  Future<void> _openDatePicker() async {
    selectedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
        visiteddate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  void _openTimePicker() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        slot_time = pickedTime.format(context);
        print('selected Time $slot_time');
        _timeController.text = pickedTime.format(context);
        _formKey2.currentState!.validate();
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm(); // 24-hour format
    return format.format(dt);
  }

  String getDayOfMonthSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  void _printVisitingDateTime() {
    print('selectedDate $selectedDate');
    print('selected Time $slot_time');
    if (selectedDate != null && _selectedTime != null) {
      //   final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final formattedTime = _formatTimeOfDay(_selectedTime!);
      visitingDateTime = '$visiteddate $formattedTime';
      print('SlotselectedDateTime: $visitingDateTime');
      print('formattedTime: $formattedTime');

      DateTime visitslotDatetime =
          DateFormat('yyyy-MM-dd HH:mm').parse(visitingDateTime!);
      //  DateTime VisitslotDateTime = VisitslotDateTime.subtract(const Duration(hours: 1));

      print('Visiting Date: $visitingDateTime');
      print('Visitslot DateTime:1230 $visitslotDatetime');

      VisitslotDateTime = visitslotDatetime.subtract(const Duration(hours: 2));

      print('Visiting Date:1234 $VisitslotDateTime');

      formattedDateapi =
          '${DateFormat('d').format(selectedDate!)}${getDayOfMonthSuffix(selectedDate!.day)} ${DateFormat('MMMM').format(selectedDate!)}';
      //  String formattedTime_ = DateFormat('h:mm a').format(selectedDate!);

      print('Date: $formattedDateapi');
      //    print('Time: $formattedTime_');
    } else {
      print('Please select both date and time.');
    }
  }
}

