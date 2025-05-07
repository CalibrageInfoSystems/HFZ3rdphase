import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/AgentRescheduleslotscreen.dart';
import 'package:hairfixingzone/Agentappointmentlist.dart';
import 'package:hairfixingzone/Appointment.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/common_widgets.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/models/technician_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TestAgentOplist extends StatefulWidget {
  final int userId;
  final int branchId;

  const TestAgentOplist({
    super.key,
    required this.userId,
    required this.branchId,
  });

  @override
  State<TestAgentOplist> createState() => _TestAgentOplistState();
}

class _TestAgentOplistState extends State<TestAgentOplist> {
  late Future<List<Appointment>> futureAppointments;
  late List<Appointment> filterAppointments;
  late Future<List<StatusModel>> futureStatus;

  final _filterDateController = TextEditingController();
  DateTime? selectedFilterDate;
  int selectedFilterStatus = 0;
  int? statustypeId;
  bool isFilterApplied = false;
  final orangeColor = CommonUtils.primaryTextColor;

  @override
  void initState() {
    super.initState();
    futureAppointments =
        getAgentAppointments(userId: widget.userId, branchId: widget.branchId);
    futureStatus = getStatus();
    /* CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
      }
    }); */
  }

  Future<List<Appointment>> getAgentAppointments(
      {int? userId, int? branchId, String? date, int? statustypeId}) async {
    final url = Uri.parse(baseUrl + GetAppointment);
    try {
      final request = {
        "userId": userId,
        "branchId": branchId,
        "fromdate": date,
        "toDate": date,
        "statustypeId": statustypeId
      };

      final jsonResponse = await http.post(
        url,
        body: jsonEncode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('GetAppointment: $url');
      print("GetAppointment requestBody: ${jsonEncode(request)}");
      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);

        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          filterAppointments =
              listResult.map((item) => Appointment.fromJson(item)).toList();
          return filterAppointments;
        } else {
          throw Exception('No Appointments Available');
        }
      } else {
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

/*   Future<List<StatusModel>> getStatus() async {
    final response = await http.get(Uri.parse(baseUrl + getstatus));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['listResult'];
      List<StatusModel> result =
          responseData.map((json) => StatusModel.fromJson(json)).toList();
      print('fetch branchname: ${result[0].desc}');
      print('fetch branchname: ${response.body}');
      return result;
    } else {
      // throw Exception('Failed to load products');
      return [];
    }
  } */
  Future<List<StatusModel>> getStatus() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + getstatus));
      print('getStatus: ${baseUrl + getstatus}');
      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            json.decode(response.body)['listResult'];
        List<StatusModel> statusList =
            responseData.map((json) => StatusModel.fromJson(json)).toList();
        List<StatusModel> result = statusList
            .where((item) =>
                item.typeCdId != 6 &&
                item.typeCdId != 18 &&
                item.typeCdId != 34 &&
                item.typeCdId != 35 &&
                item.typeCdId != 36 &&
                item.typeCdId != 28)
            .toList();
        return result;
      } else {
        // throw Exception('Failed to load products');
        return [];
      }
    } catch (e) {
      // rethrow;
      return [];
    }
  }

  void serachFilterAppointment(String input) {
    print('serachFilterAppointment: $input');
    final result = filterAppointments.where((item) {
      return item.purposeOfVisit.toLowerCase().contains(input.toLowerCase()) ||
          item.customerName.toLowerCase().contains(input.toLowerCase()) ||
          item.name.toLowerCase().contains(input.toLowerCase());
    }).toList();

    setState(() {
      futureAppointments = Future.value(result);
    });
  }

  void refreshTheScreen() {
    CommonUtils.checkInternetConnectivity().then(
      (isConnected) {
        if (isConnected) {
          setState(() {
            futureAppointments = getAgentAppointments(
              userId: null,
              branchId: widget.branchId,
              date: selectedFilterDate.toString(),
              statustypeId: statustypeId,
            );
            isFilterApplied = false;
          });
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Please check your internet  connection', context, 1, 4);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        refreshTheScreen();
      },
      child: Scaffold(
        appBar: appBar(context),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10)
                    .copyWith(top: 10),
                child: _searchBarAndFilter(),
              ),
              Expanded(
                child: FutureBuilder(
                  future: futureAppointments,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'No Appointments Available',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Roboto",
                          ),
                        ),
                      );
                    } else {
                      final data = snapshot.data as List<Appointment>;

                      if (data.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  OpCard(
                                    data: data[index],
                                    userId: widget.userId,
                                    branchId: widget.branchId,
                                    onRefresh: () {
                                      refreshTheScreen();
                                    },
                                  ),

                                  // OpCard(data: data[index], userId: widget.userId, branchid: widget.branchid, branchaddress: widget.branchaddress),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              );
                              // return AppointmentCard(
                              //     data: data[index],
                              //     day: parseDayFromDate(data[index].date),);
                            },
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'No Appointments Available',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Roboto",
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xffe2f0fd),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: CommonUtils.primaryTextColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text(
        'Appointments',
        style: TextStyle(
          color: Color(0xFF0f75bc),
          fontSize: 16.0,
          fontFamily: "Outfit",
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _searchBarAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              onChanged: (input) => serachFilterAppointment(input),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 5, left: 12),
                hintText: 'Search Appointment',
                hintStyle: CommonStyles.texthintstyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: CommonUtils.primaryTextColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1.5,
                    color: Color.fromARGB(255, 70, 3, 121),
                  ),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: CommonUtils.primaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        //MARK: Filter
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: isFilterApplied ? const Color(0xffe2f0fd) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CommonUtils.primaryTextColor,
            ),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/filter.svg',
              color:
                  isFilterApplied ? Colors.black : CommonUtils.primaryTextColor,
              width: 24,
              height: 24,
            ),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: filterTemplate(
                    onClear: () {
                      setState(() {
                        futureAppointments = getAgentAppointments(
                            userId: widget.userId, branchId: widget.branchId);
                        clearFilter();
                      });
                    },
                    onFilter: () {
                      setState(() {
                        futureAppointments = getAgentAppointments(
                          userId: null,
                          branchId: widget.branchId,
                          date: selectedFilterDate.toString(),
                          statustypeId: statustypeId,
                        );
                        isFilterApplied = true;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void clearFilter() {
    setState(() {
      isFilterApplied = false;
      selectedFilterDate = null;
      _filterDateController.clear();

      statustypeId = null;
    });
  }

  Widget filterTemplate({void Function()? onClear, void Function()? onFilter}) {
    return StatefulBuilder(
      builder: (context, setState) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Filter By',
                  style: CommonStyles.txSty_16blu_f5,
                ),
                GestureDetector(
                  onTap: () {
                    onClear?.call();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Clear All Filters',
                    style: CommonStyles.txSty_16blu_f5,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                width: double.infinity,
                height: 0.3,
                color: CommonUtils.primaryTextColor,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _filterDateController,
                    keyboardType: TextInputType.visiblePassword,
                    onTap: () async {
                      showFilterDatePicker(context);
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
                      hintText: 'Select Date',
                      counterText: '',
                      hintStyle: CommonStyles.texthintstyle,
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: FutureBuilder(
                        future: futureStatus,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CommonUtils.primaryTextColor),
                            );
                          } else if (snapshot.hasError) {
                            return const SizedBox();
                          } else {
                            List<StatusModel> result = snapshot.data!;
                            List<StatusModel> data = result
                                .where((item) =>
                                    item.typeCdId != 6 && item.typeCdId != 18)
                                .toList();
                            return SizedBox(
                              height: 38,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: data.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  bool isSelected =
                                      index == selectedFilterStatus;
                                  StatusModel status;

                                  if (index == 0) {
                                    status = StatusModel(
                                      typeCdId: null,
                                      desc: 'All',
                                    );
                                  } else {
                                    status = data[index - 1];
                                  }
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedFilterStatus = index;
                                        statustypeId = selectedFilterStatus == 0
                                            ? null
                                            : data[selectedFilterStatus - 1]
                                                .typeCdId;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? orangeColor
                                            : orangeColor.withOpacity(0.1),
                                        border: Border.all(
                                          color: isSelected
                                              ? orangeColor
                                              : orangeColor,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: IntrinsicWidth(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    status.desc.toString(),
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "Outfit",
                                                      color: isSelected
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
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
                            'Close',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 14,
                              color: CommonUtils.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SizedBox(
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                onFilter?.call();
                                /* setState(() {
                                  futureAppointments = getAgentAppointments(
                                    userId: null,
                                    branchId: widget.branchId,
                                    date: selectedFilterDate.toString(),
                                    statustypeId: statustypeId,
                                  );
                                }); */

                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 40.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: CommonUtils.primaryTextColor,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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

  Future<void> showFilterDatePicker(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = selectedFilterDate ?? currentDate;

    final DateTime? pickedDay = await showDatePicker(
      context: context,
      initialDate: initialDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2012),
      lastDate:
          DateTime(currentDate.year + 1, currentDate.month, currentDate.day),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (pickedDay != null) {
      setState(() {
        selectedFilterDate = pickedDay;
        _filterDateController.text = DateFormat('dd-MM-yyyy').format(pickedDay);
      });
    }
  }
}

class OpCard extends StatefulWidget {
  final Appointment data;
  final int userId;
  final int? branchId;
  final VoidCallback? onRefresh;

  const OpCard({
    super.key,
    required this.data,
    required this.userId,
    this.branchId,
    this.onRefresh,
  });

  /* OpCard({
    Key? key,
    required this.data,
    required this.userId,
    required int branchid,
    required String branchaddress,
    this.onRefresh,
  }) : super(key: key); */

  @override
  State<OpCard> createState() => _OpCardState();
}

class _OpCardState extends State<OpCard> {
  late List<dynamic> dateValues;
  late Future<List<TechniciansModel>> futureTechnicians;
  final TextEditingController _commentstexteditcontroller =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();

  double rating_star = 0.0;
  int? opuserId;
  final GlobalKey _toolTipKey = GlobalKey();
  final GlobalKey _fullnameTipKey = GlobalKey();
  final GlobalKey _emailtoolTipKey = GlobalKey();

  bool _billingAmountError = false;
  String? _billingAmountErrorMsg;
  bool isBillingAmountValidate = false;

  late Future<List<StatusModel>> apiPaymentOptions;

  // late List<StatusModel> paymentOptions;
  List<dynamic> paymentOptions = [];
  List<dynamic> technicianOptions = [];
  int selectedPaymentOption = -1;
  int? selectedTechnicianOption = -1;
  int? selectedTechnicianId;
  int? apiPaymentMode;
  bool isPaymentValidate = false;
  bool isPaymentModeSelected = false;

  bool isTechnicianValidate = false;
  bool isTechnicianSelected = false;

  bool isFreeService = true;
  String? selectedPaymentMode;
  bool _isLoadingAccept = false;
  bool _isLoadingCancel = false;
  bool _isAcceptClicked = false;
  bool _isCancelClicked = false;

  @override
  void initState() {
    super.initState();

    dateValues = parseDateString(widget.data.date);
    fetchPaymentOptions();
    fetchTechnicianOptions();
    print('xxx: ${widget.data.closedTechnicianName}');
  }

  @override
  void dispose() {
    _commentstexteditcontroller.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<dynamic> parseDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    print(
        'dateFormate: ${dateTime.day} - ${DateFormat.MMM().format(dateTime)} - ${dateTime.year}');
    //         int ,       String ,                           int
    return [dateTime.day, DateFormat.MMM().format(dateTime), dateTime.year];
  }

  @override
  Widget build(BuildContext context) {
    dateValues = parseDateString(widget.data.date);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(5),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.data.slotTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Outfit",
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0f75bc),
                                  ),
                                ),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        widget.data.customerName,
                                        style: CommonStyles.txSty_16b6_fb,
                                        softWrap: true,
                                        maxLines: null,
                                      ),
                                    ),
                                    GestureDetector(
                                      key: _fullnameTipKey,
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: Icon(
                                          Icons.copy,
                                          size: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: widget.data.customerName));
                                        showTooltip(
                                            context, "Copied", _fullnameTipKey);
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 2.0,
                                ),
                                if (widget.data.email!.isNotEmpty) ...{
                                  Container(
                                    child: Row(children: [
                                      Flexible(
                                        child: RichText(
                                          text: TextSpan(
                                            text: widget.data.email ?? '',
                                            style: CommonStyles.txSty_14b_fb,
                                            children: const <TextSpan>[],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        key: _emailtoolTipKey,
                                        child: const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(5, 0, 5, 0),
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                          ),
                                        ),
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget.data.email!));
                                          showTooltip(context, "Copied",
                                              _emailtoolTipKey);
                                        },
                                      ),
                                    ]),
                                  ),
                                } else ...{
                                  const SizedBox.shrink()
                                },

                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(widget.data.purposeOfVisit,
                                    style: CommonStyles.txSty_14blu_f5),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                Text(widget.data.name,
                                    style: CommonStyles.txSty_16b_fb),
                                const SizedBox(
                                  height: 2.0,
                                ),
                                //MARK: technician
                                if (widget.data.closedTechnicianName != null &&
                                    widget.data.closedTechnicianName!
                                        .isNotEmpty) ...{
                                  Row(
                                    children: [
                                      const Text(
                                        'Technician: ',
                                        style: CommonStyles.txSty_16blu_f5,
                                      ),
                                      Text(widget.data.closedTechnicianName!,
                                          style: CommonStyles.txSty_16b_fb),
                                    ],
                                  ),
                                } else if (widget.data.technicianName != null &&
                                    widget.data.technicianName!.isNotEmpty) ...{
                                  Row(
                                    children: [
                                      const Text(
                                        'Technician: ',
                                        style: CommonStyles.txSty_16blu_f5,
                                      ),
                                      Text(widget.data.technicianName!,
                                          style: CommonStyles.txSty_16b_fb),
                                    ],
                                  ),
                                },
                                /* if (widget.data.technicianName!.isNotEmpty) ...{
                                  Row(
                                    children: [
                                      const Text(
                                        'Technician: ',
                                        style: CommonStyles.txSty_16blu_f5,
                                      ),
                                      Text(widget.data.technicianName!,
                                          style: CommonStyles.txSty_16b_fb),
                                    ],
                                  ),
                                } else ...{
                                  const SizedBox.shrink()
                                }, */

                                if (widget.data.paymentType != null)
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 2.0,
                                      ),
                                      Text(widget.data.paymentType ?? ' ',
                                          style: CommonStyles.txSty_16b_fb),
                                    ],
                                  )
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                statusBasedBgById(widget.data.statusTypeId,
                                    widget.data.status),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        makePhoneCall(
                                            'tel:+91${widget.data.phoneNumber}');
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          text: widget.data.phoneNumber,
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
                                      key: _toolTipKey,
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 0, 0, 0),
                                        child: Icon(
                                          Icons.copy,
                                          size: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: widget.data.phoneNumber!));
                                        showTooltip(
                                            context, "Copied", _toolTipKey);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 3.0,
                                ),
                                Text(widget.data.gender ?? ' ',
                                    style: CommonStyles.txSty_16b_fb),
                                const SizedBox(
                                  height: 5.0,
                                  width: 2.0,
                                ),
                                if (widget.data.price != null)
                                  Text(
                                    '₹${formatNumber(widget.data.price ?? 0)}',
                                    style: CommonStyles.txSty_16b_fb,
                                  ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                if (widget.data.rating != null)
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
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              '${widget.data.rating ?? ''}',
                                              style: CommonStyles.txSty_14g_f5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: widget.data.rating != null
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        verifyStatus(widget.data, widget.userId),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget statusBasedBgById(int statusTypeId, String status) {
    final Color statusColor;
    final Color statusBgColor;
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
        status,
        style: TextStyle(
          fontSize: 13,
          fontFamily: "Outfit",
          fontWeight: FontWeight.w500,
          color: statusColor,
        ),
      ),
    );
  }

  Future<void> _handleButtonPress(Appointment data, int? userId) async {
    // if (!isPastDate(data.date, data.slotDuration)) {
    //   setState(() {
    //     _isLoadingAccept = true; // Show loading indicator
    //
    //   });
    //
    //   print('Button 1 pressed for ${data.customerName}');
    //   await Get_ApprovedDeclinedSlots(data, 5);
    //   print('accpteedbuttonisclicked');
    //
    //   setState(() {
    //     _isLoadingAccept = false; // Hide loading indicator
    //   });
    // }
    if (_isAcceptClicked || isPastDate(data.date, data.slotDuration)) {
      // If already clicked or if the date is past, ignore this click
      print('it is clicked multiple times');
      return;
    }

    setState(() {
      _isLoadingAccept = true; // Show loading indicator
      _isAcceptClicked = true; // Set to true to disable further clicks
    });

    print('Button pressed for ${data.customerName}');

    await postAppointment(data, 5, 0.0, userId);
    await Get_ApprovedDeclinedSlots(data, 5);
    print('accepted button is clicked');

    setState(() {
      _isAcceptClicked = false;
      _isLoadingAccept = false; // Hide loading indicator
    });
  }

  Future<void> _handleButtonPressCancel(Appointment data, int? userId) async {
    // if (!isPastDate(data.date, data.slotDuration)) {
    //   conformation(context, data);
    //
    // }

    if (_isCancelClicked || isPastDate(data.date, data.slotDuration)) {
      // If already clicked or if the date is past, ignore this click
      print('it is clicked multiple times');
      return;
    }

    setState(() {
      _isLoadingCancel = true; // Show loading indicator
      _isCancelClicked = true; // Set to true to disable further clicks
    });
    conformation(context, data);

    setState(() {
      _isCancelClicked = false;
      _isLoadingCancel = false; // Hide loading indicator
    });
  }

  Widget verifyStatus(Appointment data, int? userId) {
    print(
        'date ${data.date} - slotduration ${data.slotDuration} --userId $userId');
    switch (data.statusTypeId) {
      case 4: // Submited
        //   return const SizedBox();
        // onTap: () {
        //   if (!isPastDate(data.date, data.slotDuration)) {
        //     print('Button 1 pressed for ${data.customerName}');
        //
        //     Get_ApprovedDeclinedSlots(data, 5);
        //     print('accpteedbuttonisclicked');
        //   }
        // },
        return Row(
          children: [
            // GestureDetector(
            //   onTap: () {
            //     int timeDifference =
            //     calculateTimeDifference(data.date, data.slotDuration);
            //
            //     if (timeDifference <= 15) {
            //       CommonUtils.showCustomToastMessageLong(
            //         'The Request Should Not be Rescheduled Within 1 hour Before the Slot',
            //         context,
            //         0,
            //         2,
            //       );
            //     } else {
            //       print('====?${widget.userId}');
            //       // Navigate to reschedule screen if time difference is greater than 60 minutes
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => Agentrescheduleslotscreen(
            //             userId: userId!,
            //             data: data,
            //           ),
            //         ),
            //       );
            //     }
            //   },
            //   child: IgnorePointer(
            //     ignoring: isPastDate(data.date, data.slotDuration),
            //     child: Container(
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(3),
            //         border: Border.all(
            //           color: isPastDate(data.date, data.slotDuration)
            //               ? Colors.grey
            //               : CommonStyles.primaryTextColor,
            //         ),
            //       ),
            //       padding:
            //       const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            //       child: Row(
            //         children: [
            //           SvgPicture.asset(
            //             'assets/calendar-_3_.svg',
            //             width: 13,
            //             color: isPastDate(data.date, data.slotDuration)
            //                 ? Colors.grey
            //                 : CommonUtils.primaryTextColor,
            //           ),
            //           Text(
            //             '  Reschedule',
            //             style: TextStyle(
            //               fontSize: 15,
            //               color: isPastDate(data.date, data.slotDuration)
            //                   ? Colors.grey
            //                   : CommonUtils.primaryTextColor,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   width: 10,
            // ),
            GestureDetector(
              onTap: () => _handleButtonPress(data, userId),
              child: IgnorePointer(
                ignoring: _isAcceptClicked ||
                    isPastDate(data.date, data.slotDuration),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                        color: isPastDate(data.date, data.slotDuration)
                            ? Colors.grey
                            : CommonStyles.primaryTextColor),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    children: [
                      // SvgPicture.asset(
                      //   'assets/calendar-_3_.svg',
                      //   width: 13,
                      //   color: isPastDate(data.date, data.slotDuration)
                      //       ? Colors.grey
                      //       : CommonUtils.primaryTextColor,
                      // ),
                      // Text(
                      //   '  Accept',
                      //   style: TextStyle(
                      //     fontSize: 15,
                      //     color: isPastDate(data.date, data.slotDuration)
                      //         ? Colors.grey
                      //         : CommonUtils.primaryTextColor,
                      //   ),
                      // ),
                      if (_isLoadingAccept) // Show loading indicator if loading
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CommonStyles
                                .primaryTextColor, // You can customize color
                          ),
                        )
                      else
                        SvgPicture.asset(
                          'assets/calendar-_3_.svg',
                          width: 13,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonUtils.primaryTextColor,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isLoadingAccept
                            ? 'Loading...'
                            : 'Accept', // Change text based on loading state
                        style: TextStyle(
                          fontSize: 15,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonUtils.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              // onTap: () {
              //   if (!isPastDate(data.date, data.slotDuration)) {
              //     conformation(context, data);
              //     // Add your logic here for when the 'Cancel' container is tapped
              //   }
              // },
              onTap: () => _handleButtonPressCancel(data, userId),
              child: IgnorePointer(
                ignoring: _isCancelClicked ||
                    isPastDate(data.date, data.slotDuration),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isPastDate(data.date, data.slotDuration)
                          ? Colors.grey
                          : CommonStyles.statusRedText,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    children: [
                      // SvgPicture.asset(
                      //   'assets/calendar-xmark.svg',
                      //   width: 12,
                      //   color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonStyles.statusRedText,
                      // ),
                      // Text(
                      //   '  Cancel',
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     fontFamily: "Outfit",
                      //     fontWeight: FontWeight.w500,
                      //     color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonStyles.statusRedText,
                      //   ),
                      // ),
                      if (_isLoadingCancel) // Show loading indicator if loading
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CommonStyles
                                .primaryTextColor, // You can customize color
                          ),
                        )
                      else
                        SvgPicture.asset(
                          'assets/calendar-xmark.svg',
                          width: 13,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonStyles.statusRedText,
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isLoadingCancel
                            ? 'Loading...'
                            : 'Cancel', // Change text based on loading state
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonStyles.statusRedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case 5: // Accepted

        if (isSlotTimeReached(data.date, data.slotDuration)) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  CommonWidgets.customCancelDialog(
                    context,
                    message:
                        'Are You Sure You Want to Mark as Not Visited ${data.name} Consultation?',
                    onConfirm: () {
                      postAppointment(data, 28, 0.0, userId);
                    },
                  );
                  // Add appropriate action for "Not visited" if needed
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: CommonStyles
                          .statusRedText, // Use a different color for differentiation
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/not_visted.svg',
                        width: 12,
                        color: CommonStyles.statusorangeText,
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        ' Not visited',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: CommonStyles.statusorangeText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              //MARK: Here
              GestureDetector(
                onTap: () {
                  futureTechnicians = fetchTechnicians();

                  closePopUp(context, data, userId, futureTechnicians);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: CommonStyles.statusRedText,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/calendar-xmark.svg',
                        width: 12,
                        color: CommonStyles.statusRedText,
                      ),
                      const Text(
                        ' Close',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: CommonStyles.statusRedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              GestureDetector(
                onTap: () async {
                  int timeDifference =
                      calculateTimeDifference(data.date, data.slotDuration);

                  if (timeDifference <= 15) {
                    CommonUtils.showCustomToastMessageLong(
                      'The Request Should Not be Rescheduled Within 15 minutes Before the Slot',
                      context,
                      0,
                      2,
                    );
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Agentrescheduleslotscreen(
                          userId: userId!,
                          data: data,
                        ),
                      ),
                    );
                    if (result) {
                      widget.onRefresh?.call();
                    }
                  }
                },
                child: IgnorePointer(
                  ignoring: isPastDate(data.date, data.slotDuration),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isPastDate(data.date, data.slotDuration)
                            ? Colors.grey
                            : CommonStyles.primaryTextColor,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/calendar-_3_.svg',
                          width: 13,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonUtils.primaryTextColor,
                        ),
                        Text(
                          '  Reschedule',
                          style: TextStyle(
                            fontSize: 15,
                            color: isPastDate(data.date, data.slotDuration)
                                ? Colors.grey
                                : CommonUtils.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () {
                  int timeDifference =
                      calculateTimeDifference(data.date, data.slotDuration);

                  if (timeDifference <= 15) {
                    CommonUtils.showCustomToastMessageLong(
                      'The Request Should Not be Cancelled Within 15 minutes Before the Slot',
                      context,
                      0,
                      2,
                    );
                  } else {
                    if (!isPastDate(data.date, data.slotDuration)) {
                      conformation(context, data);
                    }
                  }
                },
                child: IgnorePointer(
                  ignoring: isPastDate(data.date, data.slotDuration),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isPastDate(data.date, data.slotDuration)
                            ? Colors.grey
                            : CommonStyles.statusRedText,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/calendar-xmark.svg',
                          width: 12,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonStyles.statusRedText,
                        ),
                        Text(
                          '  Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            color: isPastDate(data.date, data.slotDuration)
                                ? Colors.grey
                                : CommonStyles.statusRedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      /*  return Row(
          children: [
            GestureDetector(
              onTap: () {
                int timeDifference =
                    calculateTimeDifference(data.date, data.slotDuration);

                if (timeDifference <= 15) {
                  CommonUtils.showCustomToastMessageLong(
                    'The Request Should Not be Rescheduled Within 15 minutes Before the Slot',
                    context,
                    0,
                    2,
                  );
                } else {
                  print('====?${widget.userId}');
                }
              },
              child: IgnorePointer(
                ignoring: isPastDate(data.date, data.slotDuration),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isPastDate(data.date, data.slotDuration)
                          ? Colors.grey
                          : CommonStyles.primaryTextColor,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/calendar-_3_.svg',
                        width: 13,
                        color: isPastDate(data.date, data.slotDuration)
                            ? Colors.grey
                            : CommonUtils.primaryTextColor,
                      ),
                      Text(
                        '  Reschedule',
                        style: TextStyle(
                          fontSize: 15,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonUtils.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                if (!isPastDate(data.date, data.slotDuration)) {
                  conformation(context, data);
                  // Add your logic here for when the 'Cancel' container is tapped
                }
              },
              child: IgnorePointer(
                ignoring: isPastDate(data.date, data.slotDuration),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isPastDate(data.date, data.slotDuration)
                          ? Colors.grey
                          : CommonStyles.statusRedText,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/calendar-xmark.svg',
                        width: 12,
                        color: isPastDate(data.date, data.slotDuration)
                            ? Colors.grey
                            : CommonStyles.statusRedText,
                      ),
                      Text(
                        '  Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Outfit",
                          fontWeight: FontWeight.w500,
                          color: isPastDate(data.date, data.slotDuration)
                              ? Colors.grey
                              : CommonStyles.statusRedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
 */

      case 6: // Declined
        return const SizedBox();
      case 17: // Closed

        if (data.review == null || data.review == '') {
          return const SizedBox();
        } else {
          return Flexible(
            child: RichText(
              text: TextSpan(
                text: 'Review ',
                style: CommonStyles.txSty_16blu_f5,
                children: <TextSpan>[
                  TextSpan(
                    text: '${data.review}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: "Outfit",
                      color: Color(0xFF5f5f5f),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      case 18: // Reschuduled
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }

  // bool isSlotTimeReached(String dateString, String slotDuration) {
  //   // Parse the date from the data
  //   DateTime parsedDate = DateTime.parse(dateString);
  //
  //   // Extract the start time from the slot duration (assuming it's in the format '09:00 PM - 10:00 PM')
  //   String startTime = slotDuration.split(' - ')[0]; // Get '09:00 PM'
  //
  //   // Parse the time using DateFormat
  //   DateTime parsedStartTime = DateFormat.jm().parse(startTime); // '09:00 PM'
  //
  //   // Create a new DateTime combining the date and the start time
  //   DateTime slotStartDateTime = DateTime(
  //     parsedDate.year,
  //     parsedDate.month,
  //     parsedDate.day,
  //     parsedStartTime.hour,
  //     parsedStartTime.minute,
  //   );
  //
  //   // Get the current time
  //   DateTime now = DateTime.now();
  //
  //   // Return true if the current time is after or equal to the slot start time
  //   return now.isAfter(slotStartDateTime);
  // }

  bool isSlotTimeReached(String slotDate, String slotDuration) {
    try {
      // Parse slotDate string to DateTime (assuming it's in a common format like "yyyy-MM-ddTHH:mm:ss")
      DateTime parsedSlotDate = DateTime.parse(slotDate).toLocal();

      // Split the slotDuration string to get the start and end times (e.g., "09:00 PM - 11:00 PM")
      List<String> times = slotDuration.split(' - ');

      // Define a date format to parse time (e.g., "hh:mm a" for "09:00 PM")
      DateFormat timeFormat = DateFormat('hh:mm a');

      // Parse the start and end times
      DateTime startTime = timeFormat.parse(times[0]);
      DateTime endTime = timeFormat.parse(times[1]);

      // Convert the parsed times to DateTime objects on the same date as parsedSlotDate
      DateTime slotStartTime = DateTime(
          parsedSlotDate.year,
          parsedSlotDate.month,
          parsedSlotDate.day,
          startTime.hour,
          startTime.minute);
      DateTime slotEndTime = DateTime(parsedSlotDate.year, parsedSlotDate.month,
          parsedSlotDate.day, endTime.hour, endTime.minute);

      // Compare the current local time with the slot's end time
      return DateTime.now().isAfter(slotEndTime);
    } catch (e) {
      // Handle any parsing or conversion errors
      print('Error: $e');
      return false; // Return false in case of an error
    }
  }

  bool isPastDate(String? selectedDate, String time) {
    final now = DateTime.now();
    // DateTime currentTime = DateTime.now();
    //  print('currentTime: $currentTime');
    //   int hours = currentTime.hour;
    //  print('current hours: $hours');
    // Format the time using a specific pattern with AM/PM
    String formattedTime = DateFormat('hh:mm a').format(now);

    final selectedDateTime = DateTime.parse(selectedDate!);
    final currentDate = DateTime(now.year, now.month, now.day);

    // Agent login chey

    bool isBeforeTime = false; // Assume initial value as true
    bool isBeforeDate = selectedDateTime.isBefore(currentDate);
    // Parse the desired time for comparison
    DateTime desiredTime = DateFormat('hh:mm a').parse(time);
    // Parse the current time for comparison
    DateTime currentTime = DateFormat('hh:mm a').parse(formattedTime);

    if (selectedDateTime == currentDate) {
      int comparison = currentTime.compareTo(desiredTime);
      print('comparison$comparison');
      // Print the comparison result
      if (comparison < 0) {
        isBeforeTime = false;
        print('The current time is earlier than 10:15 AM.');
      } else if (comparison > 0) {
        isBeforeTime = true;
      } else {
        isBeforeTime = true;
      }

      //  isBeforeTime = hours >= time;
    }

    print('isBeforeTime: $isBeforeTime');
    print('isBeforeDate: $isBeforeDate');
    return isBeforeTime || isBeforeDate;
  }

  void conformation(BuildContext context, Appointment appointments) {
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
                  'Are You Sure You Want to Cancel the Appointment at ${appointments.name} Branch for ${appointments.purposeOfVisit}?',
                  style: CommonUtils.txSty_18b_fb,
                  textAlign:
                      TextAlign.center, // Optionally, align the text center
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          actions: [
            Container(
              child: ElevatedButton(
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
            ),
            const SizedBox(width: 10), // Add spacing between buttons
            Container(
              child: ElevatedButton(
                onPressed: () {
                  cancelAppointment(appointments);
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
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelAppointment(Appointment appointmens) async {
    final url = Uri.parse(baseUrl + postApiAppointment);
    print('url==>890: $url');
    DateTime now = DateTime.now();
    String dateTimeString = now.toString();
    print('DateTime as String: $dateTimeString');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    opuserId = prefs.getInt('userId');
    print('userId CancelAppointment: $opuserId');
    //  for (MyAppointment_Model appointment in appointmens) {
    // Create the request object for each appointment
    final request = {
      "Id": appointmens.id,
      "BranchId": appointmens.branchId,
      "Date": appointmens.date,
      "SlotTime": appointmens.slotTime,
      "CustomerName": appointmens.customerName,
      "PhoneNumber":
          appointmens.phoneNumber, // Changed from appointments.phoneNumber
      "Email": appointmens.email,
      "GenderTypeId": appointmens.genderTypeId,
      "StatusTypeId": 6,
      "PurposeOfVisitId": appointmens.purposeOfVisitId,
      "PurposeOfVisit": appointmens.purposeOfVisit,
      "IsActive": true,
      "CreatedDate": dateTimeString,
      "UpdatedDate": dateTimeString,
      "UpdatedByUserId": opuserId!,
      "rating": null,
      "review": null,
      "reviewSubmittedDate": null,
      "timeofslot": appointmens.timeofSlot,
      "customerId": appointmens.customerId,
      "paymentTypeId": null
    };
    print('AddUpdatefeedback object: : ${json.encode(request)}');

    try {
      // Send the POST request for each appointment
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
          print('Request sent successfully');
          openDialogreject();
          //  fetchMyAppointments(userId);
          //  CommonUtils.showCustomToastMessageLong('Cancelled  Successfully ', context, 0, 4);
          //   Navigator.pop(context);
          // Success case
          // Handle success scenario here
        } else {
          // Failure case
          // Handle failure scenario here
          CommonUtils.showCustomToastMessageLong(
              'The Request Should Not be Cancelled Within 30 minutes Before the Slot',
              context,
              0,
              2);
        }
      } else {
        //showCustomToastMessageLong(
        // 'Failed to send the request', context, 1, 2);
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while sending : $e');
    }
    //  }
  }

  Future<void> postAppointment(
      Appointment data, int i, double? Amount, int? userId) async {
    print('22222');
    final url = Uri.parse(baseUrl + postApiAppointment);
    print('url==>890: $url');
    print('url==>userId: $userId');
    // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment');
    DateTime now = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    print('userId CancelAppointment: $userId');
    // Using toString() method
    String dateTimeString = now.toString();
    print('DateTime as String: $dateTimeString');

    // Create the request object
    final request = {
      "Id": data.id,
      "BranchId": data.branchId,
      "Date": data.date,
      "SlotTime": data.slotTime,
      "CustomerName": data.customerName,
      "PhoneNumber": data.phoneNumber,
      "Email": data.email,
      "GenderTypeId": data.genderTypeId,
      "StatusTypeId": i,
      "PurposeOfVisitId": data.purposeOfVisitId,
      "PurposeOfVisit": data.purposeOfVisit,
      "IsActive": true,
      "CreatedDate": dateTimeString,
      "UpdatedDate": dateTimeString,
      "customerId": data.customerId,
      "UpdatedByUserId": userId,
      "timeofSlot": data.timeofSlot,
      if (i == 17) "price": Amount,
      "paymentTypeId": null

      // "rating": null,
      // "review": null,
      // "reviewSubmittedDate": null,
      // "timeofslot": null,
      // "customerId":  data.c
    };
    print('Accept Or reject object: : ${json.encode(request)}');
    print('Accept Or reject object: $request');
    try {
      // Send the POST request
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json', // Set the content type header
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // Extract the necessary information
        bool isSuccess = data['isSuccess'];
        if (isSuccess == true) {
          print('Request sent successfully');
          if (i == 5) {
            openDialogaccept();
          } else if (i == 17) {
            openDialogclosed();
          } else {
            CommonUtils.showCustomToastMessageLong(
                'Customer Not visited', context, 0, 2);
            widget.onRefresh?.call();
            //  Navigator.of(context).pop();
          }
          // Success case
          // Handle success scenario here
        } else {
          // Failure case
          // Handle failure scenario here
          CommonUtils.showCustomToastMessageLong(
              'Failed to Send The Request ', context, 0, 2);
        }
      } else {
        //showCustomToastMessageLong(
        // 'Failed to send the request', context, 1, 2);
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void closePopUp(BuildContext context, Appointment data, int? userId,
      Future<List<TechniciansModel>> futureTechnicians) {
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
              data: data,
              paymentOptions: paymentOptions,
              technicianOptions: technicianOptions,
              onSubmit: (paymentMode, billingAmount, technicianId) {
                Navigator.of(context).pop();
                selectedTechnicianId = technicianId;
                _priceController.text = billingAmount.toString();
                apiPaymentMode = paymentMode;
                print('xxx: $selectedTechnicianId');

                postCloseAppointment(
                    data,
                    17,
                    double.tryParse(billingAmount ?? '0.0'),
                    paymentMode,
                    userId,
                    technicianId);
              },
            )

            /*     Container(
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

                          //MARK: Close Btn
                          GestureDetector(
                            onTap: () {
                              selectedPaymentOption = -1;
                              selectedTechnicianOption = -1;
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
                                      data: data.customerName,
                                      title: 'Customer Name'),

                                  const SizedBox(height: 5),
                                  customRow(
                                      data: DateFormat('dd-MM-yyyy hh:mm a')
                                          .format(DateTime.parse(data.date)),
                                      // data: DateFormat('dd-MM-yyyy')
                                      //     .format(DateTime.parse(data.date)),
                                      title: 'Slot Time'),

                                  const SizedBox(height: 5),
                                  customRow(
                                      data: data.purposeOfVisit,
                                      title: 'Purpose of Visit'),

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
                                    technicianDropDown(context, setState, data),
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
                                    setState(() {
                                      validatePaymentMode();
                                      validateTechnician();
                                    });
                                    print(
                                        'formValidation: ${_formKey.currentState!.validate()}  | $isPaymentValidate | $isTechnicianValidate | $isBillingAmountValidate');
                                    if (_formKey.currentState!.validate() &&
                                        isPaymentValidate &&
                                        isTechnicianValidate &&
                                        isBillingAmountValidate) {
                                      double? price = double.tryParse(
                                          _priceController.text);
                                      postCloseAppointment(data, 17, price!,
                                          apiPaymentMode, userId);
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
       */

            );
      },
    );
  }

  Padding technicianDropDown(
      BuildContext context, StateSetter setState, Appointment data) {
    print('www4 technician: ${data.technicianName}');

    if (data.technicianName != null && data.technicianName!.isNotEmpty) {
      selectedTechnicianOption = technicianOptions.length + 1;
    }

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
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<int>(
              value: selectedTechnicianOption,
              iconSize: 30,
              hint: const Text(
                'Select Technician',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              icon: null,
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  selectedTechnicianOption = value;

                  if (value != null && value != technicianOptions.length + 1) {
                    selectedTechnicianId = technicianOptions[value]['id'];
                  } else if (value != null &&
                      value == technicianOptions.length + 1) {
                    selectedTechnicianId = data.technicianId;
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
                if (data.technicianName != null &&
                    data.technicianName!.isNotEmpty)
                  DropdownMenuItem<int>(
                    value: technicianOptions.length + 1,
                    child: Text(
                      '${data.technicianName}',
                    ),
                  ),
                ...technicianOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(item['userName']),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validateTechnician() {
    print('validateTechnician: $selectedPaymentOption | $selectedTechnicianId');
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
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<int>(
              value: selectedPaymentOption,
              iconSize: 30,
              icon: null,
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    selectedPaymentOption = value;
                    if (paymentOptions[value]['typeCdId'] == 23) {
                      isFreeService = false;
                      _priceController.text = '0.0';
                    } else {
                      _priceController.clear();
                      isFreeService = true;
                    }

                    apiPaymentMode =
                        paymentOptions[selectedPaymentOption]['typeCdId'];
                    selectedPaymentMode =
                        paymentOptions[selectedPaymentOption]['desc'];
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
                    child: Text(item['desc']),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

/*   Row customRow({required String title, required String data}) {
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
        const Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                ': Buttons will now automatically wrap to the next line if there’s not enough horizontal space. ',
                style: TextStyle(
                  color: CommonStyles.primaryTextColor,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                ),
                softWrap: true, // Enables text wrapping
                overflow: TextOverflow
                    .visible, // Ensures text is visible when wrapped
              ),

              /*  Text(
                ': Buttons will now automatically wrap to the next line if there’s not enough horizontal space. ',
                // ': $data',
                style: TextStyle(
                  color: CommonStyles.primaryTextColor,
                  fontSize: 14,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                ),
              ), */
            ],
          ),
        ),
      ],
    );
  } */

  Row customRow({required String title, required String data}) {
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
            data,
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

  void openDialogreject() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
                width: 100,
                child: Image.asset('assets/rejected.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              const Center(
                // Center the text
                child: Text(
                  'Your Appointment Has Been Cancelled Successfully ',
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
                  // Refresh the screen
                  widget.onRefresh?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /*  String? validateAmount(String? value) {
    print('validate 3333');
    if (value == null || value.isEmpty) {
      return 'Please Enter Billing Amount (Rs)';
    }
    return null;
  } */

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

  void openDialogaccept() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
                width: 130,
                child: Image.asset('assets/checked.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              const Center(
                // Center the text
                child: Text(
                  'Your Appointment Has Been Accepted Successfully ',
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
                  widget.onRefresh?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void openDialogclosed() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
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
                width: 130,
                child: Image.asset('assets/checked.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              const Center(
                // Center the text
                child: Text(
                  'Your Appointment Has Been Closed Successfully ',
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
                  widget.onRefresh?.call();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String formatCancelDialogDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    return formattedDate;
  }

  bool displayCloseBtn(String slotDateValue, String slotTimeValue) {
    DateTime now = DateTime.now();
    DateFormat timeFormat = DateFormat.jm();
    DateTime parsedSlotTime = timeFormat.parse(slotTimeValue);

    DateTime slotDate = DateTime.parse(slotDateValue);

    DateTime slotDateTime = DateTime(slotDate.year, slotDate.month,
        slotDate.day, parsedSlotTime.hour, parsedSlotTime.minute);

    if (slotDateTime.isAtSameMomentAs(now) || slotDateTime.isAfter(now)) {
      print("Slot is equal to or after current date and time");
      return false;
    } else {
      print("Slot is before current date and time");
      return false;
    }
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  Future<void> fetchPaymentOptions() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + getPaymentMode));
      print('fetchPaymentOptions: $response');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          paymentOptions = data['listResult'];
          print('paymentOptions: ${paymentOptions.length}');
        });
        return;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchTechnicianOptions() async {
    try {
      final requestBody = jsonEncode({
        "branchId": widget.data.branchId,
        "date": widget.data.date,
        "slot": widget.data.slotTime
      });
      final response = await http.post(
        Uri.parse(baseUrl + getTechnicians),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );
      print('fetchTechnicianOptions: ${baseUrl + getTechnicians}');
      print('fetchTechnicianOptions data: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['listResult'] == null) {
          setState(() {
            technicianOptions = [];
          });
          return;
        }
        setState(() {
          technicianOptions = data['listResult'];
        });
        return;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  Future<void> postCloseAppointment(
      Appointment data,
      int i,
      double? billingAmount,
      int? paymentTypeId,
      int? userId,
      int? technicianId) async {
    final url = Uri.parse(baseUrl + postApiAppointment);

    // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment');
    DateTime now = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    // Using toString() method
    String dateTimeString = now.toString();

    // Create the request object
    final request = {
      "Id": data.id,
      "BranchId": data.branchId,
      "Date": data.date,
      "SlotTime": data.slotTime,
      "CustomerName": data.customerName,
      "PhoneNumber": data.phoneNumber,
      "Email": data.email,
      "GenderTypeId": data.genderTypeId,
      "StatusTypeId": i,
      "PurposeOfVisitId": data.purposeOfVisitId,
      "PurposeOfVisit": data.purposeOfVisit,
      "IsActive": true,
      "CreatedDate": dateTimeString,
      "UpdatedDate": dateTimeString,
      "customerId": data.customerId,
      "UpdatedByUserId": userId,
      "timeofSlot": data.timeofSlot,
      if (i == 17) "price": billingAmount,
      "paymentTypeId": paymentTypeId,
      "technicianId": technicianId,
    };
    print('xxx: ${jsonEncode(request)}');
    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      // Check the response status code
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // Extract the necessary information
        bool isSuccess = data['isSuccess'];
        if (isSuccess == true) {
          print('Request sent successfully');
          if (i == 5) {
            openDialogaccept();
          } else if (i == 17) {
            openDialogclosed();
          }
          // Success case
          // Handle success scenario here
        } else {
          // Failure case
          // Handle failure scenario here
          CommonUtils.showCustomToastMessageLong(
              'Failed to Send The Request ', context, 0, 2);
        }
      } else {
        //showCustomToastMessageLong(
        // 'Failed to send the request', context, 1, 2);
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
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

  Future<void> makePhoneCall(String phoneNumber) async {
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  int calculateTimeDifference(String selectedDate, String time) {
    final now = DateTime.now();
    String formattedTime = DateFormat('yyyy-MM-dd hh:mm a').format(now);

    // Extract the date part (first 10 characters) from selectedDate
    String datePart = selectedDate.substring(0, 10);

    // Concatenate datePart and time
    String selectedDateTimeString = '$datePart $time';

    // Parse the concatenated string into a DateTime object
    DateTime selectedDateTime =
        DateFormat('yyyy-MM-dd hh:mm a').parse(selectedDateTimeString);
    DateTime currentDateTime =
        DateFormat('yyyy-MM-dd hh:mm a').parse(formattedTime);

    print(
        'Time difference in selectedDateTime: ${selectedDateTime.toString()}');
    print('Time difference in currentDateTime: ${currentDateTime.toString()}');

    Duration difference = selectedDateTime.difference(currentDateTime);
    int differenceInMinutes = difference.inMinutes;

    print('Time difference in minutes: $differenceInMinutes');

    return differenceInMinutes
        .abs(); // Return the absolute value of the difference
  }

  Future<List<TechniciansModel>> fetchTechnicians() async {
    try {
      final apiUrl = Uri.parse(baseUrl + getTechnicians);
      final requestBody = jsonEncode({
        "branchId": widget.data.branchId,
        "date": widget.data.date,
        "slot": widget.data.slotTime
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
}

class StatusModel {
  final int? typeCdId;
  final String desc;

  StatusModel({required this.typeCdId, required this.desc});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      typeCdId: json['typeCdId'],
      desc: json['desc'],
    );
  }
}

class CloseConsulationCard extends StatefulWidget {
  final Appointment data;
  final List<dynamic> paymentOptions;
  final List<dynamic> technicianOptions;
  final void Function(
      int? paymentMode, String? billingAmount, int? technicianId)? onSubmit;
  const CloseConsulationCard(
      {super.key,
      required this.data,
      required this.paymentOptions,
      required this.technicianOptions,
      this.onSubmit});

  @override
  State<CloseConsulationCard> createState() => _CloseConsulationCardState();
}

class _CloseConsulationCardState extends State<CloseConsulationCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
/*   late Future<List<PaymentTypesModel>> futurePaymentTypes;
  late Future<List<TechniciansModel>> futureTechnicians; */
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

  @override
  void initState() {
    super.initState();
    setInitialTechnician(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xffffffff),
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
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

                    //MARK: Close Btn
                    GestureDetector(
                      onTap: () {
                        selectedPaymentOption = -1;
                        selectedTechnicianOption = -1;
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
                                  data: widget.data.customerName,
                                  title: 'Customer Name'),

                              const SizedBox(height: 5),
                              customRow(
                                  data:
                                      '${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.data.date))} ${widget.data.slotTime}',
                                  // data: DateFormat('dd-MM-yyyy')
                                  //     .format(DateTime.parse(data.date)),
                                  title: 'Slot Time'),

                              const SizedBox(height: 5),
                              customRow(
                                  data: widget.data.purposeOfVisit,
                                  title: 'Purpose of Visit'),

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
                              paymentModeDropDown(
                                  context, setState, widget.paymentOptions),
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
                                          color:
                                              Color.fromARGB(255, 175, 15, 4),
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
                                technicianDropDown(
                                    context, setState, widget.data),
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
                                            color:
                                                Color.fromARGB(255, 175, 15, 4),
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
                                      RegExp(r'^\d*\.?\d{0,2}')),
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
                                setState(() {
                                  validatePaymentMode();
                                  validateTechnician();
                                });
                                print(
                                    'formValidation: ${_formKey.currentState!.validate()}  | $isPaymentValidate | $isTechnicianValidate | $isBillingAmountValidate');
                                if (_formKey.currentState!.validate() &&
                                    isPaymentValidate &&
                                    isTechnicianValidate &&
                                    isBillingAmountValidate) {
                                  /* double? price = double.tryParse(
                                            _priceController.text);
                                        postCloseAppointment(widget.data, 17, price!,
                                            apiPaymentMode, userId);
                                        Navigator.of(context).pop(); */
                                  widget.onSubmit?.call(
                                    selectedPaymentOption == -1
                                        ? null
                                        : apiPaymentMode,
                                    _priceController.text.trim(),
                                    selectedTechnicianId,
                                  );
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
          );
        },
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

  Padding paymentModeDropDown(BuildContext context, StateSetter setState,
      List<dynamic> paymentOptions) {
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
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<int>(
              value: selectedPaymentOption,
              iconSize: 30,
              icon: null,
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  if (value != null) {
                    selectedPaymentOption = value;
                    if (paymentOptions[value]['typeCdId'] == 23) {
                      isFreeService = false;
                      _priceController.text = '0.0';
                    } else {
                      _priceController.clear();
                      isFreeService = true;
                    }

                    apiPaymentMode =
                        paymentOptions[selectedPaymentOption]['typeCdId'];
                    selectedPaymentMode =
                        paymentOptions[selectedPaymentOption]['desc'];
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
                    child: Text(item['desc']),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* Padding technicianDropDown(
      BuildContext context, StateSetter setState, Appointment data) {
    print('www4 technician: ${data.technicianName}');

    if (data.technicianName != null && data.technicianName!.isNotEmpty) {
      selectedTechnicianOption = widget.technicianOptions.length + 1;
    }

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
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<int>(
              value: selectedTechnicianOption,
              iconSize: 30,
              hint: const Text(
                'Select Technician',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              icon: null,
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  selectedTechnicianOption = value;
print('selectedTechnicianOption: $value');
                  if (value != null &&
                      value != widget.technicianOptions.length + 1) {
                    selectedTechnicianId =
                        widget.technicianOptions[value]['id'];
                  } else if (value != null &&
                      value == widget.technicianOptions.length + 1) {
                    selectedTechnicianId = data.technicianId;
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
                if (data.technicianName != null &&
                    data.technicianName!.isNotEmpty)
                  DropdownMenuItem<int>(
                    value: widget.technicianOptions.length + 1,
                    child: Text(
                      '${data.technicianName}',
                    ),
                  ),
                ...widget.technicianOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(item['userName']),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
 */
  void setInitialTechnician(Appointment data) {
    if (data.technicianName != null && data.technicianName!.isNotEmpty) {
      selectedTechnicianOption = widget.technicianOptions.length;
      selectedTechnicianId = data.technicianId;
    } else {
      selectedTechnicianOption = -1;
    }
  }

  Padding technicianDropDown(
      BuildContext context, StateSetter setState, Appointment data) {
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
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<int>(
              value: selectedTechnicianOption,
              iconSize: 30,
              hint: const Text(
                'Select Technician',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              icon: null,
              style: const TextStyle(
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  selectedTechnicianOption = value;
                  if (value != null &&
                      value != -1 &&
                      value != widget.technicianOptions.length) {
                    print('selectedTechnicianOption: 111');
                    selectedTechnicianId =
                        widget.technicianOptions[value]['id'];
                  } else if (value != null &&
                      value != -1 &&
                      value == widget.technicianOptions.length) {
                    print('selectedTechnicianOption: 2222');
                    selectedTechnicianId = data.technicianId;
                  }
                  print(
                      'selectedTechnicianOption: $value | $selectedTechnicianId');
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
                if (data.technicianName != null &&
                    data.technicianName!.isNotEmpty)
                  DropdownMenuItem<int>(
                    value: widget.technicianOptions.length,
                    child: Text(
                      '${data.technicianName}',
                    ),
                  ),
                ...widget.technicianOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(item['firstName']),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
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
    print('validateTechnician: $selectedPaymentOption | $selectedTechnicianId');
    if (selectedTechnicianId == null || selectedTechnicianOption == -1) {
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
}
