import 'dart:convert';
import 'dart:math';

import 'package:calendar_date_picker2/src/models/calendar_date_picker2_config.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';

import 'package:hairfixingzone/slotbookingscreen.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'AgentAppointmentsProvider.dart';
import 'AgentHome.dart';
import 'AgentRescheduleslotscreen.dart';
import 'Appointment.dart';
import 'BranchModel.dart';
import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'Commonutils.dart';
import 'CustomCalendarDialog.dart';
import 'MyAppointment_Model.dart';
import 'Rescheduleslotscreen.dart';
import 'api_config.dart';

class Agentappointmentlist extends StatefulWidget {
  final int userId;
  final int branchid;
  final String branchname;
  final String filepath;
  final String phonenumber;
  final String branchaddress;

  const Agentappointmentlist(
      {super.key,
      required this.userId,
      required this.branchid,
      required this.branchname,
      required this.filepath,
      required this.phonenumber,
      required this.branchaddress});

  @override
  MyAppointments_screenState createState() => MyAppointments_screenState();
}

class MyAppointments_screenState extends State<Agentappointmentlist> {
  Future<List<Appointment>>? apiData;
  List<Appointment> temp = [];
  int? agentUserId;
  int? branchid;

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
        checkLoginuserdata();

        print('UserID==${widget.userId}');
      } else {
        print('The Internet Is not Connected');
      }
    });
  }

  void checkLoginuserdata() async {
    myAppointmentsProvider!.clearFilter();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    agentUserId = prefs.getInt('userId')!;
    print('userId: 1 $agentUserId');
    print('userId: 2 ${widget.userId}');

    initializeData(agentUserId);
  }

  void initializeData(int? userId) {
    setState(() {
      //   apiData = fetchagentAppointments(userId, widget.branchid);
      apiData = fetchagentAppointments(userId, widget.branchid);
      apiData!.then((value) {
        myAppointmentsProvider!.storeIntoProvider = value;
        temp.addAll(value);
      }).catchError((error) {
        print('catchError: Error occurred.');
      });
    });
  }

  Future<List<Appointment>> fetchagentAppointments(
      int? userId, int branchid) async {
    final url = Uri.parse(baseUrl + GetAppointment);
    // {"userId":8,"branchId":2,"fromDate":"2024-05-01","toDate":"2024-05-17","statusTypeId":null}
    print('GetAppointment$url');
    try {
      /// final request = {"userId": userId, "branchId": branchid, "fromdate": null, "toDate": null, "statustypeId": null};
      final request = {
        "userId": null,
        "branchId": branchid,
        "fromdate": null,
        "toDate": null,
        "statustypeId": null
      };
      //   final request = {"userId": userId, "branchId": branchid, "fromdate":"2024-05-01", "toDate": "2024-05-17", "statustypeId": null};

      final jsonResponse = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("GetAppointment requestBody: ${jsonEncode(request)}");
      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);

        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          List<Appointment> result =
              listResult.map((item) => Appointment.fromJson(item)).toList();
          return result;
        } else {
          myAppointmentsProvider!.storeIntoProvider = [];
          throw Exception('No Appointments Available');
        }
      } else {
        print('Request failed with status: ${jsonResponse.statusCode}');
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (error) {
      print('catch: $error');
      rethrow;
    }
  }

  void refreshTheScreen() {
    CommonUtils.checkInternetConnectivity().then(
      (isConnected) {
        if (isConnected) {
          print('The Internet Is Connected');

          try {
            // reload the data
            checkLoginuserdata();
            setState(() {});
          } catch (error) {
            print('catch: $error');
            rethrow;
          }
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Please check your internet  connection', context, 1, 4);
          print('The Internet Is not  Connected');
        }
      },
    );
  }

  // void refreshTheScreen() {
  //   setState(() {
  //     apiData = fetchagentAppointments(userId, widget.branchid);
  //   });
  // }

  AgentAppointmentsProvider? myAppointmentsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    myAppointmentsProvider = Provider.of<AgentAppointmentsProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgentHome(
              userId: widget.userId,
            ),
          ),
        );
        myAppointmentsProvider!.clearFilter();
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          refreshTheScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xffe2f0fd),
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
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: CommonUtils.primaryTextColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                myAppointmentsProvider!.clearFilter();
              },
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Consumer<AgentAppointmentsProvider>(
              builder: (context, provider, _) => WillPopScope(
                onWillPop: () async {
                  provider.clearFilter();
                  return true;
                },
                child: Column(
                  children: [
                    // search and filter
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10)
                          .copyWith(top: 10),
                      child: _searchBarAndFilter(),
                    ),

                    //MARK: Appointment
                    Expanded(
                      child: FutureBuilder(
                        future: apiData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                            List<Appointment> data = provider.proAppointments;
                            print('datasize ${data.length}');
                            print('widget.userId ${widget.userId}');

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
                                          branchid: widget.branchid,
                                          branchaddress: widget.branchaddress,
                                          onRefresh: () {
                                            // Implement the refresh logic here
                                            setState(() {
                                              // Refresh logic
                                              refreshTheScreen();
                                            });
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
          ),
        ),
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
              onChanged: (input) => filterAppointment(input),
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
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: myAppointmentsProvider!.filterStatus
                ? const Color(0xffe2f0fd)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CommonUtils.primaryTextColor,
            ),
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/filter.svg',
              color: myAppointmentsProvider!.filterStatus
                  ? Colors.black
                  : CommonUtils.primaryTextColor,
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
                  child: FilterAppointmentBottomSheet(
                      userId: widget.userId, branchid: widget.branchid),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  int parseDayFromDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    print(
        'dateFormate: ${dateTime.day} - ${DateFormat.MMM().format(dateTime)} - ${dateTime.year}');
    // int ,       String ,                           int
    return dateTime
        .day; //[dateTime.day, DateFormat.MMM().format(dateTime), dateTime.year];
  }

  void filterAppointment(String input) {
    myAppointmentsProvider!.filterProviderData(temp.where((item) {
      return item.purposeOfVisit.toLowerCase().contains(input.toLowerCase()) ||
          item.customerName.toLowerCase().contains(input.toLowerCase()) ||
          item.name.toLowerCase().contains(input.toLowerCase());
      // ||
      // item.email!.toLowerCase().contains(input.toLowerCase());
    }).toList());
  }
}

class FilterAppointmentBottomSheet extends StatefulWidget {
  final int? userId;
  final int? branchid;

  const FilterAppointmentBottomSheet(
      {Key? key, required this.userId, required this.branchid})
      : super(key: key);

  @override
  State<FilterAppointmentBottomSheet> createState() =>
      _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterAppointmentBottomSheet> {
  List<BranchModel> products = [];
  late Future<List<BranchModel>> branchname;
  BranchModel? selectedCategory;

  final orangeColor = CommonUtils.primaryTextColor;
  late Future<List<BranchModel>> apiData;
  final TextEditingController _fromToDatesController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  FocusNode DateofBirthdFocus = FocusNode();
  List<Statusmodel> statusoptions = [];
  late Future<List<Statusmodel>> prostatus;
  Statusmodel? selectedstatus;
  String? apiFromDate;
  String? apiToDate;
  DateTime? selectedDate;

  // List<String>? selectedDate;
  //   DateTime? selectDateFromDatePicker;

  AgentAppointmentsProvider? myAppointmentsProvider;

  static TextStyle anniversaryTextStyle = TextStyle(
    color: Colors.red[400],
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  @override
  void initState() {
    super.initState();

    apiData = fetchbranches(widget.userId);
    prostatus = fetchstatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    myAppointmentsProvider = Provider.of<AgentAppointmentsProvider>(context);
    _fromToDatesController.text = myAppointmentsProvider!.getDisplayDate;
  }

  String formateDate(String date) {
    DateTime dateTime = DateFormat('dd-MM-yyyy').parse(date);

    // Format the DateTime to the desired output format
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  }

  Future<void> filterAppointments(Map<String, dynamic> requestBody) async {
    // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment/GetAppointment');
    final url = Uri.parse(baseUrl + GetAppointment);
    print('filterAppointments: $requestBody');
    try {
      Map<String, dynamic> request = requestBody;

      final jsonResponse = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('request object490 ${json.encode(request)}');
      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);

        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          myAppointmentsProvider!.storeIntoProvider =
              listResult.map((item) => Appointment.fromJson(item)).toList();
        } else {
          myAppointmentsProvider!.storeIntoProvider = [];
          throw Exception('No Appointments Available');
        }
      } else {
        myAppointmentsProvider!.storeIntoProvider = [];
        print('Request failed with status: ${jsonResponse.statusCode}');
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (error) {
      print('catch: $error');
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentAppointmentsProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        child: Padding(
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
                      clearFilterAppointments({
                        "userid": null,
                        "branchId": widget.branchid,
                        "fromdate": null,
                        "toDate": null,
                        "statustypeId": null,
                      });
                    },
                    //MARK: Clear all filters
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
                      controller: _fromToDatesController,
                      keyboardType: TextInputType.visiblePassword,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(
                            FocusNode()); // to prevent the keyboard from appearing
                        /*  final values = await showCustomCalendarDialog(
                            context, CommonStyles.config);
                        if (values != null) {
                          setState(() {
                            selectedDate = _getValueText(
                                CommonStyles.config.calendarType, values);
                            provider.getDisplayDate =
                                '${selectedDate![0]}  -  ${selectedDate![1]}';
                            provider.getApiFromDate = selectedDate![0];
                            provider.getApiToDate = selectedDate![1];
                          });
                        } */
                        _selectDate(context, provider);
                      },
                      focusNode: DateofBirthdFocus,
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
                        hintText: 'xx',
                        counterText: "",
                        hintStyle: CommonStyles.texthintstyle,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      //  validator: validatePassword,
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    //MARK: Filter Status
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FutureBuilder(
                          future: prostatus,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.transparent,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(orangeColor),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<Statusmodel> data = snapshot.data!;
                              return SizedBox(
                                height: 38,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: data.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    bool isSelected =
                                        index == provider.selectedstatus;
                                    Statusmodel status;

                                    if (index == 0) {
                                      status = Statusmodel.StatusModel(
                                        typeCdId: null,
                                        desc: 'All',
                                      );
                                    } else {
                                      status = data[index - 1];
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          provider.selectedStatus = index;

                                          // provider.getStatus = status.typeCdId;
                                          provider.getApiStatusTypeId =
                                              status.typeCdId;
                                          print(
                                              'filter: ${provider.getStatus}');
                                          print(
                                              'Filter status.typeCdId: ${status.typeCdId}');
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
                                onTap: () {
                                  //MARK: Filter
                                  filterAppointments({
                                    "userId": null,
                                    "branchId": widget.branchid,
                                    "fromdate":
                                        myAppointmentsProvider?.getApiFromDate,
                                    "toDate":
                                        myAppointmentsProvider?.getApiToDate,
                                    "statustypeId": myAppointmentsProvider
                                        ?.getApiStatusTypeId,
                                  }).whenComplete(
                                      () => provider.filterStatus = true);
                                },
                                child: Container(
                                  // width: desiredWidth * 0.9,
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
      ),
    );
  }

  Future<List<Statusmodel>> fetchstatus() async {
    final response = await http.get(Uri.parse(baseUrl + getstatus));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['listResult'];
      List<Statusmodel> result =
          responseData.map((json) => Statusmodel.fromJson(json)).toList();
      print('fetch branchname: ${result[0].desc}');
      return result;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<BranchModel>> fetchbranches(userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl$GetBranchByUserId$userId/null'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['listResult'];
      List<BranchModel> result =
          responseData.map((json) => BranchModel.fromJson(json)).toList();
      print('fetch branchname: ${result[0].name}');
      return result;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> clearFilterAppointments(Map<String, dynamic> requestBody) async {
    //   final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment/GetAppointment');
    final url = Uri.parse(baseUrl + GetAppointment);
    try {
      Map<String, dynamic> request = requestBody;

      final jsonResponse = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);

        if (response['listResult'] != null) {
          List<dynamic> listResult = response['listResult'];
          myAppointmentsProvider!.storeIntoProvider =
              listResult.map((item) => Appointment.fromJson(item)).toList();
        } else {
          myAppointmentsProvider!.storeIntoProvider = [];
          throw Exception('No Appointments Available');
        }
      } else {
        myAppointmentsProvider!.storeIntoProvider = [];
        print('Request failed with status: ${jsonResponse.statusCode}');
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (error) {
      print('catch: $error');
    }
    Navigator.of(context).pop();
    myAppointmentsProvider!.clearFilter();
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

  Future<void> _selectDate(
      BuildContext context, AgentAppointmentsProvider provider) async {
    final DateTime currentDate = DateTime.now();
    final DateTime initialDate = selectedDate ?? currentDate;

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
      print('pickedDay.toString(): ${pickedDay.toString()}');
      setState(() {
        selectedDate = pickedDay;
        provider.getDisplayDate = pickedDay.toString();
        provider.getApiFromDate = pickedDay.toString();
        provider.getApiToDate = pickedDay.toString();
      });
    }
  }
}

class UserFeedback {
  double? ratingstar;
  String comments;

  UserFeedback({required this.ratingstar, required this.comments});
}

class OpCard extends StatefulWidget {
  final Appointment data;
  int userId;
  int? branchid;
  String? branchaddress;
  final VoidCallback? onRefresh;

  OpCard({
    Key? key,
    required this.data,
    required this.userId,
    required int branchid,
    required String branchaddress,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<OpCard> createState() => _OpCardState();
}

class _OpCardState extends State<OpCard> {
  late List<dynamic> dateValues;
  final TextEditingController _commentstexteditcontroller =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();

  double rating_star = 0.0;
  int? opuserId;
  final GlobalKey _toolTipKey = GlobalKey();
  final GlobalKey _fullnameTipKey = GlobalKey();
  final GlobalKey _emailtoolTipKey = GlobalKey();
  late Future<List<Statusmodel>> apiPaymentOptions;

  // late List<Statusmodel> paymentOptions;
  List<dynamic> paymentOptions = [];
  int selectedPaymentOption = -1;
  int? apiPaymentMode;
  bool isPaymentValidate = false;
  bool isPaymentModeSelected = false;
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
    print('userid===userId,$dateValues');
    print('userid===userId,$opuserId');
    print('widget===userId,${widget.userId}');
    fetchPaymentOptions();
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
            // height: widget.data.statusTypeId == 4 || widget.data.statusTypeId == 6
            //     ? 150
            //     : 180,
            //   height: 150,
            padding: const EdgeInsets.all(5),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            decoration: BoxDecoration(
              color: const Color(0xffe2f0fd),
              borderRadius: BorderRadius.circular(5.0),
              // border: Border.all(
              //   color: Colors.grey,
              //   width: 1.0, // Set the border width
              // ),
            ),
            child: Row(
              children: [
                SizedBox(
                  //  height: MediaQuery.of(context).size.height,
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
                          // letterSpacing: 1.5,
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
                      // const Divider(
                      //   color: CommonUtils.primaryTextColor, // You can change the color as per your requirement
                      //   thickness: 1, // You can change the thickness as per your requirement
                      //   height: 20, // You can adjust the height as per your requirement
                      // ),
                      // Builder(
                      //   builder: (context) {
                      //     final parts = widget.data.slotDuration.split(' ');
                      //     final time = parts[0];
                      //     final period = parts.length > 1 ? parts[1] : '';
                      //     return Column(
                      //       children: [
                      //         Text(
                      //           time,
                      //           style: const TextStyle(
                      //             fontSize: 18,
                      //             fontFamily: "Outfit",
                      //             fontWeight: FontWeight.w700,
                      //             color: Color(0xFF0f75bc),
                      //           ),
                      //         ),
                      //         Text(
                      //           period,
                      //           style: const TextStyle(
                      //             fontSize: 18,
                      //             fontFamily: "Outfit",
                      //             fontWeight: FontWeight.w700,
                      //             color: Color(0xFF0f75bc),
                      //           ),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),
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
                              child: Container(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                    // Row(children: [
                                    //   Text(widget.data.customerName, style: CommonStyles.txSty_16b6_fb),
                                    //   GestureDetector(
                                    //     key: _fullnameTipKey,
                                    //     child: const Padding(
                                    //       padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    //       child: Icon(
                                    //         Icons.copy,
                                    //         size: 16,
                                    //       ),
                                    //     ),
                                    //     onTap: () {
                                    //       Clipboard.setData(ClipboardData(text: widget.data.customerName));
                                    //       showTooltip(context, "Copied", _fullnameTipKey);
                                    //     },
                                    //   ),
                                    // ]),
                                    Row(
                                      // crossAxisAlignment: CrossAxisAlignment.start,  // Aligns content to the top
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.data.customerName,
                                            style: CommonStyles.txSty_16b6_fb,
                                            softWrap:
                                                true, // Allows text to wrap
                                            maxLines:
                                                null, // No limit on the number of lines
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
                                                text:
                                                    widget.data.customerName));
                                            showTooltip(context, "Copied",
                                                _fullnameTipKey);
                                          },
                                        ),
                                      ],
                                    ),

                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    if (widget.data.email!.isNotEmpty) ...{
                                      Container(
                                        // width: MediaQuery.of(context).size.width / 3.5,
                                        child: Row(children: [
                                          Flexible(
                                            child: RichText(
                                              text: TextSpan(
                                                text: widget.data.email ?? '',
                                                style:
                                                    CommonStyles.txSty_14b_fb,
                                                children: const <TextSpan>[],
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            key: _emailtoolTipKey,
                                            child: const Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5, 0, 5, 0),
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
                                      SizedBox.shrink()
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
                                    //    if (widget.data.technicianName != null)
                                    if (widget
                                        .data.technicianName!.isNotEmpty) ...{
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
                                      SizedBox.shrink()
                                    },

                                    const SizedBox(
                                      height: 2.0,
                                    ),
                                    if (widget.data.paymentType != null)
                                      Text(widget.data.paymentType ?? ' ',
                                          style: CommonStyles.txSty_16b_fb),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  statusBasedBgById(widget.data.statusTypeId,
                                      widget.data.status),
                                  const SizedBox(height: 2.0),

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

                                  //    Text(widget.data.gender!, style: CommonStyles.txSty_16black_f5),
                                  const SizedBox(
                                    height: 5.0,
                                    width: 2.0,
                                  ),
                                  if (widget.data.price != null)
                                    Text(
                                      '₹${formatNumber(widget.data.price ?? 0)}',
                                      style: CommonStyles.txSty_16b_fb,
                                    ),

                                  //    Text(widget.data.gender!, style: CommonStyles. ),
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
                                              color:
                                                  CommonStyles.statusGreenText,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right:
                                                      8.0), // Adjust the value as needed
                                              child: Text(
                                                '${widget.data.rating ?? ''}',
                                                style:
                                                    CommonStyles.txSty_14g_f5,
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

                      // based on status hide this row
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
        ));
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
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
      child: Row(
        children: [
          // statusBasedBgById(widget.data.statusTypeId),
          Text(
            status,
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

  Future<void> _handleButtonPress(Appointment data, int? userId) async {
    // if (!isPastDate(data.date, data.slotDuration)) {
    //   setState(() {
    //     _isLoadingAccept = true; // Show loading indicator
    //
    //   });
    //
    //   print('Button 1 pressed for ${data.customerName}');
    //   await postAppointment(data, 5, 0.0, userId);
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
        //     postAppointment(data, 5, 0.0, userId);
        //     Get_ApprovedDeclinedSlots(data, 5);
        //     print('accpteedbuttonisclicked');
        //   }
        // },
        return Row(
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
                  // Navigate to reschedule screen if time difference is greater than 60 minutes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Agentrescheduleslotscreen(
                        userId: userId!,
                        data: data,
                      ),
                    ),
                  );
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
                        SizedBox(
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
                      SizedBox(width: 4),
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
                        SizedBox(
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
                      SizedBox(width: 4),
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
                  closePopUp(context, data, 17, userId);
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
                        '  Close',
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
              const SizedBox(width: 8), // Add spacing between buttons
              GestureDetector(
                onTap: () async {
                  await postAppointment(data, 28, 0.0, userId);
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
                        'Not visited',
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
            ],
          );
        } else {
          return Row(
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
                    // Navigate to reschedule screen if time difference is greater than 60 minutes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Agentrescheduleslotscreen(
                          userId: userId!,
                          data: data,
                        ),
                      ),
                    );
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
        }
      /* return Row(
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
                  // Navigate to reschedule screen if time difference is greater than 60 minutes
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Agentrescheduleslotscreen(
                        userId: userId!,
                        data: data,
                      ),
                    ),
                  );
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
      // if (isSlotTimeReached(data.date, data.slotDuration)) {
      //   return Row(
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           closePopUp(context, data, 17, userId);
      //         },
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(3),
      //             border: Border.all(
      //               color: CommonStyles.statusRedText,
      //             ),
      //           ),
      //           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      //           child: Row(
      //             children: [
      //               SvgPicture.asset(
      //                 'assets/calendar-xmark.svg',
      //                 width: 12,
      //                 color: CommonStyles.statusRedText,
      //               ),
      //               const Text(
      //                 '  Close',
      //                 style: TextStyle(
      //                   fontSize: 16,
      //                   fontFamily: "Outfit",
      //                   fontWeight: FontWeight.w500,
      //                   color: CommonStyles.statusRedText,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //       const SizedBox(width: 8), // Add spacing between buttons
      //       GestureDetector(
      //         onTap: () async {
      //           await postAppointment(data, 28, 0.0, userId);
      //           // Add appropriate action for "Not visited" if needed
      //         },
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(3),
      //             border: Border.all(
      //               color: CommonStyles.statusRedText, // Use a different color for differentiation
      //             ),
      //           ),
      //           padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      //           child: Row(
      //             children: [
      //               SvgPicture.asset(
      //                 'assets/not_visted.svg',
      //                 width: 12,
      //                 color: CommonStyles.statusorangeText,
      //               ),
      //               const SizedBox(width: 2 ),
      //               const Text(
      //                 'Not visited',
      //                 style: TextStyle(
      //                   fontSize: 16,
      //                   fontFamily: "Outfit",
      //                   fontWeight: FontWeight.w500,
      //                   color: CommonStyles.statusorangeText,
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   );
      // } else {
      //   return const SizedBox.shrink();
      // }

      case 6: // Declined
        return const SizedBox();
      // case 11: // FeedBack
      //   return Flexible(
      //     child: Text('" ${data.review} "' ?? '',
      //         overflow: TextOverflow.ellipsis,
      //         maxLines: 2,
      //         style: CommonStyles.txSty_16blu_f5),
      //   );

      case 17: // Closed

        if (data.review == null) {
          // If status is Closed, show review or rate button
          return const SizedBox();
        } else {
          // If status is not Closed, show the review
          return Flexible(
            child: RichText(
              text: TextSpan(
                text: 'Review ',
                style: CommonStyles.txSty_16blu_f5,
                children: <TextSpan>[
                  TextSpan(
                    text: '${data.review} ' ?? '',
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

  void closePopUp(BuildContext context, Appointment data, int i, int? userId) {
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
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Customer Name',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      // Expanded(
                                      //   flex: 6,
                                      //   child: Row(
                                      //     mainAxisAlignment: MainAxisAlignment.start,
                                      //     children: [
                                      //       Text(
                                      //         ': ${data.customerName}',
                                      //         style: const TextStyle(
                                      //           color: CommonStyles.primaryTextColor,
                                      //           fontSize: 14,
                                      //           fontFamily: "Outfit",
                                      //           fontWeight: FontWeight.w500,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      Expanded(
                                        flex: 6,
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              color:
                                                  CommonStyles.primaryTextColor,
                                              fontSize: 14,
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: [
                                              WidgetSpan(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      left:
                                                          0.0), // Adjust this value for more/less spacing
                                                  child: Text(
                                                    ': ${data.customerName}',
                                                    style: const TextStyle(
                                                      color: CommonStyles
                                                          .primaryTextColor,
                                                      fontSize: 14,
                                                      fontFamily: "Outfit",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          softWrap:
                                              true, // Allow wrapping to the next line
                                          overflow: TextOverflow
                                              .visible, // Ensure text isn't clipped
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Slot Time',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: OverflowBar(
                                          overflowAlignment:
                                              OverflowBarAlignment.start,
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              ': ${DateFormat('dd-MM-yyyy').format(DateTime.parse(data.date))}, ${data.slotTime}',
                                              style: const TextStyle(
                                                color: CommonStyles
                                                    .primaryTextColor,
                                                fontSize: 14,
                                                fontFamily: "Outfit",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Expanded(
                                      //   flex: 6,
                                      //   child: RichText(
                                      //     text: TextSpan(
                                      //       style: const TextStyle(
                                      //         color: CommonStyles.primaryTextColor,
                                      //         fontSize: 14,
                                      //         fontFamily: "Outfit",
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //       children: [
                                      //         TextSpan(
                                      //           text: ': ${DateFormat('dd-MM-yyyy').format(DateTime.parse(data.date))}, ',
                                      //         ),
                                      //         WidgetSpan(
                                      //           child: Padding(
                                      //             padding: const EdgeInsets.only(left: 6.0), // Adjust this value for more/less spacing
                                      //             child: Text(
                                      //               '${data.slotDuration}',
                                      //               style: const TextStyle(
                                      //                 color: CommonStyles.primaryTextColor,
                                      //                 fontSize: 14,
                                      //                 fontFamily: "Outfit",
                                      //                 fontWeight: FontWeight.w500,
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //     softWrap: true, // Allow wrapping to the next line
                                      //     overflow: TextOverflow.visible, // Ensure text isn't clipped
                                      //   ),
                                      // ),
                                      // Expanded(
                                      //   flex: 6,
                                      //   child: FittedBox(  // Use FittedBox to scale the content within the available space
                                      //     alignment: Alignment.centerLeft,  // Align text to the left within the box
                                      //    // fit: BoxFit.fitWidth,  // Scales down the content to avoid overflow
                                      //     child: Text(
                                      //       ': ${DateFormat('dd-MM-yyyy').format(DateTime.parse(data.date))}, ${data.slotDuration}',
                                      //       style: const TextStyle(
                                      //         color: CommonStyles.primaryTextColor,
                                      //         fontSize: 14,
                                      //         fontFamily: "Outfit",
                                      //         fontWeight: FontWeight.w500,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 4,
                                        child: Text(
                                          'Purpose of Visit',
                                          style: TextStyle(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              ': ${data.purposeOfVisit}',
                                              style: const TextStyle(
                                                color: CommonStyles
                                                    .primaryTextColor,
                                                fontSize: 14,
                                                fontFamily: "Outfit",
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, top: 5.0, right: 0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isPaymentModeSelected
                                              ? const Color.fromARGB(
                                                  255, 175, 15, 4)
                                              : CommonUtils.primaryTextColor,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
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
                                                  if (paymentOptions[value]
                                                          ['typeCdId'] ==
                                                      23) {
                                                    isFreeService = false;
                                                    _priceController.text =
                                                        '0.0';
                                                  } else {
                                                    _priceController.clear();
                                                    isFreeService = true;
                                                  }

                                                  apiPaymentMode = paymentOptions[
                                                          selectedPaymentOption]
                                                      ['typeCdId'];
                                                  selectedPaymentMode =
                                                      paymentOptions[
                                                              selectedPaymentOption]
                                                          ['desc'];
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
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              ...paymentOptions
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                                    // keyboardType: TextInputType.number,
                                    // readOnly: isFreeService,
                                    enabled: isFreeService,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*')),
                                    ],
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
                                      });
                                    },
                                    maxLength: 10,
                                    decoration: InputDecoration(
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
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    validator: validateAmount,
                                  ),
                                  const SizedBox(height: 20),
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
                                    });
                                    if (_formKey.currentState!.validate()) {
                                      if (isPaymentValidate) {
                                        double? price = double.tryParse(
                                            _priceController.text);
                                        postCloseAppointment(data, 17, price!,
                                            apiPaymentMode, userId);
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: SizedBox(
                          //         child: Center(
                          //           child: Container(
                          //             height: 40.0,
                          //             decoration: BoxDecoration(
                          //               borderRadius:
                          //                   BorderRadius.circular(10.0),
                          //               color: CommonUtils.primaryTextColor,
                          //             ),
                          //             child: Center(
                          //               child: CustomButton(
                          //                 buttonText: 'Submit',
                          //                 color: CommonUtils.primaryTextColor,
                          //                 onPressed: () {
                          //                   setState(() {
                          //                     validatePaymentMode();
                          //                   });
                          //                   if (_formKey.currentState!
                          //                       .validate()) {
                          //                     if (isPaymentValidate) {
                          //                       double? price = double.tryParse(
                          //                           _priceController.text);
                          //                       postCloseAppointment(
                          //                           data,
                          //                           17,
                          //                           price!,
                          //                           apiPaymentMode,
                          //                           userId);
                          //                       Navigator.of(context).pop();
                          //                     }
                          //                   }
                          //                 },
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
                  //    Navigator.of(context).push(
                  //      MaterialPageRoute(
                  //        builder: (context) =>  Agentappointmentlist(),
                  //      ),
                  //    );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? validateAmount(String? value) {
    print('validate 3333');
    if (value == null || value.isEmpty) {
      return 'Please Enter Billing Amount (Rs)';
    }
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
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const CustomerLoginScreen(),
                  //   ),
                  // );
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
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const CustomerLoginScreen(),
                  //   ),
                  // );
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
      print('apiUrl: $response');
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

  Future<void> postCloseAppointment(Appointment data, int i,
      double? billingAmount, int? paymentTypeId, int? userId) async {
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
      "paymentTypeId": paymentTypeId

      // "rating": null,
      // "review": null,
      // "reviewSubmittedDate": null,
      // "timeofslot": null,
      // "customerId":  data.c
    };
    print('postAppointment: : ${json.encode(request)}');
    print('postAppointment: $url');
    try {
      // Send the POST request
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json', // Set the content type header
        },
      );
      print('postAppointment: ${response.body}');
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
}

Future<void> Get_ApprovedDeclinedSlots(Appointment data, int i) async {
  final url = Uri.parse(baseUrl + GetApprovedDeclinedSlots);
  print('url==>55555: $url');

  final request = {
    "Id": data.id,
    "StatusTypeId": 5,
    "BranchName": data.name,
    "Date": data.date,
    "SlotTime": data.slotTime,
    "CustomerName": data.customerName,
    "PhoneNumber": data.phoneNumber,
    "Email": data.email,
    "Address": data.name,
    "SlotDuration": data.slotDuration,
    "branchId": data.branchId,
  };
  print('Get_ApprovedSlotsmail: ${json.encode(request)}');
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
    if (response.statusCode == 204) {
      print('Request sent successfully');
    } else {
      print('Failed to send the request. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
