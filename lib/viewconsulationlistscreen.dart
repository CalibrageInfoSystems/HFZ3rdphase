import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/BranchModel.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/CustomCalendarDialog.dart';
import 'package:hairfixingzone/MyAppointment_Model.dart';

import 'package:hairfixingzone/api_config.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'AgentBranchesModel.dart';
import 'Consultation.dart';

class viewconsulationlistscreen extends StatefulWidget {
  final int branchid;
  final String fromdate;
  final String todate;
  final BranchModel agent;
  final int userid;

  const viewconsulationlistscreen(
      {super.key,
      required this.branchid,
      required this.fromdate,
      required this.todate,
      required this.agent,
      required this.userid});

  @override
  State<viewconsulationlistscreen> createState() => _ViewConsultationState();
}

class _ViewConsultationState extends State<viewconsulationlistscreen> {
  List<Consultation> consultationslist = [];

  final TextEditingController _fromToDatesController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  DateTime? selectedDate;
  String? month;
  String? date;
  String? year;
  late Future<List<Consultation>> ConsultationData;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(const Duration(days: 14));
    endDate = DateTime.now();
    _fromToDatesController.text =
        DateFormat('dd-MM-yyyy').format(DateTime.now());

    print(
        'branchid ${widget.branchid} fromdate${widget.fromdate} todate ${widget.todate}');
    ConsultationData = getviewconsulationlist(
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

// http://182.18.157.215/SaloonApp/API/api/Consultation/GetConsultationsByBranchId
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
    print('test rqbody: $requestObject');
    // {
    //   "branchId": widget.branchid,
    //   "fromDate": widget.fromdate,
    //   "toDate": widget.todate
    // };

    print('requestObject==${jsonEncode(requestObject)}');

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
            // for (var consultation in consultations) {
            //   DateTime createdDateTime = DateTime.parse(consultation.createdDate);
            //   month = DateFormat('MMM').format(createdDateTime);
            //   date = DateFormat('dd').format(createdDateTime);
            //   year = DateFormat('yyyy').format(createdDateTime);
            //
            //   print('month: $month, Date: $date, Year: $year');
            // }
            setState(() {
              consultationslist = consultations;
            });
            return consultations;
            print(consultations);
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
                                    widget.agent.name,
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
                                    widget.agent.address,
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
                            //               getviewconsulationlist(DateFormat('yyyy-MM-dd').format(startDate!), DateFormat('yyyy-MM-dd').format(endDate!));

                            selectedDate =
                                _getValueText(config.calendarType, values);
                            _fromToDatesController.text =
                                '${selectedDate![0]} - ${selectedDate![1]}';
                            String apiFromDate = formateDate(selectedDate![0]);
                            String apiToDate = formateDate(selectedDate![1]);
                            ConsultationData =
                                getviewconsulationlist(apiFromDate, apiToDate);
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
                future: ConsultationData,
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
                              DateTime createdDateTime = DateTime.parse(
                                consultationslist[index].visitingDate,
                              );
                              final GlobalKey mobilenumber = GlobalKey();

                              month = DateFormat('MMM').format(createdDateTime);
                              date = DateFormat('dd').format(createdDateTime);
                              year = DateFormat('yyyy').format(createdDateTime);
                              print('month: $month, Date: $date, Year: $year');
                              // if (consultationslist.length > 0) {
                              return consultationCard(
                                  context, index, mobilenumber);
                              //  }
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
            // border: Border.all(
            //   color: Colors.grey,
            //   //  color: const Color(0xFF8d97e2), // Add your desired border color here
            //   width:
            //   1.0, // Set the border width
            // ),
            borderRadius: BorderRadius.circular(
                10.0), // Optional: Add border radius if needed
          ),
          child: Row(
            children: [
              Container(
                //  height: MediaQuery.of(context).size.height,
                //  width: MediaQuery.of(context).size.height / 16,
                child: Column(
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
              ),
              const VerticalDivider(
                color: CommonUtils.primaryTextColor,
              ),
              Expanded(child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        //width: MediaQuery.of(context).size.width / 2.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatVisitingDate(
                                  consultationslist[index].visitingDate),
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
                              consultationslist[index].consultationName,
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
                                            .phoneNumber));
                                    showTooltip(
                                        context, "Copied", mobilenumber);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(
                      //   height: 5.0,
                      // ),
                      SizedBox(
                        //width: MediaQuery.of(context).size.width / 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consultationslist[index].gender,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5f5f5f),
                              ),
                            ),
                            Text(
                              consultationslist[index].email,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF5f5f5f),
                              ),
                            ),
                            //Text('', style: CommonStyles.txSty_16black_f5),
                            // Text(consultationslist[index].gender, style: CommonStyles.txSty_16black_f5),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Flexible(
                    child: Visibility(
                      visible: consultationslist[index].remarks.isNotEmpty,
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
                ],
              )),
            ],
          ),
        )),
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
        // actions: [
        //   IconButton(
        //     icon: SvgPicture.asset(
        //       'assets/sign-out-alt.svg', // Path to your SVG asset
        //       color: const Color(0xFF662e91),
        //       width: 24, // Adjust width as needed
        //       height: 24, // Adjust height as needed
        //     ),
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //     },
        //   ),
        // ],
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = selectedDate ?? currentDate;

    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2000), // Allow dates starting from the year 2000
      lastDate: DateTime(currentDate.year + 1, currentDate.month, currentDate.day),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      print('pickedDay.toString(): ${pickedDay.toString()}');
      setState(() {
        selectedDate = pickedDay;
        _fromToDatesController.text = DateFormat('dd-MM-yyyy').format(pickedDay);
        String apiFromDate = DateFormat('yyyy-MM-dd').format(pickedDay);
        String apiToDate = DateFormat('yyyy-MM-dd').format(pickedDay);
        ConsultationData = getviewconsulationlist(apiFromDate, apiToDate);
        print('test: $selectedDate');
        print('test apiFromDate: $apiFromDate');
        print('test apiToDate: $apiToDate');
      });
    }
  }

}
