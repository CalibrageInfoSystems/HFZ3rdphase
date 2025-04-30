import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/CustomerLoginScreen.dart';
import 'package:hairfixingzone/MyAppointment_Model.dart';
import 'package:hairfixingzone/services/notifi_service.dart';

import 'package:hairfixingzone/slot_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Common/common_styles.dart';
import 'Common/custom_button.dart';
import 'CommonUtils.dart';
import 'CustomRadioButton.dart';
import 'Room.dart';
import 'api_config.dart';

class Rescheduleslotscreen extends StatefulWidget {
  // final int branchId;
  // final String branchname;
  // final String branchlocation;
  // final String filepath;
  final MyAppointment_Model data;

  // final int appointmentId; // New field
  // final String screenFrom; // New field

  // Rescheduleslotscreen(MyAppointment_Model data, {
  //   required this.data,
  //  // New field
  // });
  const Rescheduleslotscreen({super.key, required this.data});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class Slot {
  final int branchId;
  final String name;
  final DateTime date;
  final int room;
  final String slot;
  final String SlotTimeSpan;

  final int availableSlots;

  Slot({
    required this.branchId,
    required this.name,
    required this.date,
    required this.room,
    required this.slot,
    required this.availableSlots,
    required this.SlotTimeSpan,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      branchId: json['branchId'],
      name: json['name'],
      date: DateTime.parse(json['dates']),
      room: json['room'],
      slot: json['slot'],
      availableSlots: json['availableSlots'],
      SlotTimeSpan: json['slotTimeSpan'],
    );
  }
}

class _BookingScreenState extends State<Rescheduleslotscreen> {
  List<String> timeSlots = [];
  List<String> availableSlots = [];
  List<String?> timeSlotParts = [];
  String _selectedTimeSlot = '';
  String _selectedSlot = '';
  String AvailableSlots = '';
  String? dropValue;
  List<dropdown> drop = [];
  int? dropdownid;
  late List<String> _subSlots;
  late String selectedOption;
  late String selecteddate;
  List<RadioButtonOption> options = [];
  bool isDropdownValid = true;
  int selectedGender = -1;
  bool isGenderSelected = false;
  bool slotselection = false;
  bool _isLastSlotSelected = false;

  final bool _isPhoneIconFocused = false;
  TextEditingController dateinput = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fullnameController1 = TextEditingController();
  final TextEditingController _phonenumberController2 = TextEditingController();
  final TextEditingController _emailController3 = TextEditingController();
  final TextEditingController _purposeController4 = TextEditingController();
  bool isBackButtonActivated = false;
  DateTime? slotSelectedDateTime;
  DateTime? slotSelected_DateTime;
  DateTime? newDateTime;

//  TextEditingController textController4 = TextEditingController(text: 'Initial value 4');
  List<Slot> slots = [];

  // String _selectedTimeSlot = '';
  // String AvailableSlots = '';
  // List<String> timeSlotParts =[];
  bool isButtonEnabled = true;
  bool isLoading = true;
  late bool isSlotsAvailable;
  List<Slot> disabledSlots = [];
  List<Slot> visableSlots = [];
  late int BranchId;
  List<DateTime> disabledDates = [];
  List<Holiday> holidayList = [];
  bool _isTodayHoliday = false;
  late DateTime holidayDate;
  bool isTodayHoliday = false;
  List<dynamic> dropdownItems = [];
  int selectedTypeCdId = -1; // Initial value for dropdown selection
  String selectedName = ''; // Prepopulated selectedName

  int selectedTechnician = -1;
  int? selectedTechnicianValue;
  String? selectedTechnicianName;
  List<dynamic> dropdownForTechnicians = [];

  int? selectedValue = 0;

  // String? selectedName;
  String userFullName = '';
  String email = '';
  String phonenumber = '';
  int gender = 0;
  String Gender = '';
  int? userId;
  String? contactNumber;
  bool showConfirmationDialog = false;
  int? Id;

  //String? genderbyid;
  bool ispurposeselected = false;
  String? _selectedTimeSlot24;
  int? genderttypeid;

  final TextEditingController _textEditingController =
      TextEditingController(text: "Hair fixing Appointment");
  DateTime currentDate = DateTime.now();
  DateTime? eventDate;

  TimeOfDay currentTime = TimeOfDay.now();
  TimeOfDay? eventTime;

  String? _nextTimeSlot;
  bool isnextSlotsAvailable = false;

  @override
  void dispose() {
    _dateController.dispose();

    super.dispose();
  }

  @override
  initState() {
    super.initState();
    getUserDataFromSharedPreferences();
    //fetchdropdown();
    BranchId = widget.data.branchId;

// Assuming widget.data.purposeOfVisitId is the value you want to match

    dropValue = 'Select';
    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    selecteddate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    CommonUtils.checkInternetConnectivity().then((isConnected) async {
      if (isConnected) {
        print('Connected to the internet');
//  fetchHolidayListByBranchId(widget.branchId);

        try {
          final holidayResponse = await fetchHolidayListByBranchId();
          print(holidayResponse);
          getUserDataFromSharedPreferences();
        } catch (e) {
          print('Error: $e');
        }
        fetchTimeSlots(DateTime.parse(selecteddate), widget.data.branchId)
            .then((value) {
          setState(() {
            slots = value;
          });
        }).catchError((error) {
          print('Error fetching time slots: $error');
        });
        //   fetchRadioButtonOptions();
        fetchData();
      } else {
        CommonUtils.showCustomToastMessageLong(
            'Not connected to the internet', context, 1, 4);
        print('Not connected to the internet');
      }
    });
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Id = prefs.getInt('userId') ?? 0;
    userFullName = prefs.getString('userFullName') ?? '';
    genderttypeid = prefs.getInt('genderTypeId');
    phonenumber = prefs.getString('contactNumber') ?? '';
    email = prefs.getString('email') ?? '';
    contactNumber = prefs.getString('contactNumber') ?? '';
    // genderbyid = prefs.getString('gender');
  }

  Future<Holiday> fetchHolidayListByBranchId() async {
    // final url = Uri.parse(
    //     'http://182.18.157.215/SaloonApp/API/GetHolidayListByBranchId/$branchId');
    // final url = Uri.parse(baseUrl + GetHolidayListByBranchId);
    final url = Uri.parse(baseUrl + getholidayslist);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': widget.data.branchId,
          'isActive': true,
          "fromdate": null,
          "todate": null
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final holidayResponse = HolidayResponse.fromJson(jsonResponse);
        holidayList = holidayResponse.listResult;

        DateTime now = DateTime.now();
        DateTime currentDate = DateTime(now.year, now.month, now.day);
        String formattedDate = DateFormat("yyyy-MM-dd").format(currentDate);
        print('formattedDate:1567 $formattedDate');
        for (final holiday in holidayList) {
          DateTime holidayDate = holiday.holidayDate;
          String holidaydate = DateFormat("yyyy-MM-dd").format(holidayDate);
          print('holidaydate:1571 $holidaydate');
          if (formattedDate == holidaydate) {
            isTodayHoliday = true;
            print('Today is a holiday: $formattedDate');
            break; // If a match is found, exit the loop
          }
        }
        return Holiday.fromJson(jsonResponse);
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Request failed with exception: $e');
    }
  }

  Future<void> onConfirmLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.remove('userId'); // Remove userId from SharedPreferences
    prefs.remove('userRoleId'); // Remove roleId from SharedPreferences
    CommonUtils.showCustomToastMessageLong("Logout Successful", context, 0, 3);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const CustomerLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openDatePicker(bool isTodayHoliday) async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    DateTime initialDate = _selectedDate;

    // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
    if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
      initialDate = getNextNonHoliday(DateTime
          .now()); // Use getNextNonHoliday to get the next available non-holiday day
    }

    // Ensure that the initialDate satisfies the selectableDayPredicate
    while (!selectableDayPredicate(initialDate)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2125),
      selectableDayPredicate: selectableDayPredicate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        onDateSelected(pickedDate);
      });
    }
  }

  void onDateSelected(DateTime selectedDate) async {
    setState(() {
      isTodayHoliday = false;
      _selectedDate = selectedDate;
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      selecteddate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      _selectedTimeSlot = '';
      _nextTimeSlot = '';
    });

    setState(() {
      isTodayHoliday = false;
      slotselection = false;
      bool slotavailable = true;
      _selectedTimeSlot = '';
    });

    bool isConnected = await CommonUtils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
      DateTime selectedDateTime = DateTime.parse(selecteddate);
      fetchTimeSlots(selectedDateTime, widget.data.branchId).then((value) {
        setState(() {
          slots = value;
          _selectedTimeSlot = '';
        });
      }).catchError((error) {
        print('Error fetching time slots: $error');
      });
    } else {
      CommonUtils.showCustomToastMessageLong(
          'Please Check Your Internet Connection', context, 1, 4);
      print('Not connected to the internet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredWidth = screenWidth;
    isSlotsAvailable = getVisibleSlots(slots, isTodayHoliday).isNotEmpty;
    disabledSlots = getDisabledSlots(slots);
    visableSlots = getVisibleSlots(slots, isTodayHoliday);
    // return WillPopScope(
    //     onWillPop: () async {
    //       // Show a confirmation dialog
    //       Navigator.of(context).pop(); // Navigate back to the previous screen
    //       // Return false to prevent default back button behavior
    //       return true;
    //     },
    //     child:
    return WillPopScope(
        onWillPop: () => onBackPressed(context),
        child: Scaffold(
            backgroundColor: CommonStyles.whiteColor,
            appBar: AppBar(
                elevation: 0,
                backgroundColor: CommonStyles.whiteColor,
                title: const Text(
                  'Book Appointment',
                  style: TextStyle(
                      color: Color(0xFF0f75bc),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                ),
                // actions: [
                //   IconButton(
                //     icon: SvgPicture.asset(
                //       'assets/sign-out-alt.svg', // Path to your SVG asset
                //       color: Color(0xFF662e91),
                //       width: 24, // Adjust width as needed
                //       height: 24, // Adjust height as needed
                //     ),
                //     onPressed: () {
                //       logOutDialog(context);
                //       // Add logout functionality here
                //     },
                //   ),
                // ],
                // centerTitle: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: CommonUtils.primaryTextColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )),
            //body: YourBodyWidget(),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: Container(
                          //  height: MediaQuery.of(context).size.height / 6,
                          width: MediaQuery.of(context).size.width,

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
                          // borderRadius: BorderRadius.circular(30), //border corner radius
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: const Color(0xFF960efd)
                          //         .withOpacity(0.2), //color of shadow
                          //     spreadRadius: 2, //spread radius
                          //     blurRadius: 4, // blur radius
                          //     offset: const Offset(
                          //         0, 2), // changes position of shadow
                          //   ),
                          // ],

                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                // width: MediaQuery.of(context).size.width / 4,
                                child: ClipRRect(
                                  //  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    widget.data.imageName.isNotEmpty
                                        ? widget.data.imageName
                                        : 'https://example.com/placeholder-image.jpg',
                                    fit: BoxFit.cover,
                                    height: MediaQuery.of(context).size.height /
                                        5.5 /
                                        2,
                                    width:
                                        MediaQuery.of(context).size.width / 3.2,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/hairfixing_logo.png', // Path to your PNG placeholder image
                                        fit: BoxFit.cover,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4 /
                                                2,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3.2,
                                      );
                                    },
                                  ),
                                ),
                                // child: Image.asset(
                                //   'assets/top_image.png',
                                //   fit: BoxFit.cover,
                                //   height: MediaQuery.of(context).size.height / 4 / 2,
                                //   width: MediaQuery.of(context).size.width / 2.8,
                                // )
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                padding: const EdgeInsets.only(top: 4),
                                // width: MediaQuery.of(context).size.width / 4,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.data.branch,
                                      style: const TextStyle(
                                        color: Color(0xFF0f75bc),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      widget.data.address!,
                                      style: CommonStyles.txSty_12b_f5,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),
                      const Row(
                        children: [
                          Text(
                            'Date ',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF11528f),
                            ),
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
                      TextFormField(
                        controller: _dateController,
                        keyboardType: TextInputType.visiblePassword,
                        onTap: () {
                          _openDatePicker(_isTodayHoliday);
                        },
                        // focusNode: DateofBirthdFocus,
                        readOnly: true,
                        validator: (value) {
                          if (value!.isEmpty || value.isEmpty) {
                            return 'Choose Date to Check Slots';
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
                          hintStyle: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF11528f),
                          ),
                        ),
                        //          validator: validateDate,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Scrollbar(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : isSlotsAvailable
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 2.5,
                                    ),
                                    itemCount:
                                        getVisibleSlots(slots, isTodayHoliday)
                                            .length,
                                    itemBuilder: (BuildContext context, int i) {
                                      final visibleSlots = getVisibleSlots(
                                          slots, isTodayHoliday);
                                      if (i >= visibleSlots.length) {
                                        return const SizedBox.shrink();
                                      }

                                      final slot = visibleSlots[i];

                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 2),
                                        child: ElevatedButton(
                                          onPressed: slot.availableSlots <= 0
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _selectedTimeSlot =
                                                        slot.SlotTimeSpan;
                                                    _selectedSlot = slot.slot;
                                                    AvailableSlots = slot
                                                        .availableSlots
                                                        .toString();
                                                    timeSlotParts =
                                                        _selectedSlot
                                                            .split(' - ');
                                                    // if (timeSlotParts
                                                    //     .isNotEmpty) {
                                                    //   fetchTechnicians();
                                                    //   selectedTechnician = -1;
                                                    // }
                                                    fetchTechnicians();
                                                    selectedTechnician = -1;
                                                    slotselection = true;
                                                    _selectedTimeSlot24 =
                                                        DateFormat('HH:mm')
                                                            .format(DateFormat(
                                                                    'h:mm a')
                                                                .parse(
                                                                    _selectedTimeSlot));
                                                    print(
                                                        '_selectedTimeSlot24 $_selectedTimeSlot24');
                                                    String formattedDate =
                                                        DateFormat("yyyy-MM-dd")
                                                            .format(
                                                                _selectedDate);
                                                    String datePart =
                                                        formattedDate.substring(
                                                            0, 10);
                                                    String
                                                        selectedDateTimeString =
                                                        '$datePart $_selectedTimeSlot24';
                                                    slotSelected_DateTime = DateFormat(
                                                            'yyyy-MM-dd HH:mm')
                                                        .parse(
                                                            selectedDateTimeString);
                                                    print(
                                                        'SlotselectedDateTime: $slotSelected_DateTime');
                                                    slotSelectedDateTime =
                                                        slotSelected_DateTime!
                                                            .subtract(
                                                                const Duration(
                                                                    hours: 1));
                                                    print(
                                                        '-1 hour Modified DateTime: $slotSelectedDateTime');
                                                    newDateTime =
                                                        slotSelected_DateTime!
                                                            .add(const Duration(
                                                                days: 20));
                                                    print(
                                                        'New DateTime after adding 20 days: $newDateTime');
                                                    // Parse the concatenated string into a DateTime object
                                                    //  DateTime SlotselectedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(selectedDateTimeString);
                                                    print(
                                                        'SlotselectedDateTime==613==$selectedDateTimeString');
                                                    print(
                                                        '==234==$_selectedTimeSlot');
                                                    print(
                                                        '==234==$_selectedTimeSlot');
                                                    print(
                                                        '===567==$_selectedSlot');
                                                    print(
                                                        '==900==$AvailableSlots');
                                                  });
                                                },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 1.0, horizontal: 1.0),
                                            backgroundColor:
                                                _selectedTimeSlot ==
                                                        slot.SlotTimeSpan
                                                    ? CommonUtils
                                                        .primaryTextColor
                                                    : (slot.availableSlots <= 0
                                                        ? Colors.grey
                                                        : Colors.white),
                                            side: BorderSide(
                                              color: _selectedTimeSlot ==
                                                      slot.SlotTimeSpan
                                                  ? CommonUtils.primaryTextColor
                                                  : (slot.availableSlots <= 0
                                                      ? Colors.transparent
                                                      : CommonUtils
                                                          .primaryTextColor),
                                              width: 1.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            textStyle: TextStyle(
                                              color: _selectedTimeSlot ==
                                                      slot.SlotTimeSpan
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          child: Text(
                                            slot.SlotTimeSpan,
                                            style: TextStyle(
                                              color: _selectedTimeSlot ==
                                                      slot.SlotTimeSpan
                                                  ? Colors.white
                                                  : (slot.availableSlots <= 0
                                                      ? Colors.white
                                                      : Colors.black),
                                              fontFamily: 'Outfit',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : isTodayHoliday
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Today is a Holiday',
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    // Show your regular widget when today is not a holiday

                                    : const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'No Slots are Available Today',
                                              style: TextStyle(
                                                fontFamily: 'Outfit',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                      ),
                      // Scrollbar(
                      //   child: isLoading
                      //       ? const Center(child: CircularProgressIndicator())
                      //       : isSlotsAvailable
                      //       ? GridView.builder(
                      //     shrinkWrap: true,
                      //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      //       crossAxisCount: 3,
                      //       childAspectRatio: 2.5,
                      //     ),
                      //     itemCount: getVisibleSlots(slots, isTodayHoliday).length,
                      //     itemBuilder: (BuildContext context, int i) {
                      //       final visibleSlots = getVisibleSlots(slots, isTodayHoliday);
                      //       if (i >= visibleSlots.length) return const SizedBox.shrink();
                      //
                      //       final slot = visibleSlots[i];
                      //       return Container(
                      //         margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                      //         child: ElevatedButton(
                      //           onPressed: () {
                      //             if (slot.availableSlots > 0) {
                      //               setState(() {
                      //                 // Select the current slot
                      //                 _selectedTimeSlot = slot.SlotTimeSpan;
                      //                 _selectedSlot = slot.slot;
                      //                 AvailableSlots = slot.availableSlots.toString();
                      //                 timeSlotParts = _selectedSlot.split(' - ');
                      //                 fetchTechnicians();
                      //                 selectedTechnician = -1;
                      //                 slotselection = true;
                      //
                      //                 // Convert selected time slot to 24-hour format
                      //                 _selectedTimeSlot24 = DateFormat('HH:mm').format(DateFormat('h:mm a').parse(_selectedTimeSlot));
                      //                 String formattedDate = DateFormat("yyyy-MM-dd").format(_selectedDate);
                      //                 String datePart = formattedDate.substring(0, 10);
                      //                 String selectedDateTimeString = '$datePart $_selectedTimeSlot24';
                      //                 slotSelected_DateTime = DateFormat('yyyy-MM-dd HH:mm').parse(selectedDateTimeString);
                      //                 slotSelectedDateTime = slotSelected_DateTime!.subtract(const Duration(hours: 1));
                      //                 newDateTime = slotSelected_DateTime!.add(const Duration(days: 20));
                      //
                      //                 // Clear previously selected next slot
                      //                 _nextTimeSlot = null;
                      //                 final visibleSlots = getVisibleSlots(slots, isTodayHoliday);
                      //                 int selectedIndex = visibleSlots.indexWhere((s) => s.SlotTimeSpan == slot.SlotTimeSpan);
                      //                 // if (selectedValue == 7 && selectedIndex == visibleSlots.length - 1) {
                      //                 //   setState(() {
                      //                 //     _isLastSlotSelected = true;
                      //                 //   });
                      //                 // } else {
                      //                 //   setState(() {
                      //                 //     _isLastSlotSelected = false;
                      //                 //   });
                      //                 // }
                      //                 setState(() {
                      //                   _isLastSlotSelected = (selectedValue == 7 && selectedIndex == visibleSlots.length - 1);
                      //                 });
                      //                 // Check the purpose of visit
                      //                 if (selectedValue == 7) {
                      //                   // Get the visible slots and the index of the currently selected slot
                      //
                      //                   // If the selected slot is the last one, clear the next slot
                      //                   if (selectedIndex == visibleSlots.length - 1) {
                      //                     _nextTimeSlot = null; // No next slot to select
                      //                     print("Booked Slot: $_selectedTimeSlot");
                      //                   } else {
                      //                     // Try to select the next available slot
                      //                     final nextSlot = visibleSlots[selectedIndex + 1];
                      //                     if (nextSlot.availableSlots > 0) {
                      //                       isnextSlotsAvailable = true;
                      //                       _nextTimeSlot = nextSlot.SlotTimeSpan; // Set next time slot
                      //                       print("Booked Slots: $_selectedTimeSlot, $_nextTimeSlot");
                      //                     } else {
                      //                       isnextSlotsAvailable = false;
                      //                       // Show error toast when the next slot is not available
                      //                       // ScaffoldMessenger.of(context).showSnackBar(
                      //                       //   SnackBar(
                      //                       //     content: Text('Next slot is not available'),
                      //                       //     backgroundColor: Colors.red,
                      //                       //     duration: Duration(seconds: 4),
                      //                       //   ),
                      //                       // );
                      //
                      //                       print("Next slot not available");
                      //                     }
                      //                   }
                      //                 } else {
                      //                   // If the visit is not "New Hair Patch", print the selected slot
                      //                   print("Booked Slot: $_selectedTimeSlot");
                      //                 }
                      //               });
                      //             }
                      //           },
                      //           style: ElevatedButton.styleFrom(
                      //             padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                      //             backgroundColor: (_selectedTimeSlot == slot.SlotTimeSpan || _nextTimeSlot == slot.SlotTimeSpan)
                      //                 ? CommonUtils.primaryTextColor
                      //                 : (slot.availableSlots <= 0 ? Colors.grey : Colors.white),
                      //             side: BorderSide(
                      //               color: (_selectedTimeSlot == slot.SlotTimeSpan || _nextTimeSlot == slot.SlotTimeSpan)
                      //                   ? CommonUtils.primaryTextColor
                      //                   : (slot.availableSlots <= 0 ? Colors.transparent : CommonUtils.primaryTextColor),
                      //               width: 1.0,
                      //             ),
                      //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                      //             textStyle: TextStyle(
                      //               color: (_selectedTimeSlot == slot.SlotTimeSpan || _nextTimeSlot == slot.SlotTimeSpan) ? Colors.white : Colors.black,
                      //             ),
                      //           ),
                      //           child: Text(
                      //             slot.SlotTimeSpan,
                      //             style: TextStyle(
                      //               color: (_selectedTimeSlot == slot.SlotTimeSpan || _nextTimeSlot == slot.SlotTimeSpan)
                      //                   ? Colors.white
                      //                   : (slot.availableSlots <= 0 ? Colors.white : Colors.black),
                      //               fontFamily: 'Outfit',
                      //               fontSize: 12,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     },
                      //   )
                      //       : isTodayHoliday
                      //       ? const Center(child: Text('Today is a Holiday'))
                      //       : const Center(child: Text('No Slots Are Available Today')),
                      // ),

                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        children: [
                          Text(
                            'Purpose of Visit ',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF11528f),
                            ),
                          ),
                          Text(
                            '*',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: .0, right: 0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            // border: Border.all(
                            //   color: CommonUtils.primaryTextColor,
                            // ),
                            border: Border.all(
                              color: ispurposeselected
                                  ? const Color.fromARGB(255, 175, 15, 4)
                                  : CommonUtils.primaryTextColor,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton2<int>(
                                isExpanded: true,
                                items: [
                                  // DropdownMenuItem<int>(
                                  //   value: -1,
                                  //   child: Text(
                                  //     ' Select Purpose of Visit',
                                  //     style: TextStyle(
                                  //       color: Colors.grey, fontSize: 14, fontFamily: 'Outfit',
                                  //       //  fontWeight: FontWeight.w500
                                  //     ),
                                  //   ),
                                  //   // Static text
                                  // ),
                                  ...dropdownItems.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(
                                        item['desc'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ].toList(),
                                value: selectedTypeCdId,
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
                                    }
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: double.infinity,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                  //decoration: BoxDecoration(
                                  //  borderRadius: BorderRadius.circular(14),
                                  //   border: Border.all(
                                  //     color: Colors.black26,
                                  //   ),
                                  //   color: Colors.redAccent,
                                  //    ),
                                  // elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down_sharp,
                                  ),
                                  iconSize: 24,
                                  iconEnabledColor: Color(0xFF11528f),
                                  iconDisabledColor: Color(0xFF11528f),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 4,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  //  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: Radius.circular(40),
                                    thickness:
                                        MaterialStateProperty.all<double>(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (ispurposeselected)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              child: Text(
                                'Please Select Purpose of Visit',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 175, 15, 4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      //MARK: Technicians DropDown
                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Technician',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF11528f),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0, top: .0, right: 0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: CommonUtils.primaryTextColor,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton2<int>(
                                isExpanded: true,
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: -1,
                                    child: Text(
                                      'Select Technician',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    // Static text
                                  ),
                                  ...dropdownForTechnicians
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(
                                        item['firstName'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                          fontFamily: 'Outfit',
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ].toList(),
                                value: selectedTechnician,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTechnician = value!;
                                    if (selectedTechnician != -1) {
                                      selectedTechnicianValue =
                                          dropdownForTechnicians[
                                              selectedTechnician]['id'];
                                      selectedTechnicianName =
                                          dropdownForTechnicians[
                                              selectedTechnician]['firstName'];

                                      print(
                                          "selectedTechnicianValue: $selectedTechnicianValue");
                                      print(
                                          "selectedTechnicianName:$selectedTechnicianName");
                                    } else {
                                      print("==========");
                                      print(selectedTechnicianValue);
                                      print(selectedTechnicianName);
                                    }
                                    // isDropdownValid = selectedTypeCdId != -1;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 45,
                                  width: double.infinity,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                  //decoration: BoxDecoration(
                                  //  borderRadius: BorderRadius.circular(14),
                                  //   border: Border.all(
                                  //     color: Colors.black26,
                                  //   ),
                                  //   color: Colors.redAccent,
                                  //    ),
                                  // elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down_sharp,
                                  ),
                                  iconSize: 24,
                                  iconEnabledColor: Color(0xFF11528f),
                                  iconDisabledColor: Color(0xFF11528f),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight:
                                      MediaQuery.of(context).size.height / 4,
                                  width:
                                      MediaQuery.of(context).size.width / 1.1,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey.shade50,
                                  ),
                                  //  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: Radius.circular(40),
                                    thickness:
                                        MaterialStateProperty.all<double>(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all<bool>(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      // Visibility(
                      //   visible: !isLoading, // Show the Container if isLoading is false
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width / 1.5,
                      //     child: CustomButton(
                      //       buttonText: 'Book Appointment',
                      //       color: CommonUtils.primaryTextColor,
                      //       onPressed: bookappointment,
                      //     ),
                      //   ),
                      // )
                      Visibility(
                        visible: !isLoading,
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                  buttonText: 'Book Appointment',
                                  color: CommonUtils.primaryTextColor,
                                  onPressed: () {
                                    // Validate purpose first
                                    validatePurpose(selectedName);
                                  }),
                            ),
                          ],
                        ),
                      ),
                      // Visibility(
                      //   visible: !isLoading,
                      //   child: Row(
                      //     children: [
                      //       Expanded(
                      //         child: CustomButton(
                      //           buttonText: 'Book Appointment',
                      //           color: CommonUtils.primaryTextColor,
                      //           onPressed: (selectedValue == 7 && _isLastSlotSelected)
                      //               ? (isnextSlotsAvailable
                      //               ? () {
                      //             // Validate purpose first
                      //             validatePurpose(selectedName);
                      //           }
                      //               : null) // Disable only if selectedValue is 7 and isnextSlotsAvailable is false
                      //               : () {
                      //             // Validate purpose first (if selectedValue is not 7)
                      //             validatePurpose(selectedName);
                      //           },
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Visibility(
                      //   visible: !isLoading, // Show the Container if isLoading is false
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width / 1.5,
                      //     child: CustomButton(
                      //       buttonText: 'Book Appointment',
                      //       color:CommonUtils.primaryTextColor , // Enable button if last slot is selected
                      //       onPressed: _isLastSlotSelected
                      //           ? () {
                      //         validatePurpose(selectedName); // Call validatePurpose when button is clicked
                      //       }
                      //           : null, // Disable button if not the last slot
                      //     ),
                      //   ),
                      // )
                      // Visibility(
                      //   visible: !isLoading, // Show the Container if isLoading is false
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width / 1.5,
                      //     child: CustomButton(
                      //       buttonText: 'Book Appointment',
                      //       color: CommonUtils.primaryTextColor, // Set button color
                      //       onPressed: (selectedValue == 7 && isnextSlotsAvailable &&_isLastSlotSelected) ||
                      //           (selectedValue != 7 && _isLastSlotSelected)
                      //           ? () {
                      //         // Validate purpose based on the selectedName
                      //         validatePurpose(selectedName);
                      //       }
                      //           : null, // Disable button if the conditions are not met
                      //     ),
                      //   ),
                      // ),

                      // Visibility(
                      //   visible: !isLoading, // Show the Container if isLoading is false
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width / 1.5,
                      //     child: CustomButton(
                      //       buttonText: 'Book Appointment',
                      //       color: CommonUtils.primaryTextColor,
                      //       onPressed: (selectedValue == 7)
                      //           ? (isnextSlotsAvailable
                      //           ? () {
                      //         // Validate purpose first
                      //         validatePurpose(selectedName);
                      //       }
                      //           : null // Disable button if selectedValue is 7 but isnextSlotsAvailable is false
                      //       )
                      //           : _isLastSlotSelected // Fallback to original _isLastSlotSelected logic
                      //           ? () {
                      //         validatePurpose(selectedName);
                      //       }
                      //           : null, // Disable button otherwise
                      //     ),
                      //   ),
                      // )

                      // Visibility(
                      //   visible: !isLoading,
                      //   child: SizedBox(
                      //     width: MediaQuery.of(context).size.width / 1.5,
                      //     child: CustomButton(
                      //       buttonText: 'Book Appointment',
                      //       color: CommonUtils.primaryTextColor,
                      //       onPressed: () {
                      //         // Validate purpose first
                      //         validatePurpose(selectedName);
                      //       },
                      //     ),
                      //   ),
                      // ),

                      // Container(
                      //   width: MediaQuery.of(context).size.width / 1.5,
                      //   child: CustomButton(
                      //     buttonText: 'Book Appointment',
                      //     color: CommonUtils.primaryTextColor,
                      //     onPressed: bookappointment,
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            )));
  }

  // Future<void> validatePurpose(String? value) async {
  //   if (!isSlotsAvailable) {
  //     showCustomToastMessageLong('No Slots Are Available Today', context, 1, 4);
  //   } else if (!slotselection) {
  //     showCustomToastMessageLong('Please Select A Slot', context, 1, 4);
  //   } else {
  //     // If all conditions are met, proceed to book the appointment
  //     bookappointment();
  //   }
  // }
  Future<void> validatePurpose(String? value) async {
    // Check if no slots are available
    if (!isSlotsAvailable) {
      showCustomToastMessageLong('No Slots Are Available Today', context, 1, 4);
      return; // Stop further execution if no slots are available
    }
    // if (selectedValue == 7) {
    //   if (!isnextSlotsAvailable) {
    //     // Show message if the next slot is not available
    //     showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
    //     return; // Stop execution since next slot is needed for "New Hair Patch"
    //   }
    // }

    // if (selectedValue == 7 && !_isLastSlotSelected && !isnextSlotsAvailable) {
    //   showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
    //   return;
    // }

    // if (selectedValue == 7) {
    //   if(_isLastSlotSelected==false){
    //     if (isnextSlotsAvailable) {
    //       // Show message if the next slot is not available
    //       showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
    //       return; // Stop execution since next slot is needed for "New Hair Patch"
    //     }
    //   }
    //
    // }
    // Check if the selected purpose is "New Hair Patch"
    // if (selectedValue == 7) {
    //   if (!isnextSlotsAvailable) {
    //     // Show message if the next slot is not available
    //     showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
    //     return; // Stop execution since next slot is needed for "New Hair Patch"
    //   }
    // }
    // Check if a slot has been selected
    if (!slotselection) {
      showCustomToastMessageLong('Please Select A Slot', context, 1, 4);
      return; // Stop execution if no slot has been selected
    }

    // Check if the purpose of visit has been selected
    if (value == null || value.isEmpty) {
      ispurposeselected = true; // Flag purpose as not selected
      setState(() {}); // Trigger UI update for validation message
      showCustomToastMessageLong(
          'Please Select A Purpose of Visit', context, 1, 4);
      return; // Stop execution if purpose is not selected
    }
    // showCustomToastMessageLong('Api Hit', context, 1, 4);
    // If all validations pass, proceed to book the appointment
    bookappointment();
  }

  // if (visablelength == disabledlength) {
  // showCustomToastMessageLong('No Slots Available Today ', context, 1, 4);
  // isValid = false;
  // hasValidationFailed = true;
  // }
  Future<void> bookappointment() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(baseUrl + postApiAppointment);
      print('url==>890: $url');

      DateTime now = DateTime.now();
      ProgressDialog progressDialog = ProgressDialog(context);

      // Show the progress dialog
      progressDialog.show();
      String dateTimeString = now.toString();
      print('DateTime as String: $dateTimeString');
      print('DateTime as String: $selecteddate');
      print('_selectedTimeSlot892 $_selectedTimeSlot');
      String slotdate = DateFormat('dd MMM yyyy').format(_selectedDate);
      print('slotdate $slotdate');
      // print('screenFrom1213: ${widget.screenFrom}');
      // print('appointmentId1214: ${widget.appointmentId}');

      final request = {
        "id": widget.data.id,
        "branchId": widget.data.branchId,
        "date": selecteddate,
        "slotTime": timeSlotParts[0],
        "customerName": widget.data.customerName,
        "phoneNumber": widget.data.contactNumber,
        "email": widget.data.email,
        "genderTypeId": widget.data.genderTypeId,
        "statusTypeId": 18,
        "purposeOfVisitId": selectedValue,
        "isActive": true,
        "createdDate": dateTimeString,
        "updatedDate": dateTimeString,
        "updatedByUserId": null,
        "rating": null,
        "review": null,
        "reviewSubmittedDate": null,
        // "timeofslot": widget.data.timeofSlot,
        "timeofslot": '$_selectedTimeSlot24',
        "customerId": Id,
        "paymentTypeId": null
      };

      print('Object: ${json.encode(request)}');
      try {
        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        // Check the response status code
        // if (response.statusCode == 200) {
        //   print('Request sent successfully');
        //   showCustomToastMessageLong('Slot booked successfully', context, 0, 2);
        //   Navigator.pop(context);
        // } else {
        //   showCustomToastMessageLong('Failed to send the request', context, 1, 2);
        //   print('Failed to send the request. Status code: ${response.statusCode}');
        // }

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);

          // Extract the necessary information
          bool isSuccess = data['isSuccess'];
          if (isSuccess == true) {
            DateTime testdate = DateTime.now();
            print(' testdate ====$testdate');
            final int notificationId1 = UniqueKey().hashCode;
            // debugPrint('Notification Scheduled for $testdate with ID: $notificationId1');
            debugPrint(
                'Notification Scheduled for $slotSelectedDateTime with ID: $notificationId1');
            await NotificationService().scheduleNotification(
              title: 'Reminder Notification',
              body:
                  // Hey $userFullName, Today Your Appointment is Scheduled for  ${_selectedTimeSlot24!} at the ${widget.branchname} Branch, Located At ${widget.branchaddress}.
                  'Hey $userFullName, Today Your Appointment is Scheduled for  $_selectedTimeSlot at the  ${widget.data.branch} Branch, Located at ${widget.data.address}.',
              // scheduledNotificationDateTime: testdate!,
              scheduledNotificationDateTime: slotSelectedDateTime!,
              id: notificationId1,
            );

            if (selectedValue == 8 ||
                selectedValue == 9 ||
                selectedValue == 10 ||
                selectedValue == 11) {
              DateTime testdate = DateTime.now();
              print(' testdate ====1072$testdate');
              // Handle each case separately
              //  Hey  Sai, It has Been 20 Days Since Your Tape with Glue Service was Done. Please Revisit the service at Hair Fixing Zone at the JNTU Branch
              switch (selectedValue) {
                case 8:
                  final int notificationId2 = UniqueKey().hashCode;
                  debugPrint(
                      'Notification Scheduled for $newDateTime with ID: $notificationId2');
                  await NotificationService().scheduleNotification(
                    title: 'Reminder Notification',
                    body:
                        'Hey $userFullName, It Has Been 20 Days Since Your  $selectedName Was Done. Please Revisit the service at Hairfixing Zone at the ${widget.data.branch} Branch',
                    scheduledNotificationDateTime: newDateTime!,
                    //   scheduledNotificationDateTime: testdate!,
                    id: notificationId2,
                  );
                  // Handle value 8
                  break;
                case 9:
                  final int notificationId2 = UniqueKey().hashCode;
                  debugPrint(
                      'Notification Scheduled for $newDateTime with ID: $notificationId2');
                  await NotificationService().scheduleNotification(
                    title: 'Reminder Notification',
                    body:
                        'Hey $userFullName, It Has Been 20 Days Since Your  $selectedName Was Done. Please Revisit the service at Hairfixing Zone at the ${widget.data.branch} Branch',
                    scheduledNotificationDateTime: newDateTime!,
                    //  scheduledNotificationDateTime: testdate!,
                    id: notificationId2,
                  );
                  // Handle value 9
                  break;
                case 10:
                  // Handle value 10
                  final int notificationId2 = UniqueKey().hashCode;
                  debugPrint(
                      'Notification Scheduled for $newDateTime with ID: $notificationId2');
                  await NotificationService().scheduleNotification(
                    title: 'Reminder Notification',
                    body:
                        'Hey $userFullName, It Has Been 20 Days Since Your  $selectedName Was Done. Please Revisit the service at Hairfixing Zone at the ${widget.data.branch} Branch',
                    scheduledNotificationDateTime: newDateTime!,
                    //   scheduledNotificationDateTime: testdate!,
                    id: notificationId2,
                  );
                  break;
                case 11:
                  final int notificationId2 = UniqueKey().hashCode;
                  debugPrint(
                      'Notification Scheduled for $newDateTime with ID: $notificationId2');
                  await NotificationService().scheduleNotification(
                    title: 'Reminder Notification',
                    body:
                        'Hey $userFullName, It Has Been 20 Days Since Your  $selectedName Was Done. Please Revisit the service at Hairfixing Zone at the ${widget.data.branch} Branch',
                    scheduledNotificationDateTime: newDateTime!,
                    // scheduledNotificationDateTime: testdate!,
                    id: notificationId2,
                  );
                  // Handle value 11
                  break;
                default:
                  // Handle other cases if needed
                  break;
              }
            }

            // Your existing code...
            progressDialog.dismiss();
            print('Request sent successfully');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => SlotSuccessScreen(
                        slotdate: slotdate,
                        slottime: _selectedTimeSlot,
                        Purpose: selectedName,
                        slotbranchname: widget.data.branch,
                        slotbrnach_address: widget.data.address!,
                        phonenumber: widget.data.contactNumber,
                        branchImage: widget.data.imageName,
                        latitude: widget.data.latitude!,
                        longitude: widget.data.longitude!,
                        //   locationUrl: widget.data.l,
                        locationUrl: widget.data.locationUrl!,
                      )),
            );
            // showCustomToastMessageLong('Slot booked successfully', context, 0, 2);
            // Navigator.pop(context);
            // Success case
            // Handle success scenario here
          } else {
            progressDialog.dismiss();
            // Failure case
            // Handle failure scenario here
            CommonUtils.showCustomToastMessageLong(
                '${data['statusMessage']}', context, 1, 4);
          }
          setState(() {
            isButtonEnabled = true;
            progressDialog.dismiss();
          });
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
  }

  bool isHoliday(DateTime date) {
    return holidayList.any((holiday) =>
        date.year == holiday.holidayDate.year &&
        date.month == holiday.holidayDate.month &&
        date.day == holiday.holidayDate.day);
  }

  DateTime getNextNonHoliday(DateTime currentDate) {
    // Keep moving forward until a non-holiday day is found
    while (isHoliday(currentDate)) {
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return currentDate;
  }

  bool selectableDayPredicate(DateTime date) {
    final isPastDate =
        date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    final isHolidayDate = isHoliday(date);
    final isPreviousYear = date.year < DateTime.now().year;

    // If today is a holiday and the selected date is a past date, allow selecting the next non-holiday date
    if (_isTodayHoliday && isHolidayDate && isPastDate) {
      return true;
    }

    // Return false if any of the conditions are met
    return !isPastDate &&
        !isHolidayDate &&
        !isPreviousYear &&
        date.year >= DateTime.now().year;
  }

  //Original Code commented by Arun on Jan25th
  // Future<void> _openDatePicker(bool isTodayHoliday) async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //
  //   DateTime initialDate = _selectedDate;
  //
  //   // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
  //   if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
  //     initialDate = DateTime.now().add(const Duration(days: 1));
  //   }
  //
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: DateTime.now().subtract(Duration(days: 0)),
  //     lastDate: DateTime(2125),
  //     // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.
  //
  //     selectableDayPredicate: (DateTime date) {
  //       final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
  //    //   final isSunday = date.weekday == DateTime.tuesday; // Change to DateTime.sunday
  //       final isHoliday = holidayList.any((holiday) =>
  //       date.year == holiday.holidayDate.year &&
  //           date.month == holiday.holidayDate.month &&
  //           date.day == holiday.holidayDate.day);
  //
  //       // If today is a holiday and the selected date is a past date, allow selecting the holiday date
  //       if (_isTodayHoliday && isHoliday && isPastDate) {
  //         return true;
  //       }
  //
  //       final isPreviousYear = date.year < DateTime.now().year;
  //
  //       // Return false if any of the conditions are met
  //       return !isPastDate  && !isHoliday && !isPreviousYear && date.year >= DateTime.now().year;
  //     },
  //
  //   );
  //
  //   if (pickedDate != null) {
  //     setState(() {
  //       _selectedDate = pickedDate;
  //       onDateSelected(pickedDate);
  //     });
  //
  //   }
  // }

  void disableButton() {
    setState(() {
      isButtonEnabled = false;
    });
  }

  // Future<void> validatedata() async {
  //   int disabledlength = disabledSlots.length;
  //   print('====887$disabledlength');
  //   int visablelength = visableSlots.length;
  //   print('==889$visablelength');
  //   bool isValid = true;
  //   bool hasValidationFailed = false;
  //
  //   if (selectedTypeCdId == -1) {
  //     selectedName = "Select";
  //   }
  //
  //   if (_dateController.text.isEmpty) {
  //     showCustomToastMessageLong('Please Select Date', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //   if (!isSlotsAvailable) {
  //     showCustomToastMessageLong('No Slots Available Today', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   } else if (!slotselection) {
  //     showCustomToastMessageLong('Please Select slot', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //   if (visablelength == disabledlength) {
  //     showCustomToastMessageLong('No Slots Available Today ', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //
  //   if (_selectedSlot == null) {
  //     showCustomToastMessageLong('Please Select Time Slot', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //   if (isValid && _fullnameController1.text.isEmpty) {
  //     showCustomToastMessageLong('Please Enter Your Full Name', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //   if (isValid && _phonenumberController2.text.isEmpty) {
  //     showCustomToastMessageLong('Please Enter Your Phone Number', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   } else {
  //     String value = _phonenumberController2.text;
  //     int? number = int.tryParse(value);
  //     if (isValid && number != null && number.toString().length < 10) {
  //       showCustomToastMessageLong('Please Enter Your Valid Mobile Number', context, 1, 2);
  //       isValid = false;
  //       hasValidationFailed = true;
  //     }
  //   }
  //
  //   if (isValid && _emailController3.text.isEmpty) {
  //     showCustomToastMessageLong('Please Enter Your Email', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //   if (isValid && !validateEmailFormat(_emailController3.text)) {
  //     showCustomToastMessageLong('Please Enter Valid Email', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //
  //   if (isValid && !isGenderSelected) {
  //     showCustomToastMessageLong('Please Select Gender', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  //
  //   if (isValid && selectedTypeCdId == -1) {
  //     showCustomToastMessageLong('Please Select Purpose of Visit', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //   }
  // }

  List<Slot> getVisibleSlots(List<Slot> slots, bool isTodayHoliday) {
    print('isTodayHoliday====$isTodayHoliday');
    // Get the current time and add 30 minutes
    DateTime now = DateTime.now().add(const Duration(minutes: 30));

    // Format the time in 12-hour format
    String formattedTime = DateFormat('hh:mm a').format(now);

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Combine the current date and formatted time
    String combinedDateTimeString =
        '${DateFormat('yyyy-MM-dd').format(currentDate)} $formattedTime';

    // Parse the combined date and time string into a DateTime object
    DateTime combinedDateTime =
        DateFormat('yyyy-MM-dd hh:mm a').parse(combinedDateTimeString);

    if (isTodayHoliday) {
      // Today is a holiday, return an empty list
      return [];
    }

    if (slots.isEmpty) {
      // Return an empty list if there are no slots
      return [];
    }

    return slots.where((slot) {
      String timespan = slot.SlotTimeSpan;
      // Combine the current date and formatted time
      String SlotDateTimeString =
          '${DateFormat('yyyy-MM-dd').format(currentDate)} $timespan';

      DateFormat dateformat = DateFormat('yyyy-MM-dd');
      String currentdate = dateformat.format(DateTime.now());
      String formattedapiDate = dateformat.format(slot.date);

      DateTime slotDateTime;
      if (currentdate == formattedapiDate) {
        // If the slot is for the current date, use the slot's time
        String timespan = slot.SlotTimeSpan;

        // Combine the current date and time span
        String SlotDateTimeString =
            '${DateFormat('yyyy-MM-dd').format(currentDate)} $timespan';

        // Parse the combined date and time string into a DateTime object
        slotDateTime =
            DateFormat('yyyy-MM-dd hh:mm a').parse(SlotDateTimeString);
      } else {
        // If the slot is for a different date, use the slot's date and time
        slotDateTime =
            DateFormat('yyyy-MM-dd HH:mm').parse('$formattedapiDate $timespan');
      }

      return !slotDateTime.isBefore(combinedDateTime);
    }).toList();
  }

  List<Slot> getDisabledSlots(List<Slot> slots) {
    // Get the current time
    DateTime now = DateTime.now();

    // Add 30 minutes to the current time
    DateTime futureTime = now.subtract(const Duration(minutes: 30));

    // Format the time in 12-hour format
    String formattedTime = DateFormat('hh:mm a').format(futureTime);
    print("formattedTime$formattedTime");
    // Get the current date
    DateTime currentDate = DateTime.now();

    // Combine the current date and formatted time
    String combinedDateTimeString =
        '${DateFormat('yyyy-MM-dd').format(currentDate)} $formattedTime';

    // Parse the combined date and time string into a DateTime object
    DateTime combinedDateTime =
        DateFormat('yyyy-MM-dd hh:mm a').parse(combinedDateTimeString);

    // Filter the slots based on visibility criteria
    List<Slot> disabledSlots = slots.where((slot) {
      DateTime slotDateTime =
          DateFormat('yyyy-MM-dd HH:mm').parse('${slot.date} ${slot.date}');
      return !slotDateTime.isBefore(combinedDateTime) &&
          slot.availableSlots <= 0;
    }).toList();

    return disabledSlots;
  }

  List<Slot> filteredSlots = [];

  //List<Slot> slots = [];

  // Future<List<Slot>> fetchTimeSlots(DateTime selectedDate, int branchId) async {
  //   isLoading = false;
  //   final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  //   final url = Uri.parse(baseUrl + GetSlotsByDateAndBranch + "$formattedDate/$branchId");
  //   print('url==>969: $url');
  //
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final jsonResult = json.decode(response.body);
  //       final List<dynamic> slotData = jsonResult['listResult'];
  //
  //       slots = slotData.map((slotJson) => Slot.fromJson(slotJson)).toList();
  //
  //       setState(() {
  //         // Update any necessary state variables
  //       });
  //
  //       return slots;
  //     } else {
  //       throw Exception('Failed to fetch slots');
  //     }
  //   } catch (e) {
  //     throw Exception('Errortimeslots: $e');
  //   }
  // }
  Future<List<Slot>> fetchTimeSlots(DateTime selectedDate, int branchId) async {
    setState(() {
      isLoading = true; // Set isLoading to true before making the API request
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final url =
        Uri.parse("$baseUrl$GetSlotsByDateAndBranch$formattedDate/$branchId");
    print('url==>969: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        final List<dynamic> slotData = jsonResult['listResult'];

        List<Slot> slots =
            slotData.map((slotJson) => Slot.fromJson(slotJson)).toList();

        setState(() {
          isLoading = false; // Set isLoading to false after data is fetched
          // Update any necessary state variables
        });

        return slots;
      } else {
        throw Exception('Failed to fetch slots');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Set isLoading to false if error occurs
      });
      throw Exception('Error fetching time slots: $e');
    }
  }

  void showCustomToastMessageLong(
    String message,
    BuildContext context,
    int backgroundColorType,
    int length,
  ) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double textWidth = screenWidth / 1.5; // Adjust multiplier as needed

    final double toastWidth = textWidth + 32.0; // Adjust padding as needed
    final double toastOffset = (screenWidth - toastWidth) / 2;

    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        bottom: 16.0,
        left: toastOffset,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            width: toastWidth,
            decoration: BoxDecoration(
              border: Border.all(
                color: backgroundColorType == 0 ? Colors.green : Colors.red,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(Duration(seconds: length)).then((value) {
      overlayEntry.remove();
    });
  }

  bool validateEmailFormat(String email) {
    const pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
    final regex = RegExp(pattern);

    if (email.isEmpty) {
      return false;
    }

    // Check if the email address ends with a dot in the domain part
    if (email.endsWith('.')) {
      return false;
    }

    return regex.hasMatch(email);
  }

  Future<void> fetchData() async {
    final url = Uri.parse(baseUrl + getdropdown);
    final response = await http.get((url));
    // final url =  Uri.parse(baseUrl+GetHolidayListByBranchId+'$branchId');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dropdownItems = data['listResult'];
        print("widget.data.purposeOfVisitId: ${widget.data.purposeOfVisitId}");
        print("Dropdown items:");
        for (var item in dropdownItems) {
          print("Item: $item");
        }

        // Assuming widget.data.purposeOfVisitId is the value you want to match
        selectedTypeCdId = dropdownItems.indexWhere(
            (item) => item['typeCdId'] == widget.data.purposeOfVisitId);
        print("selectedTypeCdId: $selectedTypeCdId"); // Print selectedTypeCdId
        if (selectedTypeCdId != -1) {
          selectedName = widget.data.purposeOfVisit;
          selectedValue =
              widget.data.purposeOfVisitId; // Prepopulate selectedName
        } else {
          ispurposeselected = false;
        }
        print('BranchId:$BranchId');
        print('selectedName:$selectedName');
      });
    } else {
      print('Failed to fetch data');
    }
  }

  Future<bool> onBackPressed(BuildContext context) {
    // Navigate back when the back button is pressed
    Navigator.pop(context);
    // Return false to indicate that we handled the back button press
    return Future.value(false);
  }

  // Future<void> onCreate(String date, String time, String branchname, String branchaddress) async {
  //   print('date=======$date');
  //   eventDate = DateFormat("dd MMM yyyy").parse(date);
  //   print('eventDate=======$eventDate');
  //   print('time=======$time');
  //   eventTime = convertStringToTimeOfDay(time);
  //   print('eventTime=======$eventTime');
  //   await notificationService.showNotification(
  //     0,
  //     _textEditingController.text,
  //     "A new Appointment has been created.",
  //     jsonEncode({
  //       "title": _textEditingController.text,
  //       "eventDate": DateFormat("EEEE, d MMM y").format(eventDate!),
  //       "eventTime": eventTime!.format(context),
  //     }),
  //   );
  //
  //   await notificationService.scheduleNotification(
  //     1,
  //     _textEditingController.text,
  //     "Reminder for your scheduled Appointment at ${eventTime!.format(context)} At ${branchname} branch  at ${branchaddress}",
  //     eventDate!,
  //     eventTime!,
  //     jsonEncode({
  //       "title": _textEditingController.text,
  //       "eventDate": DateFormat("EEEE, d MMM y").format(eventDate!),
  //       "eventTime": eventTime!.format(context),
  //     }),
  //     // getDateTimeComponents(),
  //   );
  //
  //   //  resetForm();
  // }

  TimeOfDay convertStringToTimeOfDay(String timeString) {
    // Split the timeString into hour, minute, and period (AM/PM)
    List<String> timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(' ')[0]);
    String period = timeParts[1].split(' ')[1];

    // Adjust hour if it's PM
    if (period == 'PM' && hour != 12) {
      hour += 12;
    }

    // Create and return a TimeOfDay object
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> fetchTechnicians() async {
    try {
      final url = Uri.parse(baseUrl + getTechnicians);
      final requestBody = {
        "branchId": widget.data.branchId,
        "date": selecteddate,
        "slot": timeSlotParts[0]

        // "branchId": 4,
        // "date": "2024-05-29T15:25:27.7701898+05:30",
        // "slot": 3
      };
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print(
          'fetchTechnicians branchId: ${widget.data.branchId} , selecteddate: $selecteddate');
      print('fetchTechnicians slot: ${timeSlotParts[0] ?? 'xxx'}');
      print('fetchTechnicians url: $url');
      print('fetchTechnicians requestBody: ${json.encode(requestBody)}');
      print('fetchTechnicians response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          dropdownForTechnicians = data['listResult'] ?? [];
        });
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('fetchTechnicians catch: $e');
      rethrow;
    }
  }
}

class RadioButtonOption {
  final int? typeCdId;
  final String desc;

  RadioButtonOption({required this.typeCdId, required this.desc});

  factory RadioButtonOption.fromJson(Map<String, dynamic> json) {
    return RadioButtonOption(
      typeCdId: json['typeCdId'] ?? 0,
      desc: json['desc'] ?? '',
    );
  }
}

class dropdown {
  final int typeCdId_1;
  final String desc_1;

  dropdown({required this.typeCdId_1, required this.desc_1});

  factory dropdown.fromJson(Map<String, dynamic> json) {
    return dropdown(
      typeCdId_1: json['TypeCdId'] ?? 0,
      desc_1: json['Desc'] ?? '',
    );
  }
}

class Holiday {
  final int id;
  final int branchId;
  final DateTime holidayDate;
  final bool isActive;
  final String comments;
  final String name;
  final String createdBy;
  final String updatedBy;

  Holiday({
    required this.id,
    required this.branchId,
    required this.holidayDate,
    required this.isActive,
    required this.comments,
    required this.name,
    required this.createdBy,
    required this.updatedBy,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? 0,
      branchId: json['branchId'] ?? 0,
      holidayDate: DateTime.parse(json['holidayDate'] ?? ''),
      isActive: json['isActive'] ?? false,
      comments: json['comments'] ?? '',
      name: json['name'] ?? '',
      createdBy: json['createdBy'] ?? '',
      updatedBy: json['updatedBy'] ?? '',
    );
  }
}

class HolidayResponse {
  final List<Holiday> listResult;

  HolidayResponse({required this.listResult});

  factory HolidayResponse.fromJson(List<dynamic> json) {
    List<Holiday> holidays =
        json.map((holidayJson) => Holiday.fromJson(holidayJson)).toList();
    return HolidayResponse(listResult: holidays);
  }
}
