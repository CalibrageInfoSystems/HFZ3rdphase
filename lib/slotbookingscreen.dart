import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CommonUtils.dart';
import 'CustomRadioButton.dart';
import 'Room.dart';
import 'api_config.dart';

class slotbookingscreen extends StatefulWidget {
  final int branchId;
  final String branchname;
  final String branchlocation;
  final String filepath;
  final String MobileNumber;
  final int appointmentId; // New field
  final String screenFrom; // New field

  slotbookingscreen({
    required this.branchId,
    required this.branchname,
    required this.branchlocation,
    required this.filepath,
    required this.MobileNumber,
    required this.appointmentId, // New field
    required this.screenFrom, // New field
  });
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

class _BookingScreenState extends State<slotbookingscreen>  {
  List<String> timeSlots = [];
  List<String> availableSlots = [];
  List<String> timeSlotParts = [];
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

  bool _isPhoneIconFocused = false;
  TextEditingController dateinput = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Room? _selectedRoom;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _fullnameController1 = TextEditingController();
  TextEditingController _phonenumberController2 = TextEditingController();
  TextEditingController _emailController3 = TextEditingController();
  TextEditingController _purposeController4 = TextEditingController();
  bool isBackButtonActivated = false;
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
  int selectedTypeCdId = -1;
  late int selectedValue;
  late String selectedName;
  String userFullName = '';
  String email = '';
  String phonenumber = '';
  int gender = 0;
  String Gender = '';
  int? userId;
  bool showConfirmationDialog = false;
  @override
  @override
  initState() {
    super.initState();
    print('branchId ID: ${widget.branchId}');
    print('branchname: ${widget.branchname}');
    print('branchaddress: ${widget.branchlocation}');
    print('filepath: ${widget.filepath}');
    print('MobileNumber: ${widget.MobileNumber}');
    print('screenFrom: ${widget.screenFrom}');
    print('appointmentId: ${widget.appointmentId}');
    loadUserData();
    //fetchdropdown();
    BranchId = widget.branchId;
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
        } catch (e) {
          print('Error: $e');
        }
        fetchTimeSlots(DateTime.parse(selecteddate), widget.branchId).then((value) {
          setState(() {
            slots = value;
          });
        }).catchError((error) {
          print('Error fetching time slots: $error');
        });
        fetchRadioButtonOptions();
        fetchData();

      } else {
        CommonUtils.showCustomToastMessageLong('Please Check Your Internet Connection', context, 1, 4);
        print('Not connected to the internet');
      }
    });
  }


  @override
  void dispose() {
    _dateController.dispose();

    super.dispose();
  }



  Future<void> _makePhoneCall(String phoneNumber) async {
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userFullName = prefs.getString('userFullName') ?? '';
      email = prefs.getString('email') ?? '';
      phonenumber = prefs.getString('contactNumber') ?? '';
      Gender = prefs.getString('gender') ?? '';
      userId = prefs.getInt('userId');
      _fullnameController1.text = userFullName;
      _emailController3.text = email;
      _phonenumberController2.text = phonenumber;
      isGenderSelected = true;
      // gender = selectedGender;
      print('userId:$userId');
      print('gender:$Gender');
      if (Gender == 'Female') {
        gender = 1;
      } else if (Gender == 'Male') {
        gender = 2;
      } else if (Gender == 'Other') {
        gender = 3;
      }
    });
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
    return  WillPopScope(
        onWillPop: () => onBackPressed(context), child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                backgroundColor: Color(0xFFFB4110),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop(); // Navigate back to the previous screen
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2)),
                    Image.asset(
                      'assets/logo.png',
                      width: 100,
                      height: 180,
                    ),
                  ],
                )),
            //body: YourBodyWidget(),
            // Replace YourBodyWidget with your actual content

            body:Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 10, right: 10),
                    child: Stack(alignment: Alignment.topCenter, children: [
                      SizedBox(
                        width: desiredWidth,
                        height: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Image.network(
                          widget.filepath,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 90.0,
                        child: Container(
                          height: 150,
                          width: desiredWidth * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(28.0),
                              bottomLeft: Radius.circular(28.0),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 8.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFD7DEFA),
                                spreadRadius: -15.0,
                                blurRadius: 20.0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFEE7E1), // Start color
                                    Color(0xFFD7DEFA), // End color
                                  ],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Positioned(
                                    right: 26.0,
                                    top: 50.0,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Handle the click event
                                        // Add your desired functionality here
                                        _makePhoneCall('tel:' + widget.MobileNumber);
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 5000),
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xFF042DE3),
                                            width: 1,
                                          ),
                                        ),
                                        transform: Matrix4.identity()..scale(_isPhoneIconFocused ? 1.2 : 1.0),
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0),
                                          child: SvgPicture.asset(
                                            'assets/phone_1.svg',
                                            height: 34,
                                            width: 34,
                                            color: Color(0xFF042DE3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 16.0,
                                        top: 39.0,
                                      ),
                                      child: Image.asset(
                                        'assets/location_icon.png',
                                        width: 15,
                                        height: 18,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 18.0,
                                        top: 15.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 4.0),
                                            child: Text(
                                              widget.branchname,
                                              style: TextStyle(
                                                color: Color(0xFFFB4110),
                                                fontSize: 18,
                                                fontFamily: 'Outfit',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(right: 70.0, left: 18.0),
                                              child: Text(
                                                widget.branchlocation,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: 'Outfit',
                                                ),
                                                maxLines: 6,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        //  padding: EdgeInsets.only(left:5 ,top: 10.0,right: 5),
                        padding: EdgeInsets.fromLTRB(15.0, 250.0, 15.0, 20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 1.0, right: 0),
                                child: GestureDetector(
                                  onTap: () async {
                                    _openDatePicker(isTodayHoliday);
                                  },
                                  child: Container(
                                    width: desiredWidth * 0.9,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Color(0xFF163CF1), width: 1.5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: AbsorbPointer(
                                      child: SizedBox(
                                        child: TextFormField(
                                          controller: _dateController,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Select date',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 14,
                                              color: Color(0xFFFB4110),
                                              fontWeight: FontWeight.w300,
                                            ),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: SvgPicture.asset(
                                                'assets/datepicker_icon.svg',
                                                width: 20.0,
                                              ),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Padding(
                                padding: EdgeInsets.all(5.0), // Adjust the padding values as needed
                                child: Column(
                                  children: [
                                    Visibility(
                                      visible: !isTodayHoliday,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Select Slot',
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFFB4110),
                                          ),
                                        ),
                                      ),
                                    ),
                                    //bool slotsAvailable = getVisibleSlots(slots).isNotEmpty;

                                    // bool isSlotsAvailable = getVisibleSlots(slots).isNotEmpty;

                                    Scrollbar(
                                      child: isLoading
                                          ? Center(
                                              child: CircularProgressIndicator(),
                                            )
                                          : isSlotsAvailable
                                              ? GridView.builder(
                                                  shrinkWrap: true,
                                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    childAspectRatio: 2.5,
                                                  ),
                                                  itemCount: getVisibleSlots(slots, isTodayHoliday).length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    final visibleSlots = getVisibleSlots(slots, isTodayHoliday);
                                                    if (i >= visibleSlots.length) {
                                                      return SizedBox.shrink();
                                                    }

                                                    final slot = visibleSlots[i];

                                                    return Container(
                                                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                      child: ElevatedButton(
                                                        onPressed: slot.availableSlots <= 0
                                                            ? null
                                                            : () {
                                                                setState(() {
                                                                  _selectedTimeSlot = slot.SlotTimeSpan;
                                                                  _selectedSlot = slot.slot;
                                                                  AvailableSlots = slot.availableSlots.toString();
                                                                  timeSlotParts = _selectedSlot.split(' - ');
                                                                  slotselection = true;
                                                                  print('===123==$timeSlotParts[0]');
                                                                  print('===12===$timeSlotParts[1]');
                                                                  print('==234==$_selectedTimeSlot');
                                                                  print('===567==$_selectedSlot');
                                                                  print('==900==$AvailableSlots');
                                                                });
                                                              },
                                                        style: ElevatedButton.styleFrom(
                                                          padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0) , backgroundColor: _selectedTimeSlot == slot.SlotTimeSpan
                                                              ? Colors.green
                                                              : (slot.availableSlots <= 0 ? Colors.grey : Colors.white),
                                                          side: BorderSide(
                                                            color: _selectedTimeSlot == slot.SlotTimeSpan
                                                                ? Colors.green
                                                                : (slot.availableSlots <= 0 ? Colors.transparent : Colors.green),
                                                            width: 2.0,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(5.0),
                                                          ),
                                                          textStyle: TextStyle(
                                                            color: _selectedTimeSlot == slot.SlotTimeSpan ? Colors.white : Colors.black,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          slot.SlotTimeSpan,
                                                          style: TextStyle(
                                                            color: _selectedTimeSlot == slot.SlotTimeSpan
                                                                ? Colors.white
                                                                : (slot.availableSlots <= 0 ? Colors.white : Colors.black),
                                                            fontFamily: 'Outfit',
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : isTodayHoliday
                                                  ? Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'Today is a holiday',
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

                                                  : Center(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'No Slots Available',
                                                            style: TextStyle(
                                                              fontFamily: 'Outfit',
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 0.0, top: 10.0, right: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20, // Adjust the width as needed
                                      height: 20, // Adjust the height as needed
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.green, // Set the border line color
                                          width: 2, // Set the border line width
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6), // Add spacing between icon and text
                                    Text(
                                      'Available', // Replace with your desired text
                                      style: TextStyle(fontSize: 12), // Set the text style
                                    ),
                                    SizedBox(width: 13),
                                    Container(
                                      width: 20, // Adjust the width as needed
                                      height: 20, // Adjust the height as needed
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border.all(
                                          color: Colors.green, // Set the border line color
                                          width: 2, // Set the border line width
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6), // Add spacing between icon and text
                                    Text(
                                      'Selected', // Replace with your desired text
                                      style: TextStyle(fontSize: 12), // Set the text style
                                    ),
                                    SizedBox(width: 13),
                                    Container(
                                      width: 20, // Adjust the width as needed
                                      height: 20, // Adjust the height as needed
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        border: Border.all(
                                          color: Colors.grey, // Set the border line color
                                          width: 2, // Set the border line width
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10), // Add spacing between icon and text
                                    Text(
                                      'No Slots', // Replace with your desired text
                                      style: TextStyle(fontSize: 12), // Set the text style
                                    ),
                                  ],
                                ),
                                // buildRow( 'Avaliable',true,false,false),
                                // SizedBox(width: 8),
                                // buildRow( 'Selected',false,true,false),
                                // SizedBox(width: 8),
                                // buildRow( 'Not Available',false, false,true),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 1.0, right: 0),
                                child: GestureDetector(
                                  child: Container(
                                    width: desiredWidth * 0.9,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Color(0xFF163CF1),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/User_icon.svg',
                                            width: 20.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 10, top: 6.0),
                                              child: TextFormField(
                                                keyboardType: TextInputType.name,
                                                controller: _fullnameController1,
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  hintText: 'Full Name',
                                                  hintStyle: TextStyle(
                                                    fontFamily: 'Outfit',
                                                    fontSize: 14,
                                                    color: Color(0xFFFB4110),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle the click event for the third text view
                                    print('Third Text View Clicked');
                                  },
                                  child: Container(
                                    width: desiredWidth * 0.9,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Color(0xFF163CF1),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/phone_1.svg',
                                            width: 20.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 10.0),
                                              child: TextFormField(
                                                // initialValue: 'Phone Number',
                                                maxLength: 10,
                                                keyboardType: TextInputType.number,
                                                controller: _phonenumberController2,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                ],
                                                readOnly: true,
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Phone Number',
                                                  hintStyle: TextStyle(
                                                    fontFamily: 'Outfit',
                                                    fontSize: 14,
                                                    color: Color(0xFFFB4110),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                  counterText: '',

                                                  border: InputBorder.none,
                                                  // Remove the underline border
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle the click event for the fourth text view
                                    print('Fourth Text View Clicked');
                                  },
                                  child: Container(
                                    width: desiredWidth * 0.9,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Color(0xFF163CF1),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: SvgPicture.asset(
                                            'assets/Mail_icon.svg',
                                            width: 20.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: EdgeInsets.only(left: 10.0),
                                              child: TextFormField(
                                                // initialValue: 'Email',
                                                controller: _emailController3,
                                                keyboardType: TextInputType.emailAddress,
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  hintText: 'Email',
                                                  hintStyle: TextStyle(
                                                    fontFamily: 'Outfit',
                                                    fontSize: 14,
                                                    color: Color(0xFFFB4110),
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                  border: InputBorder.none,
                                                  // Remove the underline border
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: Row(
                                        children: options.map((option) {
                                          return Row(
                                            children: [
                                              CustomRadioButton(
                                                selected: gender == option.typeCdId,
                                                onTap: () {
                                                  setState(() {
                                                    gender = option.typeCdId!;
                                                    //  print('selectedGender:$selectedGender');
                                                    isGenderSelected = true;
                                                  });
                                                  print(option.typeCdId);
                                                  print(option.desc);
                                                },
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                option.desc,
                                                style: TextStyle(
                                                  fontFamily: 'Outfit',
                                                  fontSize: 14,
                                                  color: Color(0xFFFB4110),
                                                ),
                                              ),
                                              SizedBox(width: 26),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(
                                      color: Color(0xFF163CF1),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButton<int>(
                                          value: selectedTypeCdId,
                                          iconSize: 30,
                                          icon: null,
                                          style: TextStyle(
                                            color: Color(0xFFFB4110),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedTypeCdId = value!;
                                              if (selectedTypeCdId != -1) {
                                                selectedValue = dropdownItems[selectedTypeCdId]['typeCdId'];
                                                selectedName = dropdownItems[selectedTypeCdId]['desc'];

                                                print("selectedValue:$selectedValue");
                                                print("selectedName:$selectedName");
                                              } else {
                                                print("==========");
                                                print(selectedValue);
                                                print(selectedName);
                                              }
                                              // isDropdownValid = selectedTypeCdId != -1;
                                            });
                                          },
                                          items: [
                                            DropdownMenuItem<int>(
                                              value: -1,
                                              child: Text('Select Purpose of Visit'), // Static text
                                            ),
                                            ...dropdownItems.asMap().entries.map((entry) {
                                              final index = entry.key;
                                              final item = entry.value;
                                              return DropdownMenuItem<int>(
                                                value: index,
                                                child: Text(item['desc']),
                                              );
                                            }).toList(),
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                                child: Container(
                                  width: 380,
                                  height: 60,
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: isButtonEnabled ? () => validatedata() : null,
                                      child: Container(
                                        width: desiredWidth * 0.9,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15.0),
                                          color: isButtonEnabled ? Color(0xFFFB4110) : Colors.grey,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Book Appointment',
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
                        ),
                      ),
                    ]),
                  ))
                ]))));
  }

  // Future<void> _openDatePicker(bool isTodayHoliday) async {
  //   setState(() {
  //     _isTodayHoliday = isTodayHoliday;
  //   });
  //
  //   DateTime initialDate = _selectedDate;
  //
  //   // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
  //   if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
  //     initialDate = getNextNonHoliday(DateTime.now()); // Use getNextNonHoliday to get the next available non-holiday day
  //   }
  //
  //   final DateTime? pickedDate = await showDatePicker(
  //     context: context,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     initialDate: initialDate,
  //     firstDate: DateTime.now().subtract(Duration(days: 0)),
  //     lastDate: DateTime(2125),
  //     selectableDayPredicate: selectableDayPredicate,
  //   );
  //
  //   if (pickedDate != null) {
  //     setState(() {
  //       _selectedDate = pickedDate;
  //       onDateSelected(pickedDate);
  //     });
  //   }
  // }
  Future<void> _openDatePicker(bool isTodayHoliday) async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    DateTime initialDate = _selectedDate;

    // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
    if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
      initialDate = getNextNonHoliday(DateTime.now()); // Use getNextNonHoliday to get the next available non-holiday day
    }

    // Ensure that the initialDate satisfies the selectableDayPredicate
    while (initialDate != null && !selectableDayPredicate(initialDate)) {
      initialDate = initialDate.add(Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 0)),
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

  bool isHoliday(DateTime date) {
    return holidayList
        .any((holiday) => date.year == holiday.holidayDate.year && date.month == holiday.holidayDate.month && date.day == holiday.holidayDate.day);
  }

  DateTime getNextNonHoliday(DateTime currentDate) {
    // Keep moving forward until a non-holiday day is found
    while (isHoliday(currentDate)) {
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return currentDate;
  }

  bool selectableDayPredicate(DateTime date) {
    final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));
    final isHolidayDate = isHoliday(date);
    final isPreviousYear = date.year < DateTime.now().year;

    // If today is a holiday and the selected date is a past date, allow selecting the next non-holiday date
    if (_isTodayHoliday && isHolidayDate && isPastDate) {
      return true;
    }

    // Return false if any of the conditions are met
    return !isPastDate && !isHolidayDate && !isPreviousYear && date.year >= DateTime.now().year;
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

  Future<void> validatedata() async {
    int disabledlength = disabledSlots.length;
    print('====887$disabledlength');
    int visablelength = visableSlots.length;
    print('==889$visablelength');
    bool isValid = true;
    bool hasValidationFailed = false;

    if (selectedTypeCdId == -1) {
      selectedName = "Select";
    }

    if (_dateController.text.isEmpty) {
      showCustomToastMessageLong('Please Select Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (!isSlotsAvailable) {
      showCustomToastMessageLong('No Slots Available Today', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    } else if (!slotselection) {
      showCustomToastMessageLong('Please Select slot', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (visablelength == disabledlength) {
      showCustomToastMessageLong('No Slots Available Today ', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (_selectedSlot == null) {
      showCustomToastMessageLong('Please Select Time Slot', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _fullnameController1.text.isEmpty) {
      showCustomToastMessageLong('Please Enter Your Full Name', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _phonenumberController2.text.isEmpty) {
      showCustomToastMessageLong('Please Enter Your Phone Number', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    } else {
      String value = _phonenumberController2.text;
      int? number = int.tryParse(value);
      if (isValid && number != null && number.toString().length < 10) {
        showCustomToastMessageLong('Please Enter Your Valid Mobile Number', context, 1, 2);
        isValid = false;
        hasValidationFailed = true;
      }
    }

    if (isValid && _emailController3.text.isEmpty) {
      showCustomToastMessageLong('Please Enter Your Email', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && !validateEmailFormat(_emailController3.text)) {
      showCustomToastMessageLong('Please Enter Valid Email', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && !isGenderSelected) {
      showCustomToastMessageLong('Please Select Gender', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && selectedTypeCdId == -1) {
      showCustomToastMessageLong('Please Select Purpose of Visit', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid) {
      // Disable the button after validation
      disableButton();
      // Define the API URL
      final url = Uri.parse(baseUrl + postApiAppointment);
      print('url==>890: $url');

      DateTime now = DateTime.now();
      // Using toString() method
      String dateTimeString = now.toString();
      print('DateTime as String: $dateTimeString');
      print('DateTime as String: $selecteddate');
      print('_selectedTimeSlot892 $_selectedTimeSlot');

      print('screenFrom1213: ${widget.screenFrom}');
      print('appointmentId1214: ${widget.appointmentId}');
      final request = {
        "id": widget.screenFrom == "ReSchedule" ? widget.appointmentId : null,
        "branchId": widget.branchId,
        "date": selecteddate,
        "slotTime": timeSlotParts[0],
        "customerName": _fullnameController1.text,
        "phoneNumber": _phonenumberController2.text,
        "email": _emailController3.text,
        "genderTypeId": gender,
        "statusTypeId": widget.screenFrom == "ReSchedule" ? 19 : 4,
        "purposeOfVisitId": selectedValue,
        "isActive": true,
        "createdDate": dateTimeString,
        "updatedDate": dateTimeString,
        "updatedByUserId": null,
        "rating": null,
        "review": null,
        "reviewSubmittedDate": null,
        "timeofslot": null,
        "customerId": userId,
        "paymentTypeId": null
      };

      print('Object: ${json.encode(request)}');
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
            print('Request sent successfully');
            showCustomToastMessageLong('Slot booked successfully', context, 0, 2);
            Navigator.pop(context);
            // Success case
            // Handle success scenario here
          } else {
            // Failure case
            // Handle failure scenario here
            CommonUtils.showCustomToastMessageLong(
                '${ data['statusMessage']}', context, 0, 2);

          }
          setState(() {
            isButtonEnabled = true;
          });
        } else {
          //showCustomToastMessageLong(
          // 'Failed to send the request', context, 1, 2);
          print('Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error slot: $e');
      }
    }
  }

  Future<void> fetchRadioButtonOptions() async {
    final url = Uri.parse(baseUrl + getgender);
    print('url==>946: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData != null && responseData['listResult'] is List<dynamic>) {
          final List<dynamic> optionsData = responseData['listResult'];
          setState(() {
            options = optionsData.map((data) => RadioButtonOption.fromJson(data)).toList();
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to fetch radio button options');
      }
    } catch (e) {
      throw Exception('Error Radio: $e');
    }
  }

  void onDateSelected(DateTime selectedDate) async {
    setState(() {
      isTodayHoliday = false;
      _selectedDate = selectedDate;
      _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      selecteddate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      _selectedTimeSlot = '';
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
      fetchTimeSlots(selectedDateTime, widget.branchId).then((value) {
        setState(() {
          slots = value;
          _selectedTimeSlot = '';
        });
      }).catchError((error) {
        print('Error fetching time slots: $error');
      });
      fetchRadioButtonOptions();
    } else {
      CommonUtils.showCustomToastMessageLong('Please Check Your Internet Connection', context, 1, 4);
      print('Not connected to the internet');
    }
  }

  List<Slot> getVisibleSlots(List<Slot> slots, bool isTodayHoliday) {
    print('isTodayHoliday====$isTodayHoliday');
    // Get the current time
    DateTime now = DateTime.now();

    // Format the time in 12-hour format
    String formattedTime = DateFormat('hh:mm a').format(now);

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Combine the current date and formatted time
    String combinedDateTimeString = DateFormat('yyyy-MM-dd').format(currentDate) + ' ' + formattedTime;

    // Parse the combined date and time string into a DateTime object
    DateTime combinedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(combinedDateTimeString);

    if (isTodayHoliday) {
      // Today is a holiday, return an empty list
      return [];
    }

    if (slots.isEmpty) {
      // Return a list with a single Slot object containing the message
      // return 'Slots not available';
    }

    return slots.where((slot) {
      String timespan = slot.SlotTimeSpan;
      // Combine the current date and formatted time
      String SlotDateTimeString = DateFormat('yyyy-MM-dd').format(currentDate) + ' ' + timespan;

      DateFormat dateformat = DateFormat('yyyy-MM-dd');
      String currentdate = dateformat.format(DateTime.now());
      String formattedapiDate = dateformat.format(slot.date);

      // // Parse the combined date and time string into a DateTime object
      // DateTime SlotDateTime =
      // DateFormat('yyyy-MM-dd hh:mm a').parse(SlotDateTimeString);

      DateTime slotDateTime;
      if (currentdate == formattedapiDate) {
        // If the slot is for the current date, use the slot's time
        String timespan = slot.SlotTimeSpan;

        // Combine the current date and time span
        String SlotDateTimeString = DateFormat('yyyy-MM-dd').format(currentDate) + ' ' + timespan;

        // Parse the combined date and time string into a DateTime object
        slotDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(SlotDateTimeString);
      } else {
        // If the slot is for a different date, use the slot's date and time
        slotDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('${formattedapiDate} ${timespan}');
      }

      return !slotDateTime.isBefore(combinedDateTime);
    }).toList();
  }

  List<Slot> getDisabledSlots(List<Slot> slots) {
    // Get the current time
    DateTime now = DateTime.now();

    // Format the time in 12-hour format
    String formattedTime = DateFormat('hh:mm a').format(now);

    // Get the current date
    DateTime currentDate = DateTime.now();

    // Combine the current date and formatted time
    String combinedDateTimeString = DateFormat('yyyy-MM-dd').format(currentDate) + ' ' + formattedTime;

    // Parse the combined date and time string into a DateTime object
    DateTime combinedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(combinedDateTimeString);

    // Filter the slots based on visibility criteria
    List<Slot> disabledSlots = slots.where((slot) {
      DateTime slotDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('${slot.date} ${slot.date}');
      return !slotDateTime.isBefore(combinedDateTime) && slot.availableSlots <= 0;
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
    final url = Uri.parse(baseUrl + GetSlotsByDateAndBranch + "$formattedDate/$branchId");
    print('url==>969: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        final List<dynamic> slotData = jsonResult['listResult'];

        List<Slot> slots = slotData.map((slotJson) => Slot.fromJson(slotJson)).toList();

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
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 16.0, color: Colors.black),
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
    final pattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$';
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

  Future<Holiday> fetchHolidayListByBranchId() async {
    // final url = Uri.parse(
    //     'http://182.18.157.215/SaloonApp/API/GetHolidayListByBranchId/$branchId');
     final url = Uri.parse(baseUrl + getholidayslist);
   // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/HolidayList/GetHolidayListdetails');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{

          'id': widget.branchId,
          'isActive': true, // Add isActive filter
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




  Future<void> fetchData() async {
    final url = Uri.parse(baseUrl + getdropdown);
    final response = await http.get((url));
    // final url =  Uri.parse(baseUrl+GetHolidayListByBranchId+'$branchId');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dropdownItems = data['listResult'];
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
    List<Holiday> holidays = json.map((holidayJson) => Holiday.fromJson(holidayJson)).toList();
    return HolidayResponse(listResult: holidays);
  }
}
