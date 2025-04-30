import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hairfixingzone/BranchModel.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/models/customer_enquiry_model.dart';
import 'package:hairfixingzone/screens/customer_enquiry/add_customer_enquiry.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CustomerEnquiries extends StatefulWidget {
  final int userId;
  final int? branchId;
  final BranchModel agentBranch;
  const CustomerEnquiries({
    super.key,
    required this.agentBranch,
    required this.userId,
    this.branchId,
  });

  @override
  State<CustomerEnquiries> createState() => _CustomerEnquiriesState();
}

class _CustomerEnquiriesState extends State<CustomerEnquiries> {
  final TextEditingController _fromDateController = TextEditingController();
  DateTime? selectedEnquiryDate;

  late Future<List<CustomerEnquiryModel>> futureEnquiries;
  bool isFilterApplied = false;

  @override
  void initState() {
    super.initState();
    futureEnquiries = getEnquiries();
  }

  @override
  void dispose() {
    _fromDateController.dispose();
    super.dispose();
  }

  List<dynamic> parseEnquiryCreatedDate(DateTime? createdDate) {
    if (createdDate == null) return [];
    print(
        'dateFormate: ${createdDate.day} - ${DateFormat.MMM().format(createdDate)} - ${createdDate.year}');
    //         int ,       String ,                           int
    return [
      createdDate.day,
      DateFormat.MMM().format(createdDate),
      createdDate.year
    ];
  }

  Future<List<CustomerEnquiryModel>> getEnquiries(
      {String? selectedDate}) async {
    try {
      final isConneted = await CommonUtils.checkInternetConnectivity();
      if (!isConneted) {
        CommonUtils.showCustomToastMessageLong(
            'Please check your internet connection', context, 0, 2);

        throw Exception('No internet connection');
      }
      final apiUrl = '$baseUrl$getCustomerEnquiries';
      final requestBody = jsonEncode({
        "userId": widget.userId,
        "branchId": widget.branchId,
        "fromDate": selectedDate,
        "toDate": selectedDate,
        /* "fromDate": selectedDate ??
            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").format(DateTime.now()),
        "toDate": selectedDate ??
            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").format(DateTime.now()), */
      });

      print('getEnquiries: $apiUrl');
      print('getEnquiries: $requestBody');

      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          List<dynamic>? enquiries = response['listResult'];
          if (enquiries == null || enquiries.isEmpty) {
            return throw Exception('No Customer Enquiries Found');
          }
          List<CustomerEnquiryModel> result =
              enquiries.map((e) => CustomerEnquiryModel.fromJson(e)).toList();
          return result;
        }
      }
      throw Exception('Failed to load Customer Enquiries');
    } catch (e) {
      print('Catch: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Column(
              children: [
                IntrinsicHeight(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFFFFFFF),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Image.network(
                            widget.agentBranch.imageName!.isNotEmpty
                                ? widget.agentBranch.imageName!
                                : 'https://example.com/placeholder-image.jpg',
                            fit: BoxFit.cover,
                            height:
                                MediaQuery.of(context).size.height / 5.5 / 2,
                            width: MediaQuery.of(context).size.width / 3.2,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/hairfixing_logo.png',
                                fit: BoxFit.cover,
                                height:
                                    MediaQuery.of(context).size.height / 4 / 2,
                                width: MediaQuery.of(context).size.width / 3.2,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.agentBranch.name,
                                style: const TextStyle(
                                  color: Color(0xFF0f75bc),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                widget.agentBranch.address,
                                style: CommonStyles.txSty_12b_f5,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //MARK: Date Picker
                TextFormField(
                  controller: _fromDateController,
                  keyboardType: TextInputType.visiblePassword,
                  onTap: () async {
                    showDatePickerForEnquiry(context);
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                        top: 15, bottom: 10, left: 15, right: 15),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFF0f75bc),
                      ),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    hintText: 'Select Dates',
                    counterText: "",
                    hintStyle: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: isFilterApplied
                        ? IconButton(
                            icon: const Icon(Icons.clear_outlined),
                            onPressed: () async {
                              setState(() {
                                _fromDateController.clear();
                                selectedEnquiryDate = null;
                                futureEnquiries = getEnquiries().whenComplete(
                                  () {
                                    setState(() {
                                      isFilterApplied = false;
                                    });
                                  },
                                );
                              });
                            },
                          )
                        : null,
                  ),
                  //  validator: validator,
                ),
              ],
            ),
            const SizedBox(height: 10),
//MARK: Enquiries List
            Expanded(
              child: customerEnquiryTemplate(),
            ),
            const SizedBox(height: 10),
            addEnquiryBtn(context),
          ],
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xffe2f0fd),
      title: const Text(
        'Customer Enquiry',
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

  Future<void> showDatePickerForEnquiry(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = selectedEnquiryDate ?? currentDate;

    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2000), // Allow dates starting from the year 2000
      lastDate:
          DateTime(currentDate.year + 1, currentDate.month, currentDate.day),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      print('pickedDay.toString(): ${pickedDay.toString()}');
      setState(() {
        selectedEnquiryDate = pickedDay;
        _fromDateController.text = DateFormat('dd-MM-yyyy').format(pickedDay);
        String formattedDate =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS").format(pickedDay);
        futureEnquiries =
            getEnquiries(selectedDate: formattedDate).whenComplete(
          () {
            setState(() {
              isFilterApplied = true;
            });
          },
        );
      });
    }
  }

  Padding addEnquiryBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              buttonText: 'Add Customer Enquiry',
              color: CommonUtils.primaryTextColor,
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddCustomerEnquiry(
                      branchId: widget.branchId,
                      userId: widget.userId,
                    ),
                  ),
                );
                if (result) {
                  setState(() {
                    _fromDateController.clear();
                    selectedEnquiryDate = null;
                    futureEnquiries = getEnquiries().whenComplete(
                      () {
                        setState(() {
                          isFilterApplied = false;
                        });
                      },
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget enquiryItem(CustomerEnquiryModel enquiry, List<dynamic> dateValues) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddCustomerEnquiry(
              branchId: widget.branchId,
              userId: widget.userId,
              enquiry: enquiry,
            ),
          ),
        );
        if (result) {
          setState(() {
            _fromDateController.clear();
            selectedEnquiryDate = null;
            futureEnquiries = getEnquiries().whenComplete(
              () {
                setState(() {
                  isFilterApplied = false;
                });
              },
            );
          });
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xffe2f0fd),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height / 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${dateValues[1]}',
                        style: CommonUtils.txSty_18p_f7,
                      ),
                      Text(
                        '${dateValues[0]}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0f75bc),
                        ),
                      ),
                      Text(
                        '${dateValues[2]}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0f75bc),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(
                  color: CommonUtils.primaryTextColor,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 7,
                                        child: Text(
                                          '${enquiry.customerName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0f75bc),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          '${enquiry.mobileNumber}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0f75bc),
                                          ),
                                        ),
                                      ),

                                      /* RichText(
                                        text: TextSpan(
                                          text: '${enquiry.mobileNumber}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF0f75bc),
                                            // decoration: TextDecoration.underline,
                                            decorationColor: Color(0xFF0f75bc),
                                          ),
                                        ),
                                      ), */
                                    ],
                                  ),
                                  const SizedBox(height: 2.0),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          enquiry.email ?? '',
                                          style: CommonStyles.txSty_16b6_fb,
                                          softWrap: true,
                                          maxLines: null,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(Icons.edit),
                                    ],
                                  ),
                                  /*  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          enquiry.email ?? '',
                                          style: CommonStyles.txSty_16b6_fb,
                                          softWrap: true,
                                          maxLines: null,
                                        ),
                                      ),
                                      /* GestureDetector(
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 0, 5, 0),
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                          ),
                                        ),
                                        onTap: () {},
                                      ), */
                                    ],
                                  ), */
                                  const SizedBox(height: 5.0),
                                  Text(enquiry.remarks ?? '',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: CommonStyles.txSty_14blu_f5),
                                ],
                              ),
                            ),
                            /* Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: RichText(
                                          text: TextSpan(
                                            text: '${enquiry.mobileNumber}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0f75bc),
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Color(0xFF0f75bc),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5.0,
                                      ),
                                      GestureDetector(
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 0, 0, 0),
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                          ),
                                        ),
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3.0,
                                  ),
                                  /* Text('.gender',
                                      style: CommonStyles.txSty_16b_fb),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_border_outlined,
                                            size: 13,
                                            color: CommonStyles.statusGreenText,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8.0),
                                            child: Text(
                                              '{.rating}',
                                              style: CommonStyles.txSty_14g_f5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ), */
                                ],
                              ),
                            ),
                         */
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FutureBuilder<List<CustomerEnquiryModel>> customerEnquiryTemplate() {
    return FutureBuilder(
      future: futureEnquiries,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              textAlign: TextAlign.center,
              snapshot.error.toString().replaceFirst('Exception: ', ''),
            ),
          );
        }
        final result = snapshot.data as List<CustomerEnquiryModel>;
        if (result.isEmpty) {
          return const Center(
            child: Text(
              textAlign: TextAlign.center,
              'No Customer Enquiries Found',
            ),
          );
        }
        return ListView.separated(
          itemCount: result.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final dateValues =
                parseEnquiryCreatedDate(result[index].createdDate);
            return enquiryItem(result[index], dateValues);
          },
        );
      },
    );
  }
}
