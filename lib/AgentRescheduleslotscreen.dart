import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Appointment.dart';
import 'Booking_Screen.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:hairfixingzone/AgentHome.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';

import 'Common/common_styles.dart';

class Agentrescheduleslotscreen extends StatefulWidget {
  final Appointment data;
  final int userId;

  const Agentrescheduleslotscreen({
    super.key,
    required this.userId,
    required this.data,
  });

  @override
  _AgentrescheduleslotscreenState createState() =>
      _AgentrescheduleslotscreenState();
}

class _AgentrescheduleslotscreenState extends State<Agentrescheduleslotscreen> {
  List<String> timeSlots = [];
  List<String> availableSlots = [];
  List<String?> timeSlotParts = [];
  String _selectedTimeSlot = '';
  String _selectedSlot = '';
  String availableSlotsText = '';
  String? dropValue;
  String AvailableSlots = '';
  List<dropdown> drop = [];
  int? dropdownid;
  late List<String> _subSlots;
  late String selectedOption;
  late String selectedDate;
  bool isDropdownValid = true;
  int selectedGender = -1;
  bool isGenderSelected = false;
  bool slotSelection = false;
  bool _isLastSlotSelected = false;
  bool slotselection = false;
  List<Slot> visableSlots = [];
  final bool _isPhoneIconFocused = false;
  TextEditingController dateInput = TextEditingController();
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
  List<Slot> slots = [];
  bool isButtonEnabled = true;
  bool isLoading = true;
  late bool isSlotsAvailable;
  bool isNextSlotsAvailable = false;
  List<Slot> disabledSlots = [];
  List<Slot> visibleSlots = [];
  late int branchId;
  List<DateTime> disabledDates = [];
  List<Holiday> holidayList = [];
  bool _isTodayHoliday = false;
  late DateTime holidayDate;
  bool isTodayHoliday = false;
  List<dynamic> dropdownItems = [];
  List<dynamic> dropdownForTechnicians = [];
  int selectedTypeCdId = -1;
  int selectedTechnician = -1;
  int? selectedTechnicianValue;
  String? selectedTechnicianName;
  int selectedValue = 0;
  String? selectedName;
  String userFullName = '';
  String email = '';
  String phoneNumber = '';

  int gender = 0;
  String genderText = '';
  int? userId;
  String? contactNumber;
  bool showConfirmationDialog = false;
  int? id;
  bool _fullNameError = false;
  String? _fullNameErrorMsg;
  bool isFullNameValidate = false;
  FocusNode fullNameFocus = FocusNode();
  bool isPurposeSelected = false;
  String? _selectedTimeSlot24;
  bool ispurposeselected = false;
  int? genderTypeId;
  final TextEditingController _textEditingController =
      TextEditingController(text: "Hair Fixing Appointment");
  DateTime currentDate = DateTime.now();
  DateTime? eventDate;
  TimeOfDay currentTime = TimeOfDay.now();
  TimeOfDay? eventTime;
  final ScrollController _scrollController = ScrollController();
  FocusNode mobileNumberFocus = FocusNode();
  bool isMobileNumberValidate = false;
  bool _mobileNumberError = false;
  String? _mobileNumberErrorMsg;
  String? selecteddate;

  String phonenumber = '';

  String Gender = '';
  int? agentId;
  int? Id;
  @override
  void dispose() {
    _dateController.dispose();
    _fullnameController1.dispose();
    _phonenumberController2.dispose();
    _emailController3.dispose();
    _purposeController4.dispose();
    _textEditingController.dispose();
    _scrollController.dispose();
    dateInput.dispose();
    mobileNumberFocus.dispose();
    fullNameFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // getUserDataFromSharedPreferences();
    print("====Agent user Id ${widget.userId}");
    branchId =
        widget.data.branchId; // Ensure this property exists in Appointment
    dropValue = 'Select';

    _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    selecteddate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fullnameController1.text = widget.data.customerName ?? '';
    _phonenumberController2.text = widget.data.phoneNumber ?? '';
    _checkInternetAndFetchData();
  }

  Future<void> _checkInternetAndFetchData() async {
    bool isConnected = await CommonUtils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
      try {
        final holidayResponse = await fetchHolidayListByBranchId();
        print(holidayResponse);
      } catch (e) {
        print('Error fetching holiday list: $e');
      }
      _fetchTimeSlots();
      fetchData();
    } else {
      CommonUtils.showCustomToastMessageLong(
          'Not connected to the internet', context, 1, 4);
      print('Not connected to the internet');
    }
  }

  Future<void> _fetchTimeSlots() async {
    try {
      List<Slot> fetchedSlots =
          await fetchTimeSlots(DateTime.parse(selecteddate!), branchId);
      setState(() {
        slots = fetchedSlots;
      });
    } catch (error) {
      print('Error fetching time slots: $error');
    }
  }

  // Future<void> getUserDataFromSharedPreferences() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   Id = prefs.getInt('userId') ?? 0;
  //   userFullName = prefs.getString('userFullName') ?? '';
  //   genderttypeid = prefs.getInt('genderTypeId');
  //   phonenumber = prefs.getString('contactNumber') ?? '';
  //   email = prefs.getString('email') ?? '';
  //   contactNumber = prefs.getString('contactNumber') ?? '';
  //   // genderbyid = prefs.getString('gender');
  // }

  Future<Holiday?> fetchHolidayListByBranchId() async {
    final url = Uri.parse(baseUrl + getholidayslist);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'id': branchId,
          'isActive': true,
          "fromdate": null,
          "todate": null
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final holidayResponse = HolidayResponse.fromJson(jsonResponse);
        holidayList = holidayResponse.listResult ?? [];

        DateTime currentDate = DateTime.now();
        String formattedDate = DateFormat("yyyy-MM-dd").format(currentDate);
        print('formattedDate: $formattedDate');

        isTodayHoliday = holidayList.any((holiday) {
          String holidayDate =
              DateFormat("yyyy-MM-dd").format(holiday.holidayDate);
          print('holidayDate: $holidayDate');
          return formattedDate == holidayDate;
        });

        if (isTodayHoliday) {
          print('Today is a holiday: $formattedDate');
        }

        return Holiday.fromJson(jsonResponse);
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Request failed with exception: $e');
    }
  }

  Future<void> _openDatePicker(bool isTodayHoliday) async {
    setState(() => _isTodayHoliday = isTodayHoliday);

    DateTime initialDate = _selectedDate;
    if (_isTodayHoliday) {
      initialDate = getNextNonHoliday(DateTime.now());
    }

    while (!selectableDayPredicate(initialDate)) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2125),
      selectableDayPredicate: selectableDayPredicate,
    );

    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  void onDateSelected(DateTime selectedDate) async {
    _selectedDate = selectedDate;
    selecteddate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    setState(() {
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
      isTodayHoliday = false;
      slotselection = false;
      _selectedTimeSlot = '';
    });

    if (await CommonUtils.checkInternetConnectivity()) {
      print('Connected to the internet');
      fetchTimeSlots(DateTime.parse(selecteddate!), branchId).then((value) {
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

  String? validateMobilenum(String? value) {
    if (value == null || value.isEmpty) {
      _setMobileError('Please Enter Mobile Number');
      return null;
    }
    if (!RegExp(r'^[5-9]\d{9}$').hasMatch(value)) {
      _setMobileError('Enter a valid 10-digit mobile number starting with 5-9');
      return null;
    }
    isMobileNumberValidate = true;
    return null;
  }

  void _setMobileError(String message) {
    setState(() {
      _mobileNumberError = true;
      _mobileNumberErrorMsg = message;
      isMobileNumberValidate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredWidth = screenWidth;
    isSlotsAvailable = getVisibleSlots(slots, isTodayHoliday).isNotEmpty;
    disabledSlots = getDisabledSlots(slots);
    visableSlots = getVisibleSlots(slots, isTodayHoliday);

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
                      SizedBox(
                        height: 5,
                      ),
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
                                      widget.data.name,
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
                      SizedBox(
                        height: 10,
                      ),
                      const Row(
                        children: [
                          Text(
                            'Customer Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF11528f),
                            ),
                          ),
                          Text(' *',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller:
                            _fullnameController1, // Assigning the controller
                        keyboardType: TextInputType.name,
                        readOnly: true,
                          enabled:false,
                          // obscureText: true,
                        onChanged: (value) {
                          //MARK: Space restrict
                          setState(() {
                            if (value.startsWith(' ')) {
                              _fullnameController1.value = TextEditingValue(
                                text: value.trimLeft(),
                                selection: TextSelection.collapsed(
                                    offset: value.trimLeft().length),
                              );
                            }
                            _fullNameError = false;
                          });
                        },
                        maxLength: 60,
                        decoration: InputDecoration(
                          errorText: _fullNameError ? _fullNameErrorMsg : null,
                          errorMaxLines: 2,
                          contentPadding: const EdgeInsets.only(
                              top: 15, bottom: 2, left: 15, right: 15),
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
                          hintText: 'Enter Customer Name',
                          counterText: "",
                          hintStyle: CommonStyles.texthintstyle,
                        ),
                        validator: validatefullname,
                        style: CommonStyles.texthintstyle,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Row(
                        children: [
                          Text(
                            'Mobile Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Outfit",
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF11528f),
                            ),
                          ),
                          Text(' *',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller:
                            _phonenumberController2, // Assigning the controller
                        keyboardType: TextInputType.phone,
                        readOnly: true,
                        enabled:false,
                        // obscureText: true,
                        validator: validateMobilenum,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value.length == 1 &&
                                ['0', '1', '2', '3', '4'].contains(value)) {
                              _phonenumberController2.clear();
                            }
                            if (value.startsWith(' ')) {
                              _phonenumberController2.value = TextEditingValue(
                                text: value.trimLeft(),
                                selection: TextSelection.collapsed(
                                    offset: value.trimLeft().length),
                              );
                            }
                            _mobileNumberError = false;
                          });
                        },
                        maxLength: 10,
                        decoration: InputDecoration(
                          errorText:
                              _mobileNumberError ? _mobileNumberErrorMsg : null,
                          errorMaxLines: 2,
                          contentPadding: const EdgeInsets.only(
                              top: 15, bottom: 2, left: 15, right: 15),
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
                          hintText: 'Enter Mobile Number',
                          counterText: "",
                          hintStyle: CommonStyles.texthintstyle,
                        ),
                        // validator: validatefullname,
                        style: CommonStyles.texthintstyle,
                      ),

                      const SizedBox(
                        height: 10,
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
                                                    // fetchTechnicians();
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

                      const SizedBox(height: 40),

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
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )));
  }

  String? validatefullname(String? value) {
    if (value!.isEmpty) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Please Enter Customer Name';
        // _scrollToAndFocus(FullnameFocus, 0);
      });
      isFullNameValidate = false;
      return null;
    }
    if (value.length < 2) {
      setState(() {
        _fullNameError = true;
        _fullNameErrorMsg = 'Full Name Should Contains Minimum 2 Characters';
        //  _scrollToAndFocus(FullnameFocus, 0);
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
        //  _scrollToAndFocus(FullnameFocus, 0);
      });
      isFullNameValidate = false;
      return null;
    }
    isFullNameValidate = true;
    return null;
  }

  Future<void> validatePurpose(String? value) async {
    if (_formKey.currentState!.validate()) {
      if (isFullNameValidate && isMobileNumberValidate) {
        if (!isSlotsAvailable) {
          showCustomToastMessageLong(
              'No Slots Are Available Today', context, 1, 4);
          return; // Stop further execution if no slots are available
        }
        if (!slotselection) {
          showCustomToastMessageLong('Please Select A Slot', context, 1, 4);
          return; // Stop execution if no slot has been selected
        }
        if (value == null || value.isEmpty) {
          ispurposeselected = true; // Flag purpose as not selected
          setState(() {}); // Trigger UI update for validation message
          showCustomToastMessageLong(
              'Please Select A Purpose of Visit', context, 1, 4);
          return; // Stop execution if purpose is not selected
        }

        // If all validations pass, proceed to book the appointment
        bookappointment();
      }

      // Check if no slots are available

      // Check if the selected purpose is "New Hair Patch"

      // if (selectedValue == 7) {
      //
      //   if (!isnextSlotsAvailable) {
      //     // Show message if the next slot is not available
      //     showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
      //     return; // Stop execution since next slot is needed for "New Hair Patch"
      //   }
      // }
      // print('_isLastSlotSelected:$_isLastSlotSelected');
      // if ((selectedValue != 7 && !isnextSlotsAvailable) || (selectedValue == 7 && !isnextSlotsAvailable && !_isLastSlotSelected)) {
      //   showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
      //   return;
      // }
      // if (selectedValue == 7 && !_isLastSlotSelected && !isnextSlotsAvailable) {
      //   showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
      //   return;
      // }
      // if (selectedValue == 7) {
      //   // If it's the last slot selected, do not show the toast
      //   if (_isLastSlotSelected) {
      //     return; // Exit without showing the toast
      //   }
      //
      //   // If next slots are not available and it's not the last slot, show the toast
      //   if (!isnextSlotsAvailable) {
      //     showCustomToastMessageLong('Next Slot is not Available', context, 1, 4);
      //     return;
      //   }
      // }
      // Check if a slot has been selected

      // Check if the purpose of visit has been selected
    }
  }

  Future<void> bookappointment() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse(baseUrl + postApiAppointment);
      print('url==>890: $url');
      String fullName = _fullnameController1.text;
      String phonenumber = _phonenumberController2.text;
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
        "customerName": fullName,
        "phoneNumber": phonenumber,
        "email": email,
        "genderTypeId": null,
        "statusTypeId": 18,
        "purposeOfVisitId": selectedValue,
        "isActive": true,
        "createdDate": dateTimeString,
        "updatedDate": dateTimeString,
        "updatedByUserId": widget.userId,
        "rating": null,
        "review": null,
        "reviewSubmittedDate": null,
        // "timeofslot": widget.data.timeofSlot,
        "timeofslot": '$_selectedTimeSlot24',
        "customerId": null,
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
          // LoadingProgress.stop(context);
          // Extract the necessary information
          bool isSuccess = data['isSuccess'];
          progressDialog.dismiss();
          DateTime testdate = DateTime.now();
          print(' testdate ====$testdate');
          if (isSuccess == true) {
            print('Request sent successfully');
            CommonUtils.showCustomToastMessageLong(
                'Appointment Rescheduled  Successfully', context, 0, 5);
            /*  Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                /*  builder: (context) => TestAgentOplist(
                    userId: widget.userId,
                    branchId: widget.branchId,
                    branchAddress: 'widget.branchAddress'), */
                builder: (context) => AgentHome(userId: widget.userId),
              ),
            ); */
            Navigator.of(context).pop(true);
          } else {
            progressDialog.dismiss();
            print('statusmesssage${data['statusMessage']}');
            CommonUtils.showCustomToastMessageLong(
                '${data['statusMessage']}', context, 1, 5);
          }

          setState(() {
            isButtonEnabled = true;
            progressDialog.dismiss();
          });
        } else {
          progressDialog.dismiss();
          // ProgressManager.stopProgress();
          //showCustomToastMessageLong(
          // 'Failed to send the request', context, 1, 2);
          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        progressDialog.dismiss();
        // ProgressManager.stopProgress();
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

  // List<Slot> filteredSlots = [];

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
        print('selectedName:$selectedName');
      });
    } else {
      print('Failed to fetch data');
    }
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Id = prefs.getInt('userId') ?? 0;
    userFullName = prefs.getString('userFullName') ?? '';
    //  genderttypeid = prefs.getInt('genderTypeId');
    phonenumber = prefs.getString('contactNumber') ?? '';
//    email = prefs.getString('email') ?? '';
    contactNumber = prefs.getString('contactNumber') ?? '';
    // genderbyid = prefs.getString('gender');
  }
}

Future<bool> onBackPressed(BuildContext context) {
  // Navigate back when the back button is pressed
  Navigator.pop(context);
  // Return false to indicate that we handled the back button press
  return Future.value(false);
}

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
