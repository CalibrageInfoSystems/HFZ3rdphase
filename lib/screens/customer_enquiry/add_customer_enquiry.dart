import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/Common/custome_form_field.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/models/customer_enquiry_model.dart';
import 'package:http/http.dart' as http;

class AddCustomerEnquiry extends StatefulWidget {
  final int userId;
  final int? branchId;
  final CustomerEnquiryModel? enquiry;

  const AddCustomerEnquiry({
    super.key,
    required this.userId,
    required this.branchId,
    this.enquiry,
  });

  @override
  State<AddCustomerEnquiry> createState() => _AddCustomerEnquiryState();
}

class _AddCustomerEnquiryState extends State<AddCustomerEnquiry> {
  final formKey = GlobalKey<FormState>();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  bool _customerNameError = false;
  String? _customerNameErrorMsg;
  bool isCustomerNameValidate = false;

  bool _mobileError = false;
  String? _mobileErrorMsg;
  bool isMobileValidate = false;

  bool _emailError = false;
  String? _emailErrorMsg;
  bool isEmailValidate = false;

  int? customerEnquiryId;

  @override
  void initState() {
    super.initState();
    print('www: ${widget.userId}');
    print('www: ${widget.branchId}');

    if (widget.enquiry != null) {
      customerNameController.text = widget.enquiry!.customerName ?? '';
      mobileController.text = widget.enquiry!.mobileNumber ?? '';
      emailController.text = widget.enquiry!.email ?? '';
      remarksController.text = widget.enquiry!.remarks ?? '';
      customerEnquiryId = widget.enquiry!.id;
    }
  }

  @override
  void dispose() {
    customerNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                customerNamefield(),
                const SizedBox(height: 10),
                mobileField(),
                const SizedBox(height: 10),
                emailfield(),
                const SizedBox(height: 10),
                remarksfield(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText:
                            widget.enquiry != null ? 'Update' : 'Submit',
                        color: CommonUtils.primaryTextColor,
                        onPressed: validateForm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xffe2f0fd),
      title: Text(
        widget.enquiry != null
            ? 'Update Customer Enquiry'
            : 'Add Customer Enquiry',
        style: TextStyle(
          color: Color(0xFF0f75bc),
          fontSize: 16.0,
          fontFamily: "Outfit",
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: CommonUtils.primaryTextColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  CustomeFormField customerNamefield() {
    return CustomeFormField(
      label: 'Customer Name',
      controller: customerNameController,
      errorText: _customerNameError ? _customerNameErrorMsg : null,
      validator: validateProductName,
      onChanged: (value) {
        setState(() {
          if (value.startsWith(' ')) {
            customerNameController.value = TextEditingValue(
              text: value.trimLeft(),
              selection:
                  TextSelection.collapsed(offset: value.trimLeft().length),
            );
          }
          _customerNameError = false;
        });
      },
      maxLength: 50,
      keyboardType: TextInputType.name,
    );
  }

  String? validateProductName(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _customerNameError = true;
        _customerNameErrorMsg = 'Please Enter Customer Name';
      });
      isCustomerNameValidate = false;
      return null;
    }
    isCustomerNameValidate = true;
    return null;
  }

  CustomeFormField mobileField() {
    return CustomeFormField(
      label: 'Mobile Number',
      controller: mobileController,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      validator: validateMobileNumber,
      errorText: _mobileError ? _mobileErrorMsg : null,
      onChanged: (value) {
        setState(() {
          if (value.startsWith(' ')) {
            mobileController.value = TextEditingValue(
              text: value.trimLeft(),
              selection:
                  TextSelection.collapsed(offset: value.trimLeft().length),
            );
          }
          _mobileError = false;
        });
      },
    );
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _mobileError = true;
        _mobileErrorMsg = 'Please Enter Mobile Number';
      });
      isMobileValidate = false;
      return null;
    }

    if (value.length < 10) {
      setState(() {
        _mobileError = true;
        _mobileErrorMsg = 'Please Enter Valid Mobile Number';
      });
      isMobileValidate = false;
      return null;
    }

    isMobileValidate = true;

    return null;
  }

  CustomeFormField emailfield() {
    return CustomeFormField(
      label: 'Email',
      controller: emailController,
      maxLength: 50,
      isMandatory: false,
      keyboardType: TextInputType.emailAddress,
      errorText: _emailError ? _emailErrorMsg : null,
      onChanged: (value) {
        setState(() {
          _emailError = false;
        });
      },
      validator: validateEmail,
    );
  }

  CustomeFormField remarksfield() {
    return CustomeFormField(
      label: 'Remarks',
      controller: remarksController,
      maxLines: 3,
      maxLength: 200,
      isMandatory: false,
    );
  }

  bool isRequestProcessing = false;

  Future<void> validateForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final isConneted = await CommonUtils.checkInternetConnectivity();
    if (!isConneted) {
      CommonUtils.showCustomToastMessageLong(
          'Please check your internet connection', context, 0, 2);

      throw Exception('No internet connection');
    }

    print(
        'validateForm: $isCustomerNameValidate && $isEmailValidate && $isMobileValidate');

    if (formKey.currentState!.validate() &&
        isCustomerNameValidate &&
        isEmailValidate &&
        isMobileValidate) {
      setState(() {
        isRequestProcessing = true;
      });

      print('validateForm: Form is valid: 33333');
      postCustomerEnquiry();
      /* formKey.currentState!.reset();
      customerNameController.clear();
      mobileController.clear();
      emailController.clear();
      remarksController.clear(); */
    }
  }

  Future<void> postCustomerEnquiry() async {
    try {
      final connection = await CommonUtils.checkInternetConnectivity();
      if (!connection) {
        CommonUtils.showCustomToastMessageLong(
            'No Internet Connection', context, 1, 2);
        throw Exception('No Internet Connection');
      }

      final apiUrl = Uri.parse(baseUrl + addUpdateCustomerEnquiry);
      final requestBody = jsonEncode({
        "id": customerEnquiryId,
        "name": customerNameController.text.trim(),
        "mobileNumber": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "branchId": widget.branchId,
        "isActive": true,
        "remarks": remarksController.text.trim(),
        "createdByUserId": widget.userId,
        "createdDate": DateTime.now().toIso8601String(),
        "updatedByUserId": widget.userId,
        "updatedDate": DateTime.now().toIso8601String(),
      });

      final jsonResponse = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('www: $apiUrl');
      print('www: $requestBody');
      print('www: ${jsonResponse.body}');
      setState(() {
        isRequestProcessing = false;
      });
      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);
        if (response['isSuccess'] == true) {
          formKey.currentState!.reset();
          customerNameController.clear();
          mobileController.clear();
          emailController.clear();
          remarksController.clear();
          CommonUtils.showCustomToastMessageLong(
              response['statusMessage'], context, 0, 2);
          Navigator.pop(context, true);
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Failed to add customer enquiry', context, 1, 2);
        }
      } else {
        CommonUtils.showCustomToastMessageLong(
            jsonResponse.body, context, 1, 2);
        throw Exception('Failed to add customer enquiry');
      }
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      rethrow;
    }
  }

  String? validateEmail(String? value) {
    print('validateEmail: $value');
    if (value != null &&
        value.isNotEmpty &&
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
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
}
