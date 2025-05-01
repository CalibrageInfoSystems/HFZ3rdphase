import 'dart:convert';
import 'dart:ffi';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/AddConsulationscreen.dart';
import 'package:hairfixingzone/AgentBranchModel.dart';
import 'package:hairfixingzone/BranchModel.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/common_widgets.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/CustomCalendarDialog.dart';
import 'package:hairfixingzone/MyAppointment_Model.dart';

import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/models/payment_types_model.dart';
import 'package:hairfixingzone/models/technician_model.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'AgentBranchesModel.dart';
import 'Consultation.dart';

class ViewConsulationlistScreen extends StatefulWidget {
  final int branchid;
  final String fromdate;
  final String todate;
  final AgentBranchModel agent;
  final int userid;

  const ViewConsulationlistScreen(
      {super.key,
      required this.branchid,
      required this.fromdate,
      required this.todate,
      required this.agent,
      required this.userid});

  @override
  State<ViewConsulationlistScreen> createState() => _ViewConsultationState();
}

class _ViewConsultationState extends State<ViewConsulationlistScreen> {
  List<Consultation> consultationslist = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _fromToDatesController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  DateTime? selectedDate;
  String? month;
  String? date;
  String? year;
  late Future<List<Consultation>> consultationData;

  int selectedPaymentOption = -1;
  int? selectedTechnicianOption;
  int? selectedTechnicianId;
  int? apiPaymentMode;
  bool isPaymentValidate = false;
  bool isPaymentModeSelected = false;
  bool _billingAmountError = false;
  String? _billingAmountErrorMsg;
  bool isBillingAmountValidate = false;

  bool isTechnicianValidate = false;
  bool isTechnicianSelected = false;

  bool isFreeService = true;
  String? selectedPaymentMode;
  late Future<List<PaymentTypesModel>> futurePaymentTypes;
  late Future<List<TechniciansModel>> futureTechnicians;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(const Duration(days: 14));
    endDate = DateTime.now();
    _fromToDatesController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());
    futurePaymentTypes = fetchPaymentTypes();
    // futureTechnicians = fetchTechnicians();
    print(
        'branchid ${widget.branchid} fromdate${widget.fromdate} todate ${widget.todate}');
    consultationData = getviewconsulationlist(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  Future<List<PaymentTypesModel>> fetchPaymentTypes() async {
    try {
      final connection = await CommonUtils.checkInternetConnectivity();
      if (!connection) {
        CommonUtils.showCustomToastMessageLong(
            'Please check your internet connection', context, 1, 4);
        return [];
      }
      final apiUrl = Uri.parse(baseUrl + getPaymentMode);
      final jsonResponse = await http.get(apiUrl);
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['listResult'] != null) {
          List<dynamic> paymentTypes = response['listResult'];
          return paymentTypes
              .map((paymentType) => PaymentTypesModel.fromJson(paymentType))
              .toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List<TechniciansModel>> fetchTechnicians({
    required int? branchId,
    required String? date,
    required String? slot,
  }) async {
    try {
      final apiUrl = Uri.parse(baseUrl + getTechnicians);
      final requestBody = jsonEncode({
        "branchId": branchId,
        "date": date,
        "slot": slot,
      });
      final jsonResponse = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      print('fetchTechnicianOptions: ${baseUrl + getTechnicians}');
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['listResult'] != null) {
          List<dynamic> techniciansList = response['listResult'];
          return techniciansList
              .map((technician) => TechniciansModel.fromJson(technician))
              .toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List<Consultation>> getviewconsulationlist(
      String fromdate, String todate) async {
    // const String apiUrl =
    //     'http://182.18.157.215/SaloonApp/API/api/Consultation/GetConsultationsByBranchId';
    String apiUrl = baseUrl + getconsulationbyranchid;
    print('getconsulationapi:$apiUrl');
    final Map<String, dynamic> requestObject = {
      "userId": widget.userid, // userId
      "branchId": widget.agent.id, //widget.branchid,
      "fromDate": fromdate, //widget.fromdate,
      "toDate": todate,
      "isActive": true, //widget.todate
    };
    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestObject),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData["isSuccess"]) {
          List<dynamic> jsonList = responseData["listResult"];
          final dynamic listResult = responseData["listResult"];
          if (listResult != null && listResult is List<dynamic>) {
            List<Consultation> consultations =
                jsonList.map((e) => Consultation.fromJson(e)).toList();

            setState(() {
              consultationslist = consultations;
            });
            return consultations;
          } else {
            print("ListResult is null or not a List<dynamic>");
          }
        } else {
          print("ListResult is null");
        }
      } else {}
    } catch (e) {
      print("Exception: $e");
    }
    return [];
  }

  String formateDate(String date) {
    try {
      DateFormat inputFormat = DateFormat('dd/MM/yyyy');

      DateTime dateTime = inputFormat.parse(date);

      DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      String formattedDateStr = outputFormat.format(dateTime);
      return formattedDateStr;
    } catch (e) {
      print('Error parsing date: $e');
      rethrow;
    }
  }

  final config = CalendarDatePicker2WithActionButtonsConfig(
    firstDate: DateTime(2012),
    lastDate: DateTime(2030),
    dayTextStyle: CommonStyles.dayTextStyle,
    calendarType: CalendarDatePicker2Type.range,
    // selectedDayHighlightColor: Colors.purple[800],
    closeDialogOnCancelTapped: true,
    firstDayOfWeek: 1,
    weekdayLabelTextStyle: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    ),
    controlsTextStyle: const TextStyle(
      color: Color.fromARGB(255, 224, 18, 18),
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),
    centerAlignModePicker: true,
    customModePickerIcon: const SizedBox(),
    // ensure SizedBox is constant
    selectedDayTextStyle:
        CommonStyles.dayTextStyle.copyWith(color: Colors.white),
    // dayTextStylePredicate: ({required DateTime date}) {
    //   TextStyle? textStyle;
    //   if (DateUtils.isSameDay(date, DateTime(2021, 1, 25))) {
    //     textStyle = anniversaryTextStyle;
    //   }
    //   return textStyle;
    // },
  );

  void showTooltip(BuildContext context, String message, GlobalKey toolTipKey) {
    final renderBox =
        toolTipKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final target = renderBox.localToGlobal(
            renderBox.size.bottomLeft(Offset.zero),
            ancestor: overlay) +
        const Offset(-10, 0);

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: target.dx,
        top: target.dy,
        child: Material(
          color: Colors.transparent,
          child: TooltipOverlay(message: message),
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CommonStyles.whiteColor,
        appBar: _appBar(context),
        body: Container(
          color: Colors.white, // Set the background color to white
          child: Column(
            children: [
              // branch and dates
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Container(
                        //  height: MediaQuery.of(context).size.height / 6,
                        width: MediaQuery.of(context).size.width,
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Color(0xFF662e91), width: 1.0),
                        //   borderRadius: BorderRadius.circular(10.0),
                        // ),
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
                            //  color: const Color(0xFF8d97e2), // Add your desired border color here
                            width: 1.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(
                              10.0), // Optional: Add border radius if needed
                        ),
                        child: Row(
                          children: [
                            Container(
                              // padding: const EdgeInsets.all(10),
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
                                  //  color: const Color(0xFF8d97e2), // Add your desired border color here
                                  width: 1.0, // Set the border width
                                ),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Optional: Add border radius if needed
                              ),
                              // width: MediaQuery.of(context).size.width / 4,
                              child: Image.network(
                                widget.agent.imageName!.isNotEmpty
                                    ? widget.agent.imageName!
                                    : 'https://example.com/placeholder-image.jpg',
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height /
                                    5.5 /
                                    2,
                                width: MediaQuery.of(context).size.width / 3.2,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/hairfixing_logo.png', // Path to your PNG placeholder image
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height /
                                        4 /
                                        2,
                                    width:
                                        MediaQuery.of(context).size.width / 3.2,
                                  );
                                },
                              ),
                              // child: Image.asset(
                              //   'assets/top_image.png',
                              //   fit: BoxFit.cover,
                              //   height: MediaQuery.of(context).size.height / 4 / 2,
                              //   width: MediaQuery.of(context).size.width / 2.8,
                              // )
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: MediaQuery.of(context).size.width / 2,
                              alignment: Alignment
                                  .centerLeft, // width: MediaQuery.of(context).size.width / 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${widget.agent.name}',
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
                                    '${widget.agent.address}',
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
                      controller: _fromToDatesController,
                      keyboardType: TextInputType.visiblePassword,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(
                            FocusNode()); // to prevent the keyboard from appearing
                        /* final values =
                            await showCustomCalendarDialog(context, config);
                        if (values != null) {
                          setState(() {
                            //           startDate = s;
                            //           endDate = e;
                            //           _fromToDatesController.text =
                            //               '${startDate != null ? DateFormat("dd/MM/yyyy").format(startDate!) : '-'} / ${endDate != null ? DateFormat("dd/MM/yyyy").format(endDate!) : '-'}';
                            //           ConsultationData =

                            selectedDate =
                                _getValueText(config.calendarType, values);
                            _fromToDatesController.text =
                                '${selectedDate![0]} - ${selectedDate![1]}';
                            String apiFromDate = formateDate(selectedDate![0]);
                            String apiToDate = formateDate(selectedDate![1]);
                            ConsultationData =
                            // provider.getDisplayDate =
                            //     '${selectedDate![0]}  to  ${selectedDate![1]}';
                            // provider.getApiFromDate = selectedDate![0];
                            // provider.getApiToDate = selectedDate![1];
                          });
                        } */

                        _selectDate(context);
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
                          // borderSide: const BorderSide(
                          //   color: CommonUtils.primaryTextColor,
                          // ),
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
                      ),
                      //  validator: validatePassword,
                    ),
                  ],
                ),
              ),

              FutureBuilder(
                future: consultationData,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  } else {
                    List<Consultation> data = snapshot.data!;
                    if (data.isEmpty) {
                      return SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: const Center(
                            child: Text('No Consultation Found'),
                          ));
                    } else {
                      return Expanded(
                        child: ListView.builder(
                            // shrinkWrap: true,
                            itemCount: consultationslist.isEmpty
                                ? 1
                                : consultationslist.length,
                            itemBuilder: (context, index) {
                              DateTime createdDateTime =
                                  consultationslist[index].visitingDate!;
                              /* DateTime.parse(
                              ); */
                              final GlobalKey mobilenumber = GlobalKey();

                              month = DateFormat('MMM').format(createdDateTime);
                              date = DateFormat('dd').format(createdDateTime);
                              year = DateFormat('yyyy').format(createdDateTime);
                              print('month: $month, Date: $date, Year: $year');
                              // if (consultationslist.length > 0) {
                              futureTechnicians = fetchTechnicians(
                                branchId: consultationslist[index].branchId,
                                date: formatVisitingDateToISO(
                                    consultationslist[index].visitingDate),
                                slot: formatVisitingTime(
                                    consultationslist[index].visitingDate),
                              );
                              return consultationCard(
                                  context, index, mobilenumber);
                            }),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ));
  }

  String? formatVisitingDateToISO(DateTime? visitingDate) {
    if (visitingDate == null) {
      return null;
    }

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(visitingDate);
      return formattedDate;
    } catch (e) {
      return null;
    }
  }

  String? formatVisitingTime(DateTime? visitingDate) {
    if (visitingDate == null) {
      return null;
    }

    try {
      String formattedTime = DateFormat('h:mm').format(visitingDate);
      return formattedTime;
    } catch (e) {
      print('Error formatting time: $e');
      return null;
    }
  }

  Padding consultationCard(BuildContext context, int index,
      GlobalKey<State<StatefulWidget>> mobilenumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: IntrinsicHeight(
            child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xffe2f0fd),
                Color(0xffe2f0fd),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$month',
                    style: CommonUtils.txSty_18p_f7,
                  ),
                  Text(
                    '$date',
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0f75bc),
                    ),
                  ),
                  Text(
                    '$year',
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0f75bc),
                    ),
                  ),
                ],
              ),
              const VerticalDivider(
                color: CommonUtils.primaryTextColor,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${formatVisitingDate2(consultationslist[index].visitingDate)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 2.0,
                            ),
                            Text(
                              '${consultationslist[index].consultationName}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    makePhoneCall(
                                        'tel:+91${consultationslist[index].phoneNumber}');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text:
                                          consultationslist[index].phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Outfit",
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF0f75bc),
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(
                                            0xFF0f75bc), // Change this to your desired underline color
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  key: mobilenumber,
                                  child: const Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: Colors.black,
                                  ),
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: consultationslist[index]
                                            .phoneNumber!));
                                    showTooltip(
                                        context, "Copied", mobilenumber);
                                  },
                                ),
                              ],
                            ),
                            if (consultationslist[index].technicianName !=
                                null) ...[
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Text(
                                    'Technician: ',
                                    style: CommonStyles.txSty_16blu_f5.copyWith(
                                      fontSize: 14,
                                      fontFamily: "Outfit",
                                    ),
                                  ),
                                  Text(
                                    '${consultationslist[index].technicianName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Outfit",
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5f5f5f),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (consultationslist[index].paymentType != null)
                              Column(
                                children: [
                                  const SizedBox(
                                    height: 2.0,
                                  ),
                                  Text(
                                      consultationslist[index].paymentType ??
                                          '',
                                      style: CommonStyles.txSty_16b_fb),
                                ],
                              )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            statusBasedBgById(
                                consultationslist[index].statusTypeId,
                                consultationslist[index].status),
                            const SizedBox(height: 5.0),
                            Text(
                              '${consultationslist[index].gender}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5f5f5f),
                              ),
                            ),
                            Text(
                              '${consultationslist[index].email}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5f5f5f),
                              ),
                            ),
                            if (consultationslist[index].price != null) ...[
                              const SizedBox(height: 5.0),
                              Text(
                                '₹${consultationslist[index].price}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF5f5f5f),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Flexible(
                    child: Visibility(
                      visible: (consultationslist[index].remarks != null &&
                          consultationslist[index].remarks!.isNotEmpty),
                      child: RichText(
                        text: TextSpan(
                          text: 'Remark : ',
                          style: CommonStyles.txSty_14blu_f5,
                          children: <TextSpan>[
                            TextSpan(
                              text: consultationslist[index].remarks ?? '',
                              style: const TextStyle(
                                color: Color(0xFF5f5f5f),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //MARK: Status Btn
                  if (consultationslist[index].statusTypeId != 28 &&
                      consultationslist[index].statusTypeId != 18 &&
                      consultationslist[index].statusTypeId != 17 &&
                      consultationslist[index].statusTypeId != 36) ...[
                    (DateTime.now()
                            .isAfter(consultationslist[index].visitingDate!))
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  CommonWidgets.customCancelDialog(
                                    context,
                                    message:
                                        'Are You Sure You Want to Mark as Not Visited ${consultationslist[index].consultationName} Consultation?',
                                    onConfirm: () {
                                      customConsultationCall(
                                          consultationslist[index], 28);
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: CommonStyles.statusRedText,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/not_visted.svg',
                                        width: 12,
                                        color: CommonStyles.statusorangeText,
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        'Not visited',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CommonStyles.statusorangeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  // closePopUp(context, consultationslist[index]);
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.zero,
                                        contentPadding: EdgeInsets.zero,
                                        titlePadding: EdgeInsets.zero,
                                        content: CloseConsulationCard(
                                          data: consultationslist[index],
                                          futurePaymentTypes:
                                              futurePaymentTypes,
                                          futureTechnicians: futureTechnicians,
                                          /*  onSubmit: () {
                                            print('qqq: 1111111111111');
                                            Navigator.of(context).pop();
                                            customConsultationCall(
                                                consultationslist[index], 17);
                                          }, */
                                          onSubmit: (paymentMode, billingAmount,
                                              technicianId) {
                                            Navigator.of(context).pop();
                                            selectedTechnicianId = technicianId;
                                            _priceController.text =
                                                billingAmount.toString();
                                            apiPaymentMode = paymentMode;

                                            customConsultationCall(
                                                consultationslist[index], 17);
                                          },
                                        ),
                                      );
                                    },
                                  );
                                  /*  CloseConsulationCard(
                                    data: consultationslist[index],
                                    onSubmit: () {
                                      Navigator.of(context).pop();
                                      customConsultationCall(
                                          consultationslist[index], 17);
                                    },
                                  ); */
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: CommonStyles
                                          .statusRedText, // Use a different color for differentiation
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/close.svg',
                                        width: 12,
                                        color: CommonStyles.statusorangeText,
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        'Close',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CommonStyles.statusorangeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        //MARK: Reschedule
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              customStatusBtn(
                                index,
                                context,
                                statusIcon: 'assets/calendar-_3_.svg',
                                statusText: 'Reschedule',
                                btnThemeColor: CommonStyles.primaryTextColor,
                                onTap: () async {
                                  if (canRescheduleAppointment(
                                      consultationslist[index].visitingDate)) {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddConsulationscreen(
                                                agentId: widget.userid,
                                                branch: widget.agent,
                                                screenForReschedule: true,
                                                consultation:
                                                    consultationslist[index]),
                                      ),
                                    );

                                    if (result == true) {
                                      final formattedDate =
                                          DateFormat('yyyy-MM-dd').format(
                                              selectedDate ?? DateTime.now());

                                      setState(() {
                                        consultationData =
                                            getviewconsulationlist(
                                                formattedDate, formattedDate);
                                      });
                                    }
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                      'The Request Should Not be Rescheduled Within 15 minutes Before the Slot',
                                      context,
                                      0,
                                      2,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              customStatusBtn(
                                index,
                                context,
                                statusIcon: 'assets/calendar-xmark.svg',
                                statusText: 'Cancel',
                                btnThemeColor: CommonStyles.statusRedText,
                                onTap: () {
                                  if (canRescheduleAppointment(
                                      consultationslist[index].visitingDate)) {
                                    CommonWidgets.customCancelDialog(
                                      context,
                                      message:
                                          'Are You Sure You Want to Cancel this ${consultationslist[index].consultationName} Consultation?',
                                      onConfirm: () {
                                        cancelConsultation(
                                            consultationslist[index]);
                                      },
                                    );
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                      'The Request Should Not be Cancelled Within 15 minutes Before the Slot',
                                      context,
                                      0,
                                      2,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                  ],
                  if (consultationslist[index].statusTypeId != 17 &&
                      consultationslist[index].statusTypeId != 28 &&
                      consultationslist[index].statusTypeId != 36) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.start,
                      children: [
                        if (consultationslist[index].statusTypeId != 34)
                          customStatusBtn(
                            index,
                            context,
                            statusIcon: 'assets/calendar-_3_.svg',
                            statusText: 'Follow Up',
                            btnThemeColor: CommonStyles.followUpStatusColor,
                            onTap: () {
                              CommonWidgets.customCancelDialog(
                                context,
                                message:
                                    'You Want to Follow up ${consultationslist[index].consultationName} Consultation?',
                                onConfirm: () {
                                  customConsultationCall(
                                      consultationslist[index], 34);
                                },
                              );
                            },
                          ),
                        if (consultationslist[index].statusTypeId != 35)
                          customStatusBtn(
                            index,
                            context,
                            statusIcon: 'assets/calendar-xmark.svg',
                            statusText: 'Order Placed',
                            btnThemeColor: CommonStyles.orderPlacedStatusColor,
                            onTap: () {
                              CommonWidgets.customCancelDialog(
                                context,
                                message:
                                    'You Want to Order Place ${consultationslist[index].consultationName} Consultation?',
                                onConfirm: () {
                                  customConsultationCall(
                                      consultationslist[index], 35);
                                },
                              );
                            },
                          ),
                        if (consultationslist[index].statusTypeId != 36)
                          customStatusBtn(
                            index,
                            context,
                            statusIcon: 'assets/calendar-xmark.svg',
                            statusText: 'Not Interested',
                            btnThemeColor:
                                CommonStyles.notInterestedStatusColor,
                            onTap: () {
                              CommonWidgets.customCancelDialog(
                                context,
                                message:
                                    'Are You Sure You are Not Interested ${consultationslist[index].consultationName} Consultation?',
                                onConfirm: () {
                                  customConsultationCall(
                                      consultationslist[index], 36);
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              )),
            ],
          ),
        )),
      ),
    );
  }

  GestureDetector customStatusBtn(int index, BuildContext context,
      {void Function()? onTap,
      String? statusIcon,
      required String statusText,
      required Color btnThemeColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            // color: CommonStyles.statusRedText,
            color: btnThemeColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              statusIcon ?? 'assets/calendar-xmark.svg',
              width: 13,
              color: btnThemeColor,
            ),
            Text(
              ' $statusText',
              style: TextStyle(
                fontSize: 15,
                color: btnThemeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*  void closePopUp(BuildContext context, Consultation data) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: const Color(0xffffffff),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Expanded(
                              child: Center(
                            child: Text(
                              'Billing Details',
                              style: TextStyle(
                                color: CommonStyles.primaryTextColor,
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )),
                          GestureDetector(
                            onTap: () {
                              selectedPaymentOption = -1;
                              _priceController.clear();
                              Navigator.of(context).pop();
                            },
                            child: const CircleAvatar(
                              backgroundColor: CommonStyles.primaryColor,
                              radius: 12,
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  color: CommonStyles.primaryTextColor,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Form(
                            key: _formKey,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 8),
                                  customRow(
                                      data: data.consultationName,
                                      title: 'Customer Name'),

                                  const SizedBox(height: 5),
                                  customRow(
                                      /* data: DateFormat('dd-MM-yyyy')
                                          .format(DateTime.parse(data.visitingDate)), */
                                      data: formatDateTime(data.visitingDate),
                                      title: 'Slot Time'),

                                  /* const SizedBox(height: 5),
                                  customRow(
                                      data: data.purposeOfVisit,
                                      title: 'Purpose of Visit'), */

                                  /* if (data.technicianName != null) ...[
                                    const SizedBox(height: 5),
                                    customRow(
                                        data: data.technicianName!,
                                        title: 'Technician'),
                                  ], */
                                  const SizedBox(height: 10),
                                  //MARK: Payment Mode
                                  const Row(
                                    children: [
                                      Text(
                                        'Payment Mode ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  paymentModeDropDown(context, setState),
                                  if (isPaymentModeSelected)
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 5),
                                          child: Text(
                                            'Please Select Payment Mode',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 175, 15, 4),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  //MARK: Technicians
                                  // if (data.technicianName == null)
                                  ...[
                                    const SizedBox(height: 10.0),
                                    const Row(
                                      children: [
                                        Text(
                                          'Technician ',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    technicianDropDown(context, setState),
                                    if (isTechnicianSelected)
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 5),
                                            child: Text(
                                              'Please Select Technician',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 175, 15, 4),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                  const SizedBox(height: 10.0),
                                  const Row(
                                    children: [
                                      Text(
                                        'Billing Amount (Rs) ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '*',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  TextFormField(
                                    controller: _priceController,
                                    enabled: isFreeService,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
                                    maxLength: 10,
                                    decoration: InputDecoration(
                                        errorText: _billingAmountError
                                            ? _billingAmountErrorMsg
                                            : null,
                                        contentPadding: const EdgeInsets.only(
                                            top: 15,
                                            bottom: 10,
                                            left: 15,
                                            right: 15),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: CommonUtils.primaryTextColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: CommonUtils.primaryTextColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color:
                                                Color.fromARGB(255, 175, 15, 4),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                        border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        hintText: 'Enter Billing Amount (Rs)',
                                        counterText: "",
                                        hintStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500)),
                                    validator: validateAmount,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.startsWith(' ')) {
                                          _priceController.value =
                                              TextEditingValue(
                                            text: value.trimLeft(),
                                            selection: TextSelection.collapsed(
                                                offset:
                                                    value.trimLeft().length),
                                          );
                                        }
                                        _billingAmountError = false;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  buttonText: 'Submit',
                                  color: CommonUtils.primaryTextColor,
                                  onPressed: () {
                                    /* CommonWidgets.customCancelDialog(
                                    context,
                                    message:
                                        'Are You Sure You Want to Close ${consultationslist[index].consultationName} Consultation?',
                                    onConfirm: () {
                                      customConsultationCall(
                                          consultationslist[index], 17);
                                    },
                                  ); */

                                    setState(() {
                                      validatePaymentMode();
                                      validateTechnician();
                                    });
                                    if (_formKey.currentState!.validate() &&
                                        isPaymentValidate &&
                                        isTechnicianValidate &&
                                        isBillingAmountValidate) {
                                      double? price = double.tryParse(
                                          _priceController.text);
                                      //MARK: close api for consultation
                                      customConsultationCall(data, 17);
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
 */
  void validatePaymentMode() {
    print('www: $selectedPaymentOption');
    if (selectedPaymentOption == -1) {
      setState(() {
        isPaymentModeSelected = true;
        isPaymentValidate = false;
      });
    } else {
      setState(() {
        isPaymentModeSelected = false;
        isPaymentValidate = true;
      });
    }
  }

  void validateTechnician() {
    print('www: $selectedPaymentOption');
    if (selectedTechnicianId == null || selectedTechnicianId == -1) {
      setState(() {
        isTechnicianSelected = true;
        isTechnicianValidate = false;
      });
    } else {
      setState(() {
        isTechnicianSelected = false;
        isTechnicianValidate = true;
      });
    }
  }

  String? formatDateTime(DateTime? visitingDate) {
    if (visitingDate == null) {
      return null;
    }

    try {
      String formattedDate = DateFormat('dd-MM-yyyy').format(visitingDate);
      return formattedDate;
    } catch (e) {
      return null;
    }
  }

  bool canRescheduleAppointment(DateTime? visitingDate) {
    if (visitingDate == null) return false;

    final now = DateTime.now();

    bool isSameDay = now.year == visitingDate.year &&
        now.month == visitingDate.month &&
        now.day == visitingDate.day;
    if (isSameDay) {
      final difference = visitingDate.difference(now).inMinutes;
      return difference > 15;
    }
    return true;
  }

  Widget statusBasedBgById(int? statusTypeId, String? status) {
    final Color statusColor;
    final Color statusBgColor;
    print('statusBasedBgById: $statusTypeId | $status');
    if (statusTypeId == 11) {
      status = "Closed";
    }

    switch (statusTypeId) {
      case 4: // Submited
        statusColor = CommonStyles.statusBlueText;
        statusBgColor = CommonStyles.statusBlueBg;
        break;
      case 5: // Accepted
        statusColor = CommonStyles.statusGreenText;
        statusBgColor = CommonStyles.statusGreenBg;
        break;
      case 6: // Declined
        statusColor = CommonStyles.statusRedText;
        statusBgColor = CommonStyles.statusRedBg;
        break;
      case 11: // FeedBack
        statusColor = const Color.fromARGB(255, 33, 129, 70);
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 17: // Closed
        statusColor = CommonStyles.statusYellowText;
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 28: // Not Visited
        statusColor = CommonStyles.statusYellowText;
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 100: // Rejected
        statusColor = CommonStyles.statusYellowText;
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 34: // Follow Up
        statusColor = CommonStyles.followUpStatusColor;
        statusBgColor = CommonStyles.followUpStatusColor.withOpacity(0.2);
        break;
      case 35: // Order Placed
        statusColor = CommonStyles.orderPlacedStatusColor;
        statusBgColor = CommonStyles.orderPlacedStatusColor.withOpacity(0.2);
        break;
      case 36: // Not Interested
        statusColor = CommonStyles.notInterestedStatusColor;
        statusBgColor = CommonStyles.notInterestedStatusColor.withOpacity(0.2);
        break;
      default:
        statusColor = Colors.black26;
        statusBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: statusBgColor),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Text(
        '$status',
        style: TextStyle(
          fontSize: 13,
          fontFamily: "Outfit",
          fontWeight: FontWeight.w500,
          color: statusColor,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffe2f0fd),
        title: const Text(
          'View Consultation',
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
        ));
  }

  List<String>? _getValueText(
      CalendarDatePicker2Type datePickerType, List<DateTime?> values) {
    values =
        values.map((e) => e != null ? DateUtils.dateOnly(e) : null).toList();

    DateTime? startDate;
    DateTime? endDate;

    startDate = values[0];
    endDate = values.length > 1 ? values[1] : null;
    String? formattedStartDate = DateFormat('dd/MM/yyyy').format(startDate!);
    String? formattedEndDate =
        endDate != null ? DateFormat('dd/MM/yyyy').format(endDate) : 'null';

    return [formattedStartDate, formattedEndDate];
  }

  String formatVisitingDate(String visitingDate) {
    // String visitingDate = '2024-07-16T16:15:00';
    DateTime parsedDate = DateTime.parse(visitingDate);
    String formattedTime = DateFormat.jm().format(parsedDate);
    print(formattedTime); // Output: 4:15 PM
    return formattedTime;
  }

  String? formatVisitingDate2(DateTime? parsedDate) {
    if (parsedDate == null) {
      return '';
    }
    String formattedTime = DateFormat.jm().format(parsedDate);
    return formattedTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = selectedDate ?? currentDate;

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
        selectedDate = pickedDay;
        _fromToDatesController.text =
            DateFormat('dd-MM-yyyy').format(pickedDay);
        String apiFromDate = DateFormat('yyyy-MM-dd').format(pickedDay);
        String apiToDate = DateFormat('yyyy-MM-dd').format(pickedDay);
        consultationData = getviewconsulationlist(apiFromDate, apiToDate);
        print('test: $selectedDate');
        print('test apiFromDate: $apiFromDate');
        print('test apiToDate: $apiToDate');
      });
    }
  }

  void cancelConsultationDialog(Consultation consultation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 130,
                child: Image.asset('assets/check.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                // Center the text
                child: Text(
                  'Are You Sure You Want to Cancel the Appointment at ${consultation.branchName} Branch for ${consultation.consultationName}?',
                  style: CommonUtils.txSty_18b_fb,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  color: CommonUtils.primaryTextColor,
                ),
                side: const BorderSide(
                  color: CommonUtils.primaryTextColor,
                ),
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: CommonUtils.primaryTextColor,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                cancelConsultation(consultation);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  color: CommonUtils.primaryTextColor,
                ),
                side: const BorderSide(
                  color: CommonUtils.primaryTextColor,
                ),
                backgroundColor: CommonUtils.primaryTextColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelConsultation(Consultation consultation) async {
    print('cancelConsultation: ${jsonEncode(consultation)}');
    try {
      final apiUrl = Uri.parse(baseUrl + addupdateconsulation);
      final requestBody = jsonEncode({
        "id": consultation.consultationId,
        "name": consultation.consultationName,
        "genderTypeId": consultation.genderTypeId,
        "phoneNumber": consultation.phoneNumber,
        "email": consultation.email,
        "branchId": consultation.branchId,
        "isActive": true,
        "remarks": consultation.remarks,
        "createdByUserId": consultation.createdByUser,
        "createdDate": DateFormat('yyyy-MM-dd')
            .format(consultation.createdDate ?? DateTime.now()),
        "updatedByUserId": widget.userid,
        "updatedDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "visitingDate": DateFormat('yyyy-MM-dd')
            .format(consultation.visitingDate ?? DateTime.now()),
        "statusTypeId": 6 // newly added
      });
      print('rescheduleConsultation: $requestBody');
      final jsonResponse = await http.post(
        apiUrl,
        body: requestBody,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);
        if (response['isSuccess']) {
          CommonUtils.showCustomToastMessageLong(
              'Consultation Cancelled Successfully', context, 0, 5);
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());
          setState(() {
            consultationData =
                getviewconsulationlist(formattedDate, formattedDate);
          });
        } else {
          CommonUtils.showCustomToastMessageLong(
              '${response['statusMessage']}', context, 0, 5);
        }
      } else {
        throw Exception('Failed to cancel consultation');
      }
    } catch (e) {
      print('Error slot: $e');
      rethrow;
    }
  }

  Future<void> customConsultationCall(
      Consultation consultation, int statusTypeId) async {
    try {
      final apiUrl = Uri.parse(baseUrl + addupdateconsulation);
      final requestBody = jsonEncode({
        "id": consultation.consultationId,
        "name": consultation.consultationName,
        "genderTypeId": consultation.genderTypeId,
        "phoneNumber": consultation.phoneNumber,
        "email": consultation.email,
        "branchId": consultation.branchId,
        "isActive": true,
        "remarks": consultation.remarks,
        "createdByUserId": consultation.createdByUser,
        "createdDate":
            DateFormat('yyyy-MM-dd').format(consultation.createdDate!),
        "updatedByUserId": widget.userid,
        "updatedDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "visitingDate":
            DateFormat('yyyy-MM-dd').format(consultation.visitingDate!),
        "statusTypeId": statusTypeId,
        "paymentTypeId": apiPaymentMode,
        "price": _priceController.text.trim(),
        "technicianId": selectedTechnicianId
      });
      print('rescheduleConsultation: $requestBody');
      final jsonResponse = await http.post(
        apiUrl,
        body: requestBody,
        headers: {'Content-Type': 'application/json'},
      );

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);
        if (response['isSuccess']) {
          CommonUtils.showCustomToastMessageLong(
              statusTypeId == 28
                  ? 'Consultation Marked as Not Visited'
                  : response['statusMessage'],
              context,
              0,
              2);
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());
          setState(() {
            consultationData =
                getviewconsulationlist(formattedDate, formattedDate);
          });
        } else {
          CommonUtils.showCustomToastMessageLong(
              '${response['statusMessage']}', context, 0, 2);
        }
      } else {
        throw Exception('Failed to reschedule consultation');
      }
    } catch (e) {
      print('Error slot: $e');
      rethrow;
    }
  }

  /*  Row customRow({required String title, required String? data}) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                ': $data',
                style: const TextStyle(
                  color: CommonStyles.primaryTextColor,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
 */

  Row customRow({required String title, required String? data}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ' : ',
          style: TextStyle(
            color: CommonStyles.primaryTextColor,
            fontSize: 14,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            '$data',
            style: const TextStyle(
              color: CommonStyles.primaryTextColor,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Padding paymentModeDropDown(BuildContext context, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 5.0, right: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: isPaymentModeSelected
                ? const Color.fromARGB(255, 175, 15, 4)
                : CommonUtils.primaryTextColor,
          ),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: FutureBuilder(
            future: futurePaymentTypes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text(''),
                );
              }
              if (snapshot.hasError) {
                // return Text('Error: ${snapshot.error}');
                return const SizedBox();
              }
              final paymentOptions = snapshot.data as List<PaymentTypesModel>;
              return DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<int>(
                    value:
                        paymentOptions.isNotEmpty && selectedPaymentOption != -1
                            ? selectedPaymentOption
                            : -1, // Ensure the default value exists
                    iconSize: 30,
                    icon: null,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          selectedPaymentOption = value;
                          if (paymentOptions[value].typeCdId == 23) {
                            isFreeService = false;
                            _priceController.text = '0.0';
                          } else {
                            _priceController.clear();
                            isFreeService = true;
                          }

                          apiPaymentMode =
                              paymentOptions[selectedPaymentOption].typeCdId;
                          selectedPaymentMode =
                              paymentOptions[selectedPaymentOption].desc;
                        }
                        isPaymentModeSelected = false;
                      });
                    },
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          'Select Payment Mode',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ...paymentOptions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('${item.desc}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Padding technicianDropDown(BuildContext context, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 5.0, right: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: isTechnicianSelected
                ? const Color.fromARGB(255, 175, 15, 4)
                : CommonUtils.primaryTextColor,
          ),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: FutureBuilder(
            future: futureTechnicians,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text(''),
                );
              }
              if (snapshot.hasError) {
                // return Text('Error: ${snapshot.error}');
                return const SizedBox();
              }
              final technicianOptions = snapshot.data as List<TechniciansModel>;
              return DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<int>(
                    value: selectedTechnicianOption,
                    iconSize: 30,
                    hint: const Text(
                      'Select Technician',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    icon: null,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        print('www1: $value');
                        selectedTechnicianOption = value;

                        if (value != null) {
                          selectedTechnicianId = technicianOptions[value].id;
                        }
                        isTechnicianSelected = false;
                      });
                    },
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          'Select Technician',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ...technicianOptions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('${item.userName}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  String? validateAmount(String? value) {
    print('validatefullname: $value');
    if (value!.isEmpty) {
      setState(() {
        _billingAmountError = true;
        _billingAmountErrorMsg = 'Please Enter Billing Amount (Rs)';
      });
      isBillingAmountValidate = false;
      return null;
    }
    isBillingAmountValidate = true;
    return null;
  }
}

class CloseConsulationCard extends StatefulWidget {
  final Consultation data;
  // final void Function()? onSubmit;
  final void Function(
      int? paymentMode, String? billingAmount, int? technicianId)? onSubmit;
  final Future<List<TechniciansModel>> futureTechnicians;
  final Future<List<PaymentTypesModel>> futurePaymentTypes;
  const CloseConsulationCard(
      {super.key,
      required this.data,
      this.onSubmit,
      required this.futureTechnicians,
      required this.futurePaymentTypes});

  @override
  State<CloseConsulationCard> createState() => _CloseConsulationCardState();
}

class _CloseConsulationCardState extends State<CloseConsulationCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
/*   late Future<List<PaymentTypesModel>> futurePaymentTypes;
  late Future<List<TechniciansModel>> futureTechnicians; */
  int? selectedPaymentOption = -1;
  int? selectedTechnicianOption;
  int? selectedTechnicianId;
  int? apiPaymentMode;
  bool isPaymentValidate = false;
  bool isPaymentModeSelected = false;
  bool _billingAmountError = false;
  String? _billingAmountErrorMsg;
  bool isBillingAmountValidate = false;

  bool isTechnicianValidate = false;
  bool isTechnicianSelected = false;
  bool isFreeService = true;
  String? selectedPaymentMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xffffffff),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(
                    child: Center(
                  child: Text(
                    'Billing Details',
                    style: TextStyle(
                      color: CommonStyles.primaryTextColor,
                      fontSize: 14,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )),
                GestureDetector(
                  onTap: () {
                    selectedPaymentOption = -1;
                    _priceController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    backgroundColor: CommonStyles.primaryColor,
                    radius: 12,
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color: CommonStyles.primaryTextColor,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          customRow(
                              data: widget.data.consultationName,
                              title: 'Customer Name'),

                          const SizedBox(height: 5),
                          customRow(
                              /* data: DateFormat('dd-MM-yyyy')
                                            .format(DateTime.parse(data.visitingDate)), */
                              // data: formatDateTime(widget.data.visitingDate),

                              data: DateFormat('dd-MM-yyyy hh:mm a')
                                  .format(widget.data.visitingDate!),
                              title: 'Slot Time'),

                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Text(
                                'Payment Mode ',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          paymentModeDropDown(context, setState),
                          if (isPaymentModeSelected)
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Text(
                                    'Please Select Payment Mode',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 175, 15, 4),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          //MARK: Technicians
                          // if (data.technicianName == null)
                          ...[
                            const SizedBox(height: 10.0),
                            const Row(
                              children: [
                                Text(
                                  'Technician ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            technicianDropDown(context, setState),
                            if (isTechnicianSelected)
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 5),
                                    child: Text(
                                      'Please Select Technician',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 175, 15, 4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                          const SizedBox(height: 10.0),
                          const Row(
                            children: [
                              Text(
                                'Billing Amount (Rs) ',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0),
                          TextFormField(
                            controller: _priceController,
                            enabled: isFreeService,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            /*  inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                 RegExp(r'^\d+\.?\d{0,2}$'),),
                            ], */
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            maxLength: 10,
                            decoration: InputDecoration(
                                errorText: _billingAmountError
                                    ? _billingAmountErrorMsg
                                    : null,
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
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color.fromARGB(255, 175, 15, 4),
                                  ),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                hintText: 'Enter Billing Amount (Rs)',
                                counterText: "",
                                hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500)),
                            validator: validateAmount,
                            onChanged: (value) {
                              setState(() {
                                if (value.startsWith(' ')) {
                                  _priceController.value = TextEditingValue(
                                    text: value.trimLeft(),
                                    selection: TextSelection.collapsed(
                                        offset: value.trimLeft().length),
                                  );
                                }
                                _billingAmountError = false;
                              });
                            },
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          buttonText: 'Submit',
                          color: CommonUtils.primaryTextColor,
                          onPressed: () {
                            /* CommonWidgets.customCancelDialog(
                                      context,
                                      message:
                                          'Are You Sure You Want to Close ${consultationslist[index].consultationName} Consultation?',
                                      onConfirm: () {
                                        customConsultationCall(
                                            consultationslist[index], 17);
                                      },
                                    ); */
                            setState(() {
                              validatePaymentMode();
                              validateTechnician();
                            });
                            print(
                                'qqq currentState: $isPaymentValidate | $isTechnicianValidate | $isBillingAmountValidate');
                            if (_formKey.currentState!.validate() &&
                                isPaymentValidate &&
                                isTechnicianValidate) {
                              // widget.onSubmit?.call();
                              widget.onSubmit?.call(
                                selectedPaymentOption == -1
                                    ? null
                                    : apiPaymentMode,
                                _priceController.text.trim(),
                                selectedTechnicianId,
                              );
                              /* double? price =
                                      double.tryParse(_priceController.text);
                                  //MARK: close api for consultation
                                  customConsultationCall(widget.data, 17);
                                  Navigator.of(context).pop(); */
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row customRow({required String title, required String? data}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(
          ' : ',
          style: TextStyle(
            color: CommonStyles.primaryTextColor,
            fontSize: 14,
            fontFamily: "Outfit",
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            '$data',
            style: const TextStyle(
              color: CommonStyles.primaryTextColor,
              fontSize: 14,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  String? formatDateTime(DateTime? visitingDate) {
    if (visitingDate == null) {
      return null;
    }

    try {
      String formattedDate = DateFormat('dd-MM-yyyy').format(visitingDate);
      return formattedDate;
    } catch (e) {
      return null;
    }
  }

  Padding paymentModeDropDown(BuildContext context, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 5.0, right: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: isPaymentModeSelected
                ? const Color.fromARGB(255, 175, 15, 4)
                : CommonUtils.primaryTextColor,
          ),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: FutureBuilder(
            future: widget.futurePaymentTypes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text(''),
                );
              }
              if (snapshot.hasError) {
                // return Text('Error: ${snapshot.error}');
                return const SizedBox();
              }
              final paymentOptions = snapshot.data as List<PaymentTypesModel>;
              return DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<int>(
                    value:
                        paymentOptions.isNotEmpty && selectedPaymentOption != -1
                            ? selectedPaymentOption
                            : -1, // Ensure the default value exists
                    iconSize: 30,
                    icon: null,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          selectedPaymentOption = value;
                          if (paymentOptions[value].typeCdId == 23) {
                            isFreeService = false;
                            _priceController.text = '0.0';
                          } else {
                            _priceController.clear();
                            isFreeService = true;
                          }

                          apiPaymentMode =
                              paymentOptions[selectedPaymentOption!].typeCdId;
                          selectedPaymentMode =
                              paymentOptions[selectedPaymentOption!].desc;
                        }
                        isPaymentModeSelected = false;
                      });
                    },
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          'Select Payment Mode',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ...paymentOptions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('${item.desc}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Padding technicianDropDown(BuildContext context, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 5.0, right: 0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: isTechnicianSelected
                ? const Color.fromARGB(255, 175, 15, 4)
                : CommonUtils.primaryTextColor,
          ),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: FutureBuilder(
            future: widget.futureTechnicians,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(13),
                  child: Text(''),
                );
              }
              if (snapshot.hasError) {
                // return Text('Error: ${snapshot.error}');
                return const SizedBox();
              }
              final technicianOptions = snapshot.data as List<TechniciansModel>;
              return DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<int>(
                    value: selectedTechnicianOption,
                    iconSize: 30,
                    hint: const Text(
                      'Select Technician',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    icon: null,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    onChanged: (value) {
                      setState(() {
                        print('www1: $value');
                        selectedTechnicianOption = value;

                        if (value != null) {
                          selectedTechnicianId = technicianOptions[value].id;
                        }
                        isTechnicianSelected = false;
                      });
                    },
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          'Select Technician',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ...technicianOptions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text('${item.userName}'),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  void validatePaymentMode() {
    print('www: $selectedPaymentOption');
    if (selectedPaymentOption == -1) {
      setState(() {
        isPaymentModeSelected = true;
        isPaymentValidate = false;
      });
    } else {
      setState(() {
        isPaymentModeSelected = false;
        isPaymentValidate = true;
      });
    }
  }

  void validateTechnician() {
    print('www: $selectedPaymentOption');
    if (selectedTechnicianId == null || selectedTechnicianId == -1) {
      setState(() {
        isTechnicianSelected = true;
        isTechnicianValidate = false;
      });
    } else {
      setState(() {
        isTechnicianSelected = false;
        isTechnicianValidate = true;
      });
    }
  }
  /* 
Future<void> customConsultationCall(
      Consultation consultation, int statusTypeId) async {
    try {
      final apiUrl = Uri.parse(baseUrl + addupdateconsulation);
      final requestBody = jsonEncode({
        "id": consultation.consultationId,
        "name": consultation.consultationName,
        "genderTypeId": consultation.genderTypeId,
        "phoneNumber": consultation.phoneNumber,
        "email": consultation.email,
        "branchId": consultation.branchId,
        "isActive": true,
        "remarks": consultation.remarks,
        "createdByUserId": consultation.createdByUser,
        "createdDate":
            DateFormat('yyyy-MM-dd').format(consultation.createdDate!),
        "updatedByUserId": widget.userid,
        "updatedDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "visitingDate":
            DateFormat('yyyy-MM-dd').format(consultation.visitingDate!),
        "statusTypeId": statusTypeId,
        "paymentTypeId": apiPaymentMode,
        "price": _priceController.text.trim(),
        "technicianId": selectedTechnicianId
      });
      print('rescheduleConsultation: $requestBody');
      final jsonResponse = await http.post(
        apiUrl,
        body: requestBody,
        headers: {'Content-Type': 'application/json'},
      );

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);
        if (response['isSuccess']) {
          CommonUtils.showCustomToastMessageLong(
              statusTypeId == 28
                  ? 'Consultation Marked as Not Visited'
                  : 'Consultation Closed Successfully',
              context,
              0,
              2);
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());
          setState(() {
            consultationData =
                getviewconsulationlist(formattedDate, formattedDate);
          });
        } else {
          CommonUtils.showCustomToastMessageLong(
              '${response['statusMessage']}', context, 0, 2);
        }
      } else {
        throw Exception('Failed to reschedule consultation');
      }
    } catch (e) {
      print('Error slot: $e');
      rethrow;
    }
  }
 */

  String? validateAmount(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _billingAmountError = true;
        _billingAmountErrorMsg = 'Please Enter Billing Amount (Rs)';
      });
      isBillingAmountValidate = false;
      return null;
    }
    isBillingAmountValidate = true;
    return null;
  }
}

/* 
class ConsultationCard extends StatefulWidget {
  final Consultation consultation;
  const ConsultationCard({super.key, required this.consultation});

  @override
  State<ConsultationCard> createState() => _ConsultationCardState();
}

class _ConsultationCardState extends State<ConsultationCard> {
  late List<dynamic> dateValues;

                              final GlobalKey mobilenumber = GlobalKey();

                              
  @override
  void initState() {
    dateValues = parseDateString(widget.consultation.visitingDate);

    super.initState();
  }

  List<dynamic> parseDateString(DateTime? visitingDate) {
    if (visitingDate == null) {
      return [];
    }
    print(
        'dateFormate: ${visitingDate.day} - ${DateFormat.MMM().format(visitingDate)} - ${visitingDate.year}');
    //         int ,       String ,                           int
    return [
      visitingDate.day,
      DateFormat.MMM().format(visitingDate),
      visitingDate.year
    ];
  }

  @override
  Widget build(BuildContext context) {
    dateValues = parseDateString(widget.consultation.visitingDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: IntrinsicHeight(
            child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xffe2f0fd),
                Color(0xffe2f0fd),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Column(
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
              const VerticalDivider(
                color: CommonUtils.primaryTextColor,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          //width: MediaQuery.of(context).size.width / 2.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${formatVisitingDate2(widget.consultation.visitingDate)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 2.0,
                              ),
                              Text(
                                '${widget.consultation.consultationName}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Outfit",
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      makePhoneCall(
                                          'tel:+91${widget.consultation.phoneNumber}');
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: widget.consultation
                                            .phoneNumber,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Outfit",
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF0f75bc),
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(
                                              0xFF0f75bc), // Change this to your desired underline color
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  GestureDetector(
                                    key: mobilenumber,
                                    child: const Icon(
                                      Icons.copy,
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: widget.consultation
                                              .phoneNumber!));
                                      showTooltip(
                                          context, "Copied", mobilenumber);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          statusBasedBgById(
                              widget.consultation.statusTypeId,
                              widget.consultation.status),
                          const SizedBox(height: 5.0),
                          Text(
                            '${widget.consultation.gender}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5f5f5f),
                            ),
                          ),
                          Text(
                            '${widget.consultation.email}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5f5f5f),
                            ),
                          ),
                          //Text('', style: CommonStyles.txSty_16black_f5),
                          // Text(widget.consultation.gender, style: CommonStyles.txSty_16black_f5),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Flexible(
                    child: Visibility(
                      visible: (widget.consultation.remarks != null &&
                          widget.consultation.remarks!.isNotEmpty),
                      child: RichText(
                        text: TextSpan(
                          text: 'Remark : ',
                          style: CommonStyles.txSty_14blu_f5,
                          children: <TextSpan>[
                            TextSpan(
                              text: widget.consultation.remarks ?? '',
                              style: const TextStyle(
                                color: Color(0xFF5f5f5f),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //MARK: Status Btn
                  if (widget.consultation.statusTypeId != 28 &&
                      widget.consultation.statusTypeId != 18 &&
                      widget.consultation.statusTypeId != 17 &&
                      widget.consultation.statusTypeId != 36) ...[
                    (DateTime.now()
                            .isAfter(widget.consultation.visitingDate!))
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  CommonWidgets.customCancelDialog(
                                    context,
                                    message:
                                        'Are You Sure You Want to Mark as Not Visited ${widget.consultation.consultationName} Consultation?',
                                    onConfirm: () {
                                      customConsultationCall(
                                          widget.consultation, 28);
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: CommonStyles.statusRedText,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/not_visted.svg',
                                        width: 12,
                                        color: CommonStyles.statusorangeText,
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        'Not visited',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CommonStyles.statusorangeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  closePopUp(context, widget.consultation);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(
                                      color: CommonStyles
                                          .statusRedText, // Use a different color for differentiation
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/close.svg',
                                        width: 12,
                                        color: CommonStyles.statusorangeText,
                                      ),
                                      const SizedBox(width: 2),
                                      const Text(
                                        'Close',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: CommonStyles.statusorangeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        //MARK: Reschedule
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              customStatusBtn(
                                index,
                                context,
                                statusIcon: 'assets/calendar-_3_.svg',
                                statusText: 'Reschedule',
                                btnThemeColor: CommonStyles.primaryTextColor,
                                onTap: () async {
                                  if (canRescheduleAppointment(
                                      widget.consultation.visitingDate)) {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddConsulationscreen(
                                                agentId: widget.userid,
                                                branch: widget.agent,
                                                screenForReschedule: true,
                                                consultation:
                                                    widget.consultation),
                                      ),
                                    );

                                    if (result == true) {
                                      final formattedDate =
                                          DateFormat('yyyy-MM-dd').format(
                                              selectedDate ?? DateTime.now());

                                      setState(() {
                                        consultationData =
                                            getviewconsulationlist(
                                                formattedDate, formattedDate);
                                      });
                                    }
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                      'The Request Should Not be Rescheduled Within 15 minutes Before the Slot',
                                      context,
                                      0,
                                      2,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 10),
                              customStatusBtn(
                                index,
                                context,
                                statusIcon: 'assets/calendar-xmark.svg',
                                statusText: 'Cancel',
                                btnThemeColor: CommonStyles.statusRedText,
                                onTap: () {
                                  if (canRescheduleAppointment(
                                      widget.consultation.visitingDate)) {
                                    CommonWidgets.customCancelDialog(
                                      context,
                                      message:
                                          'Are You Sure You Want to Cancel this ${widget.consultation.consultationName} Consultation?',
                                      onConfirm: () {
                                        cancelConsultation(
                                            widget.consultation);
                                      },
                                    );
                                  } else {
                                    CommonUtils.showCustomToastMessageLong(
                                      'The Request Should Not be Cancelled Within 15 minutes Before the Slot',
                                      context,
                                      0,
                                      2,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                  ],
                  if (widget.consultation.statusTypeId != 17 &&
                      widget.consultation.statusTypeId != 28 &&
                      widget.consultation.statusTypeId != 36) ...[
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.start,
                      children: [
                        if (widget.consultation.statusTypeId != 34)
                          customStatusBtn(
                            index,
                            context,
                            statusIcon: 'assets/calendar-_3_.svg',
                            statusText: 'Follow Up',
                            btnThemeColor: CommonStyles.followUpStatusColor,
                            onTap: () {
                              CommonWidgets.customCancelDialog(
                                context,
                                message:
                                    'You Want to Follow up ${widget.consultation.consultationName} Consultation?',
                                onConfirm: () {
                                  customConsultationCall(
                                      widget.consultation, 34);
                                },
                              );
                            },
                          ),
                        if (widget.consultation.statusTypeId != 35)
                          customStatusBtn(
                            index,
                            context,
                            statusIcon: 'assets/calendar-xmark.svg',
                            statusText: 'Order Placed',
                            btnThemeColor: CommonStyles.orderPlacedStatusColor,
                            onTap: () {
                              CommonWidgets.customCancelDialog(
                                context,
                                message:
                                    'You Want to Order Place ${widget.consultation.consultationName} Consultation?',
                                onConfirm: () {
                                  customConsultationCall(
                                      widget.consultation, 35);
                                },
                              );
                            },
                          ),
                        if (widget.consultation.statusTypeId != 36)
                          customStatusBtn(
                            index,
                            context,
                            statusIcon: 'assets/calendar-xmark.svg',
                            statusText: 'Not Interested',
                            btnThemeColor:
                                CommonStyles.notInterestedStatusColor,
                            onTap: () {
                              CommonWidgets.customCancelDialog(
                                context,
                                message:
                                    'Are You Sure You are Not Interested ${widget.consultation.consultationName} Consultation?',
                                onConfirm: () {
                                  customConsultationCall(
                                      widget.consultation, 36);
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              )),
            ],
          ),
        )),
      ),
    );
  }
  

  String? formatVisitingDate2(DateTime? parsedDate) {
    if (parsedDate == null) {
      return '';
    }
    String formattedTime = DateFormat.jm().format(parsedDate);
    return formattedTime;
  }
  
Future<void> makePhoneCall(String phoneNumber) async {
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
  
    void showTooltip(BuildContext context, String message, GlobalKey toolTipKey) {
    final renderBox =
        toolTipKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final target = renderBox.localToGlobal(
            renderBox.size.bottomLeft(Offset.zero),
            ancestor: overlay) +
        const Offset(-10, 0);

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: target.dx,
        top: target.dy,
        child: Material(
          color: Colors.transparent,
          child: TooltipOverlay(message: message),
        ),
      ),
    );

    Overlay.of(context).insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
  
Widget statusBasedBgById(int? statusTypeId, String? status) {
    final Color statusColor;
    final Color statusBgColor;
    print('statusBasedBgById: $statusTypeId | $status');
    if (statusTypeId == 11) {
      status = "Closed";
    }

    switch (statusTypeId) {
      case 4: // Submited
        statusColor = CommonStyles.statusBlueText;
        statusBgColor = CommonStyles.statusBlueBg;
        break;
      case 5: // Accepted
        statusColor = CommonStyles.statusGreenText;
        statusBgColor = CommonStyles.statusGreenBg;
        break;
      case 6: // Declined
        statusColor = CommonStyles.statusRedText;
        statusBgColor = CommonStyles.statusRedBg;
        break;
      case 11: // FeedBack
        statusColor = const Color.fromARGB(255, 33, 129, 70);
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 17: // Closed
        statusColor = CommonStyles.statusYellowText;
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 28: // Not Visited
        statusColor = CommonStyles.statusYellowText;
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 100: // Rejected
        statusColor = CommonStyles.statusYellowText;
        statusBgColor = CommonStyles.statusYellowBg;
        break;
      case 34: // Follow Up
        statusColor = CommonStyles.followUpStatusColor;
        statusBgColor = CommonStyles.followUpStatusColor.withOpacity(0.2);
        break;
      case 35: // Order Placed
        statusColor = CommonStyles.orderPlacedStatusColor;
        statusBgColor = CommonStyles.orderPlacedStatusColor.withOpacity(0.2);
        break;
      case 36: // Not Interested
        statusColor = CommonStyles.notInterestedStatusColor;
        statusBgColor = CommonStyles.notInterestedStatusColor.withOpacity(0.2);
        break;
      default:
        statusColor = Colors.black26;
        statusBgColor = Colors.black26.withOpacity(0.2);
        break;
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: statusBgColor),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
      child: Row(
        children: [
          // statusBasedBgById(widget.data.statusTypeId),
          Text(
            '$status',
            style: TextStyle(
              fontSize: 16,
              fontFamily: "Outfit",
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> customConsultationCall(
      Consultation consultation, int statusTypeId) async {
    try {
      final apiUrl = Uri.parse(baseUrl + addupdateconsulation);
      final requestBody = jsonEncode({
        "id": consultation.consultationId,
        "name": consultation.consultationName,
        "genderTypeId": consultation.genderTypeId,
        "phoneNumber": consultation.phoneNumber,
        "email": consultation.email,
        "branchId": consultation.branchId,
        "isActive": true,
        "remarks": consultation.remarks,
        "createdByUserId": consultation.createdByUser,
        "createdDate":
            DateFormat('yyyy-MM-dd').format(consultation.createdDate!),
        "updatedByUserId": widget.userid,
        "updatedDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "visitingDate":
            DateFormat('yyyy-MM-dd').format(consultation.visitingDate!),
        "statusTypeId": statusTypeId,
        "paymentTypeId": apiPaymentMode,
        "price": _priceController.text.trim(),
        "technicianId": selectedTechnicianId
      });
      print('rescheduleConsultation: $requestBody');
      final jsonResponse = await http.post(
        apiUrl,
        body: requestBody,
        headers: {'Content-Type': 'application/json'},
      );

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);
        if (response['isSuccess']) {
          CommonUtils.showCustomToastMessageLong(
              statusTypeId == 28
                  ? 'Consultation Marked as Not Visited'
                  : 'Consultation Closed Successfully',
              context,
              0,
              2);
          final formattedDate =
              DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now());
          setState(() {
            consultationData =
                getviewconsulationlist(formattedDate, formattedDate);
          });
        } else {
          CommonUtils.showCustomToastMessageLong(
              '${response['statusMessage']}', context, 0, 2);
        }
      } else {
        throw Exception('Failed to reschedule consultation');
      }
    } catch (e) {
      print('Error slot: $e');
      rethrow;
    }
  }


}
 */