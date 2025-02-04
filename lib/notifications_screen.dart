// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hairfixingzone/MyProductsProvider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hairfixingzone/Agentappointmentlist.dart';
import 'package:hairfixingzone/Appointment.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';

import 'AgentHome.dart';
import 'CommonUtils.dart';
import 'Notifications.dart';
import 'api_config.dart';

class notifications_screen extends StatefulWidget {
  int userId;
  String formattedDate;

  notifications_screen({super.key, required this.userId, required this.formattedDate});

  @override
  _notifications_screenState createState() => _notifications_screenState();
}

class _notifications_screenState extends State<notifications_screen> {
  final bool _isLoading = false;

  String notificationMsg = "Waiting for notifications";
  String firebaseToken = "";
  List<Notifications> appointments = [];

  // late Future<List<Notifications>> apiData;
  late Future<List<Notifications>?> apiData = Future.value(null);
  late MyProductProvider myProductProvider;
  bool isLoading = true;
  int? userId;

  @override
  void initState() {
    super.initState();
    sharedPref();
    print('User ID: ${widget.userId}');

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('Connected to the internet');

        initializeData();
      } else {
        CommonUtils.showCustomToastMessageLong('Please Check Your Internet Connection', context, 1, 4);
        print('Not connected to the internet');
      }
    });
  }

  void initializeData() {
    fetchAppointments(widget.userId, widget.formattedDate).then((value) {
      apiData = Future.value(value);
      myProductProvider.proNotify = value;
      setState(() {});
    }).catchError((error) {
      print('catchError: Error occurred.');
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myProductProvider = Provider.of<MyProductProvider>(context, listen: false);
  }

  Future<void> sharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Replace the current screen with AgentHome when the back button is pressed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AgentHome(userId: widget.userId),
            ),
          );
          // Returning false means we don't want the system to perform the default back navigation
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            // backgroundColor:  Color(0xFFf3e3ff),
            backgroundColor: const Color(0xffe2f0fd),
            title: Text(
              'Notifications Screen',
              style: TextStyle(color: Color(0xFF0f75bc), fontSize: 16.0, fontWeight: FontWeight.w600),
              textAlign: TextAlign.start,
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: CommonUtils.primaryTextColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgentHome(userId: widget.userId)),
                );
                //    Navigator.of(context).pop();
              },
            ),
          ),
          body: Consumer<MyProductProvider>(
            builder: (context, provider, _) => Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Notifications>?>(
                    future: apiData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'No Appointments Found!',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Outfit",
                            ),
                          ),
                        );
                      } else {
                        List<Notifications> data = provider.proNotify;
                        if (data.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    AgentOpCard(
                                      userId: userId,
                                      data: data[index],
                                      onRefresh: () {
                                        initializeData();
                                        // recall the api
                                      },
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                );
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
                                fontFamily: "Outfit",
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
        ));
  }

  Future<List<Notifications>> fetchAppointments(int userId, String? formattedDate) async {
    print('Agent userId173: $userId');
    final url = Uri.parse('$baseUrl$Getnotificatons$userId/null/null');
    //  final url = Uri.parse('$baseUrl$Getnotificatons$userId/null/$formattedDate');
    // Uri.parse(
    //     'http://182.18.157.215/SaloonApp/API/api/Appointment/GetNotificationsByUserId/8/null/2024-05-13');
    // Uri.parse('$baseUrl$Getnotificatons$userId/null/$formattedDate');
    print('notify: $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['listResult'] != null) {
          final List<dynamic> appointmentsData = responseData['listResult'];
          List<Notifications> result = appointmentsData.map((appointment) => Notifications.fromJson(appointment)).toList();
          return result;
        } else {
          myProductProvider.proNotify = [];
          throw Exception('List is empty');
        }
      } else {
        throw Exception('Failed to fetch appointments');
      }
    } catch (error) {
      print('catch: $error');
      rethrow;
    }
  }

// Future<void> Get_ApprovedDeclinedSlots(Notifications data, int i) async {
//   final url = Uri.parse(baseUrl + GetApprovedDeclinedSlots);
//   print('url==>55555: $url');
//
//   final request = {
//     "Id": data.id,
//     "StatusTypeId": 5,
//     "BranchName": data.name,
//     "Date": data.date,
//     "SlotTime": data.slotTime,
//     "CustomerName": data.customerName,
//     "PhoneNumber": data.phoneNumber,
//     "Email": data.email,
//     "Address": data.address,
//     "SlotDuration": data.slotDuration
//   };
//   print('Get_ApprovedSlotsmail: $request');
//   try {
//     // Send the POST request
//     final response = await http.post(
//       url,
//       body: json.encode(request),
//       headers: {
//         'Content-Type': 'application/json', // Set the content type header
//       },
//     );
//
//     // Check the response status code
//     if (response.statusCode == 204) {
//       print('Request sent successfully');
//     } else {
//       print(
//           'Failed to send the request. Status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }

// void  acceptAppointment(int index) {
//   setState(() {
//     appointments[index].isAccepted = true;
//   });
// }
//
// void rejectAppointment(int index) {
//   setState(() {
//     appointments[index].isRejected = true;
//   });
}

// Future<void> postAppointment(Notifications data, int i) async {
//   final url = Uri.parse(baseUrl + postApiAppointment);
//   print('url==>890: $url');
//   // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment');
//   DateTime now = DateTime.now();
//
//   // Using toString() method
//   String dateTimeString = now.toString();
//   print('DateTime as String: $dateTimeString');
//
//   // Create the request object
//   final request = {
//     "Id": data.id,
//     "BranchId": data.branchId,
//     "Date": data.date,
//     "SlotTime": data.slotTime,
//     "CustomerName": data.customerName,
//     "PhoneNumber": data.phoneNumber,
//     "Email": data.email,
//     "GenderTypeId": data.genderTypeId,
//     "StatusTypeId": i,
//     "PurposeOfVisitId": data.purposeOfVisitId,
//     "PurposeOfVisit": data.purposeOfVisit,
//     "IsActive": true,
//     "CreatedDate": dateTimeString,
//     "UpdatedDate": dateTimeString,
//     "UpdatedByUserId": widget.userId
//   };
//   print('Accept Or reject object: $request');
//   try {
//     // Send the POST request
//     final response = await http.post(
//       url,
//       body: json.encode(request),
//       headers: {
//         'Content-Type': 'application/json', // Set the content type header
//       },
//     );
//
//     // Check the response status code
//     if (response.statusCode == 200) {
//       print('Request sent successfully');
//
//       // showCustomToastMessageLong(
//       //     'Request sent successfully', context, 0, 2);
//       //    Navigator.pop(context);
//     } else {
//       //showCustomToastMessageLong(
//       // 'Failed to send the request', context, 1, 2);
//       print(
//           'Failed to send the request. Status code: ${response.statusCode}');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }
//
// bool isPastDate(String selectedDate, String time) {
//   final now = DateTime.now();
//   // DateTime currentTime = DateTime.now();
//   //  print('currentTime: $currentTime');
//   //   int hours = currentTime.hour;
//   //  print('current hours: $hours');
//   // Format the time using a specific pattern with AM/PM
//   String formattedTime = DateFormat('hh:mm a').format(now);
//
//   final selectedDateTime = DateTime.parse(selectedDate);
//   final currentDate = DateTime(now.year, now.month, now.day);
//
//   // Agent login chey
//
//   bool isBeforeTime = false; // Assume initial value as true
//   bool isBeforeDate = selectedDateTime.isBefore(currentDate);
//   // Parse the desired time for comparison
//   DateTime desiredTime = DateFormat('hh:mm a').parse(time);
//   // Parse the current time for comparison
//   DateTime currentTime = DateFormat('hh:mm a').parse(formattedTime);
//
//   if (selectedDateTime == currentDate) {
//     int comparison = currentTime.compareTo(desiredTime);
//     print('comparison$comparison');
//     // Print the comparison result
//     if (comparison < 0) {
//       isBeforeTime = false;
//       print('The current time is earlier than 10:15 AM.');
//     } else if (comparison > 0) {
//       isBeforeTime = true;
//     } else {
//       isBeforeTime = true;
//     }
//
//     //  isBeforeTime = hours >= time;
//   }
//
//   print('isBeforeTime: $isBeforeTime');
//   print('isBeforeDate: $isBeforeDate');
//   return isBeforeTime || isBeforeDate;
// }

// ignore: must_be_immutable
class AgentOpCard extends StatefulWidget {
  // final Appointment data;
  int? userId;

  // int? branchid;
  // String? branchaddress;
  final VoidCallback? onRefresh;
  final Notifications data;

  AgentOpCard({
    Key? key,
    this.onRefresh,
    this.userId,
    required this.data,
  }) : super(key: key);

  @override
  State<AgentOpCard> createState() => _AgentOpCardState();
}

class _AgentOpCardState extends State<AgentOpCard> {
  late List<dynamic> dateValues;
  final TextEditingController _commentstexteditcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateValues = parseDateString(widget.data.date);
  }

  @override
  void dispose() {
    _commentstexteditcontroller.dispose();
    super.dispose();
  }

  late Future<List<Notifications>?> apiData = Future.value(null);
  final GlobalKey _toolTipKey = GlobalKey();
  final GlobalKey _fullnameTipKey = GlobalKey();
  final GlobalKey _emailtoolTipKey = GlobalKey();
  late MyProductProvider myProductProvider;
  bool _isLoadingAccept = false;
  bool _isLoadingCancel = false;
  bool _isAcceptClicked = false;
  bool _isCancelClicked = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myProductProvider = Provider.of<MyProductProvider>(context, listen: false);
  }

  // void initializeData() {
  //   apiData = fetchAppointments(1, '');
  //   apiData.then((value) {
  //     myProductProvider.proNotify = value!;
  //   }).catchError((error) {
  //     print('catchError: Error occurred.');
  //   });
  // }

  List<dynamic> parseDateString(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    print('dateFormate: ${dateTime.day} - ${DateFormat.MMM().format(dateTime)} - ${dateTime.year}');
    //         int ,       String ,                           int
    return [dateTime.day, DateFormat.MMM().format(dateTime), dateTime.year];
  }


  // Future<List<Notifications>> fetchAppointments(
  //     int userId, String? formattedDate) async {
  //   final url = Uri.parse(
  //       'http://182.18.157.215/SaloonApp/API/api/Appointment/GetNotificationsByUserId/8/null/2024-05-13');
  //   // Uri.parse('$baseUrl$Getnotificatons$userId/null/$formattedDate');
  //   print('notify: $url');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> responseData = jsonDecode(response.body);
  //       if (responseData['listResult'] != null) {
  //         final List<dynamic> appointmentsData = responseData['listResult'];
  //         List<Notifications> result = appointmentsData
  //             .map((appointment) => Notifications.fromJson(appointment))
  //             .toList();
  //         return result;
  //       } else {
  //         throw Exception('List is empty');
  //       }
  //     } else {
  //       throw Exception('Failed to fetch appointments');
  //     }
  //   } catch (error) {
  //     print('catch: $error');
  //     rethrow;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // color: Colors.white,
              color: const Color(0xffe2f0fd),

              borderRadius: BorderRadius.circular(5.0),
              // boxShadow: [
              //   BoxShadow(
              //     color: const Color(0xFF960efd).withOpacity(0.2), //color of shadow
              //     spreadRadius: 2, //spread radius
              //     blurRadius: 4, // blur radius
              //     offset: const Offset(0, 2), // changes position of shadow
              //   ),
              // ],
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
                          fontSize: 22,
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
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 2.5),
                  child: const VerticalDivider(
                    color: CommonUtils.primaryTextColor,
                  ),
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
                                    Row(
                                      // crossAxisAlignment: CrossAxisAlignment.start,  // Aligns content to the top
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.data.customerName,
                                            style: CommonStyles.txSty_16b6_fb,
                                            softWrap: true,  // Allows text to wrap
                                            maxLines: null,  // No limit on the number of lines
                                          ),
                                        ),
                                        GestureDetector(
                                          key: _fullnameTipKey,
                                          child: const Padding(
                                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                            child: Icon(
                                              Icons.copy,
                                              size: 16,
                                            ),
                                          ),
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: widget.data.customerName));
                                            showTooltip(context, "Copied", _fullnameTipKey);
                                          },
                                        ),
                                      ],
                                    ),
                                    // if (widget.data.email.isNotEmpty) ...{
                                    //   Text(widget.data.email, style: CommonStyles.txSty_16black_f5),
                                    // } else ...{
                                    //   SizedBox.shrink()
                                    // },
                                    if (widget.data.email!.isNotEmpty) ...{
                                      Container(
                                        // width: MediaQuery.of(context).size.width / 3.5,
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
                                              padding: EdgeInsets.fromLTRB(2, 0, 5, 0),
                                              child: Icon(
                                                Icons.copy,
                                                size: 16,
                                              ),
                                            ),
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: widget.data.email!));
                                              showTooltip(context, "Copied", _emailtoolTipKey);
                                            },
                                          ),
                                        ]),
                                      ),
                                    } else ...{
                                      SizedBox.shrink()
                                    },
                                    Text(widget.data.purposeOfVisit, style: CommonStyles.txSty_14blu_f5),
                                   // Text(widget.data.purposeOfVisit, style: CommonStyles.txSty_16black_f5),
                                   // Text(widget.data.name, style: CommonStyles.txSty_16black_f5),
                                    Text(widget.data.name, style: CommonStyles.txSty_16b_fb),
                                    const SizedBox(
                                      height: 2.0,
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // statusBasedBgById(statusTypeId,
                                  //     status),
                                  const SizedBox(
                                    height: 2.0,
                                  ),

                                  // Text(widget.data.status,
                                  //     style: CommonStyles.txSty_16black_f5),

                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: CommonStyles.statusBlueBg,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.data.status,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: "Outfit",
                                            fontWeight: FontWeight.w500,
                                            color: CommonStyles.statusBlueText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 3.0,
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          makePhoneCall('tel:+91${widget.data.phoneNumber}');
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            text: widget.data.phoneNumber,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Outfit",
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0f75bc),
                                              decoration: TextDecoration.underline,
                                              decorationColor: Color(0xFF0f75bc), // Change this to your desired underline color
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
                                          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                          child: Icon(
                                            Icons.copy,
                                            size: 16,
                                          ),
                                        ),
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: widget.data.phoneNumber!));
                                          showTooltip(context, "Copied", _toolTipKey);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 3.0,
                                  ),
                                  Text('${widget.data.gender}  ', style: CommonStyles.txSty_16black_f5),

                                  //    Text(gender!, style: CommonStyles.txSty_16black_f5),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          acceptSlot(widget.data),
                          const SizedBox(
                            width: 10,
                          ),
                          cancelSlot(widget.data),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
  Future<void> makePhoneCall(String phoneNumber) async {
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _handleButtonPressCancel(Notifications data) async {



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

  Widget cancelSlot(Notifications data) {
    return GestureDetector(
      // onTap: () {
      //   if (!isPastDate(data.date, data.slotDuration)) {
      //     conformation(context, data);
      //     // Add your logic here for when the 'Cancel' container is tapped
      //   }
      // },
      onTap: () => _handleButtonPressCancel(data),
      child: IgnorePointer(
        ignoring: _isCancelClicked||isPastDate(data.date, data.slotDuration),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonStyles.statusRedText,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
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
                    color: CommonStyles.primaryTextColor, // You can customize color
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/calendar-xmark.svg',
                  width: 13,
                  color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonStyles.statusRedText,
                ),
              SizedBox(width: 4),
              Text(
                _isLoadingCancel ? 'Loading...' : 'Cancel', // Change text based on loading state
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Outfit",
                  fontWeight: FontWeight.w500,
                  color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonStyles.statusRedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    //   GestureDetector(
    //   onTap: () {
    //     conformation(context, data);
    //   },
    //   child: Container(
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(3),
    //       border: Border.all(
    //         color: CommonStyles.statusRedText,
    //       ),
    //     ),
    //     padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    //     child: Row(
    //       children: [
    //         SvgPicture.asset(
    //           'assets/calendar-xmark.svg',
    //           width: 12,
    //           color: CommonStyles.statusRedText,
    //         ),
    //         const Text(
    //           '  Cancel',
    //           style: TextStyle(
    //             fontSize: 16,
    //             fontFamily: "Outfit",
    //             fontWeight: FontWeight.w500,
    //             color: CommonStyles.statusRedText,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
  Future<void> _handleButtonPress(Notifications data, int? userId) async {

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

    await acceptAppointment(data, 5, 0, widget.userId);
    await Get_ApprovedDeclinedSlots(data, 5);
    print('accepted button is clicked');

    setState(() {
      _isAcceptClicked = false;
      _isLoadingAccept = false; // Hide loading indicator
    });
  }
  Widget acceptSlot(Notifications data) {
    return GestureDetector(
      // onTap: () {
      //   if (!isPastDate(data.date, data.slotDuration)) {
      //     print('Button 1 pressed for ${data.customerName}');
      //
      //     acceptAppointment(data, 5, 0, widget.userId);
      //     Get_ApprovedDeclinedSlots(data, 5);
      //     print('accpteedbuttonisclicked');
      //     // Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (context) => Rescheduleslotscreen(
      //     //       data: data,
      //     //     ),
      //     //   ),
      //     // );
      //   }
      // },
      onTap: () => _handleButtonPress(data, widget.userId),
      child: IgnorePointer(
        ignoring:_isAcceptClicked || isPastDate(data.date, data.slotDuration),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonStyles.primaryTextColor),
          ),
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          child: Row(
            children: [
              // SvgPicture.asset(
              //   'assets/calendar-_3_.svg',
              //   width: 13,
              //   color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonUtils.primaryTextColor,
              // ),
              // Text(
              //   '  Accept',
              //   style: TextStyle(
              //     fontSize: 15,
              //     color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonUtils.primaryTextColor,
              //   ),
              // ),
              if (_isLoadingAccept) // Show loading indicator if loading
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CommonStyles.primaryTextColor, // You can customize color
                  ),
                )
              else
                SvgPicture.asset(
                  'assets/calendar-_3_.svg',
                  width: 13,
                  color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonUtils.primaryTextColor,
                ),
              SizedBox(width: 4),
              Text(
                _isLoadingAccept ? 'Loading...' : 'Accept', // Change text based on loading state
                style: TextStyle(
                  fontSize: 15,
                  color: isPastDate(data.date, data.slotDuration) ? Colors.grey : CommonUtils.primaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    //   GestureDetector(
    //   onTap: () {
    //     acceptAppointment(data, 5, 0, widget.userId); //MARK: ?????????????
    //     Get_ApprovedDeclinedSlots(data, 5);
    //   },
    //   child: Container(
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(3),
    //       border: Border.all(
    //         color: CommonUtils.primaryTextColor,
    //       ),
    //     ),
    //     padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    //     child: Row(
    //       children: [
    //         SvgPicture.asset(
    //           'assets/calendar-_3_.svg',
    //           width: 13,
    //           color: CommonUtils.primaryTextColor,
    //         ),
    //         const Text(
    //           '  Accept',
    //           style: TextStyle(
    //             fontSize: 15,
    //             color: CommonUtils.primaryTextColor,
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  //MARK: Dialogs
  void conformation(BuildContext context, Notifications appointments) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text(
          //   'Confirmation',
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: CommonUtils.blueColor,
          //     fontFamily: 'Outfit',
          //   ),
          // ),
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
                  'Are You Sure You Want to Cancel the Appointment at  ${appointments.purposeOfVisit} Branch for ${appointments.name}?',
                  style: CommonUtils.txSty_18b_fb,
                  textAlign: TextAlign.center, // Optionally, align the text center
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

// status apis

  Future<void> cancelAppointment(Notifications appointmens) async {
    final url = Uri.parse(baseUrl + postApiAppointment);
    DateTime now = DateTime.now();
    String dateTimeString = now.toString();
    print('DateTime as String: $dateTimeString');
    print('cancel UpdatedByUserId  794 ${widget.userId}');
    final request = {
      "Id": appointmens.id,
      "BranchId": appointmens.branchId,
      "Date": appointmens.date,
      "SlotTime": appointmens.slotTime,
      "CustomerName": appointmens.customerName,
      "PhoneNumber": appointmens.phoneNumber,
      "Email": appointmens.email,
      "GenderTypeId": appointmens.genderTypeId,
      "StatusTypeId": 6,
      "PurposeOfVisitId": appointmens.purposeOfVisitId,
      "PurposeOfVisit": appointmens.purposeOfVisit,
      "IsActive": true,
      "CreatedDate": dateTimeString,
      "UpdatedDate": dateTimeString,
      "UpdatedByUserId": widget.userId,
      "rating": null,
      "review": null,
      "reviewSubmittedDate": null,
      "timeofslot": appointmens.timeOfSlot,
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
        } else {
          // Failure case
          // Handle failure scenario here
          CommonUtils.showCustomToastMessageLong('The Request Should Not be Cancelled Within 30 minutes Before the Slot', context, 0, 2);
        }
      } else {
        print('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while sending : $e');
    }
  }

  Future<void> acceptAppointment(Notifications data, int i, int Amount, int? userId) async {
    final url = Uri.parse(baseUrl + postApiAppointment);
    print('url==>890: $url');
    print('url==>userId: $userId');
    // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment');
    DateTime now = DateTime.now();

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
      "UpdatedByUserId": widget.userId,
      "timeofSlot": data.timeOfSlot,
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
          //  initializeData();
          openDialogaccept();
          // print('Request sent successfully');
          // if (i == 5) {
          //   initializeData();
          //   openDialogaccept();
          // } else if (i == 18) {
          //   openDialogclosed();
          // }
          // Success case
          // Handle success scenario here
        } else {
          // Failure case
          // Handle failure scenario here
          CommonUtils.showCustomToastMessageLong('Not Accepted Failed to Send The Request', context, 0, 2);
        }
      } else {
        //showCustomToastMessageLong(
        // 'Failed to send the request', context, 1, 2);
        print('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> Get_ApprovedDeclinedSlots(Notifications data, int i) async {
    final url = Uri.parse(baseUrl + GetApprovedDeclinedSlots);
    print('url==>55555: $url');

    final request = {
      "Id": data.branchId,
      "StatusTypeId": 5,
      "BranchName": data.name,
      "Date": data.date,
      "SlotTime": data.slotTime,
      "CustomerName": data.customerName,
      "PhoneNumber": data.phoneNumber,
      "Email": data.email,
      "Address": data.address,
      "SlotDuration": data.slotDuration,
      "branchId": data.branchId,
    };
    print('Get_ApprovedSlotsmail: $request');
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
      case 18: // Closed
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
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: statusBgColor),
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
      child: Row(
        children: [
          // statusBasedBgById(statusTypeId),
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
    }

    print('isBeforeTime: $isBeforeTime');
    print('isBeforeDate: $isBeforeDate');
    return isBeforeTime || isBeforeDate;
  }

  void closepopup(Appointment data, int i, int? userId) {
    TextEditingController priceController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Price '),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 345.0,
              height: 120.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      // CustomeFormField(
                      //   label: 'Email/User Name',
                      //   validator: validateEmail,
                      //   controller: _emailController,
                      // ),
                      const Row(
                        children: [
                          Text(
                            'Amount (Rs)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: priceController,
                        // Assigning the controller
                        keyboardType: TextInputType.number,
                        // obscureText: true,

                        maxLength: 50,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
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
                          hintText: 'Enter Amount in Rs',
                          counterText: "",
                          hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
                        ),
                        validator: validateAmount,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  int? price = int.tryParse(priceController.text);
                  // postAppointment(data, 18, price!, userId);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void openDialogreject() async {
    await showDialog(
      context: context,
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
                  textAlign: TextAlign.center, // Optionally, align the text center
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
    if (value == null || value.isEmpty) {
      return 'Please Enter Amount in Rs';
    }
    // else if (!RegExp(
    //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    //     .hasMatch(value)) {
    //   return 'Please enter a valid email address';
    // }
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
                  'Your Appointment Has Been Accepted Successfully.',
                  style: CommonUtils.txSty_18b_fb,
                  textAlign: TextAlign.center, // Optionally, align the text center
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
                  textAlign: TextAlign.center, // Optionally, align the text center
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
  void showTooltip(BuildContext context, String message, GlobalKey toolTipKey) {
    final renderBox = toolTipKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final target = renderBox.localToGlobal(renderBox.size.bottomLeft(Offset.zero), ancestor: overlay) + const Offset(-10, 0);

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
}

// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.dart';
// import 'CommonUtils.dart';
// import 'Notifications.dart';
// import 'api_config.dart';
//
// class notifications_screen extends StatefulWidget {
//   int userId;
//   String formattedDate;
//
//   notifications_screen({required this.userId, required this.formattedDate});
//   @override
//   _notifications_screenState createState() => _notifications_screenState();
// }
// class _notifications_screenState extends State<notifications_screen> {
//   bool _isLoading = false;
//
//
//   String notificationMsg = "Waiting for notifications";
//   String firebaseToken = "";
//   List<Notifications> appointments = [];
//   bool isLoading = true;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//
//     print('User ID: ${widget.userId}');
//
//     CommonUtils.checkInternetConnectivity().then((isConnected) {
//       if (isConnected) {
//         print('Connected to the internet');
//         fetchAppointments(widget.userId,widget.formattedDate);
//       } else {    CommonUtils.showCustomToastMessageLong('Please Check Your Internet Connection', context, 1, 4);
//       print('Not connected to the internet');  // Not connected to the internet
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Set this to false
//
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF44614),
//         centerTitle: true,
//         title: Container(
//           width: 85,
//           height: 50,
//           child: FractionallySizedBox(
//             widthFactor: 1,
//             child: Image.asset(
//               'assets/logo.png',
//               fit: BoxFit.fitHeight,
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/background.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//
//         padding: EdgeInsets.symmetric(horizontal: 20.0),
//         child: isLoading ? Center(
//           child: CircularProgressIndicator(),)
//             : appointments.isNotEmpty
//             ? ListView.builder(
//           shrinkWrap: true,
//           itemCount: appointments.length,
//           itemBuilder: (context, index) {
//             final appointment = appointments[index];
//             final isEvenItem = index % 2 == 0;
//             final boxDecoration = isEvenItem
//                 ? BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFFfee7e1),
//                     Color(0xFFd7defa),
//                   ],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(30.0),
//                   bottomLeft: Radius.circular(30.0),
//                 )
//             )
//                 : BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFFd7defa),
//                     Color(0xFFfee7e1),
//                   ],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(30.0),
//                   bottomLeft: Radius.circular(30.0),
//                 )
//             );
//
//             return GestureDetector(
//               onTap: () {
//                 print('CardView clicked!');
//               },
//               child: ClipRRect(
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(42.5),
//                   bottomLeft: Radius.circular(42.5),
//                 ),
//                 child: Card(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.only(
//                         topRight: Radius.circular(30.0),
//                         bottomLeft: Radius.circular(30.0),
//                       )
//                   ),
//                   child: Container(
//                     padding: EdgeInsets.only(bottom: 10, top: 5, left: 5, right: 10),
//                     decoration: boxDecoration,
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: ListTile(
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//
//                                 Padding(
//                                   padding: EdgeInsets.only(top:5.0,
//                                       bottom: 4.0),
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: 'Name : ',
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFFF44614),fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                         TextSpan(
//                                           text: appointment.customerName,
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFF042DE3),fontSize: 12,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//
//
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: 4.0),
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: 'Branch Name : ',
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFFF44614),fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                         TextSpan(
//                                           text: appointment.name,
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFF042DE3),fontSize: 12,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: 4.0),
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: 'Gender : ',
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFFF44614),fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                         TextSpan(
//                                           text: appointment.gender,
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFF042DE3),fontSize: 12,
//
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: 4.0),
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         TextSpan(
//                                           text: 'Purpose : ',
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFFF44614),fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                         TextSpan(
//                                           text: appointment.purposeOfVisit,
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFF042DE3),fontSize: 12,
//
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: 4.0),
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         WidgetSpan(
//                                           child: Icon(
//                                             Icons
//                                                 .email_outlined,
//                                             size: 16,
//                                             color: Color(
//                                                 0xFFF44614),
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: ' : ',
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFFF44614),
//                                               fontSize: 12,
//
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                         TextSpan(
//                                           text: appointment.email,
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFF042DE3),fontSize: 12,
//
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: 4.0),
//
//                                   child: RichText(
//                                     text: TextSpan(
//                                       children: [
//                                         WidgetSpan(
//                                           child: Icon(
//                                             Icons.lock_clock,
//                                             color: Color(
//                                                 0xFFF44614),
//                                             size: 16,
//                                           ),
//                                         ),
//                                         TextSpan(
//                                           text: ' : ',
//                                           style: TextStyle(
//                                               color: Color(
//                                                   0xFFF44614),
//                                               fontSize: 12,
//
//                                               fontWeight: FontWeight.bold,
//                                               fontFamily: 'Outfit'),
//                                         ),
//
//                                         TextSpan(
//
//                                           text: DateFormat('dd-MM-yyyy').format(DateTime.parse(appointment.date)),
//                                           //  text: appointment.date,
//                                           style: TextStyle(
//                                               color: Color(
//                                                 0xFF042DE3,
//                                               ),
//                                               fontSize: 12,
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                         TextSpan(
//                                           text: " "+ appointment.slotDuration,
//                                           style: TextStyle(
//                                               color: Color(
//                                                 0xFF042DE3,
//                                               ),
//                                               fontSize: 12,
//
//                                               fontFamily: 'Outfit'),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.only(
//                                   bottom: 5.0,left: 5.0,right: 5.0,top: 5.0),
//                               child:GestureDetector(
//                                 onTap: () {
//                                   String phoneNumber = appointment.phoneNumber;
//                                   launch("tel:$phoneNumber");
//                                 },
//                                 child: RichText(
//                                   text: TextSpan(
//                                     children: [
//                                       WidgetSpan(
//                                         child: Padding(
//                                           padding: EdgeInsets.only(left: 8.0, top: 2.0), // Add desired left and top padding
//                                           child: Icon(
//                                             Icons.phone,
//                                             color: Color(0xFFF44614),
//                                             size: 16,
//                                           ),
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: ': ',
//                                         style: TextStyle(
//                                           color: Color(0xFFF44614),
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: 'Outfit',
//                                         ),
//                                       ),
//                                       TextSpan(
//                                         text: appointment.phoneNumber,
//                                         style: TextStyle(
//                                           color: Color(0xFF042DE3),
//                                           fontFamily: 'Outfit',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             if (appointment.statusTypeId == 5)
//                               Visibility(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.only(top: 10.0),
//                                       child: Container(
//                                         width: 75,
//                                         height: 75,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: Colors.green,
//                                             width: 2.0,
//                                           ),
//                                           color: Colors.white,
//                                         ),
//                                         child: Stack(
//                                           alignment: Alignment.center,
//                                           children: [
//                                             Positioned(
//                                               top: 12,
//                                               child: Icon(
//                                                 Icons.check,
//                                                 color: Colors.green ,
//                                                 size: 33,
//                                               ),
//                                             ),
//                                             Positioned(
//                                               bottom: 15,
//                                               child: Text(
//                                                 'Accepted',
//                                                 style: TextStyle(
//                                                     color: Colors.green ,
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontFamily: 'Outfit'
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             if (appointment.statusTypeId == 6)
//                               Visibility(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.only(top: 10.0),
//                                       child: Container(
//                                         width: 75,
//                                         height: 75,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color:  Colors.red,
//                                             width: 2.0,
//                                           ),
//                                           color: Colors.white,
//                                         ),
//                                         child: Stack(
//                                           alignment: Alignment.center,
//                                           children: [
//                                             Positioned(
//                                               top: 12,
//                                               child: Icon(
//                                                 Icons.close,
//                                                 color:Colors.red,
//                                                 size: 33,
//                                               ),
//                                             ),
//                                             Positioned(
//                                               bottom: 15,
//                                               child: Text(
//                                                 'Rejected',
//                                                 style: TextStyle(
//                                                     color:  Colors.red,
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.bold,
//                                                     fontFamily: 'Outfit'
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//
//                             if (!appointment.isAccepted) SizedBox(height: 8),
//                             if (!appointment.isRejected)
//                               if(!appointment.isAccepted)
//                                 if (appointment.statusTypeId == 4)
//
//                                   if (!appointment.isAccepted)
//                                     ElevatedButton(
//                                       //  onPressed: () {
//                                       onPressed: isPastDate(widget.formattedDate, appointment.slotDuration) ? null : () {
//
//                                         acceptAppointment(index);
//
//                                         Notifications data = Notifications(
//                                           id: appointment.id,
//                                           branchId: appointment.branchId,
//                                           name: appointment.name,
//                                           date: appointment.date,
//                                           slotTime: appointment.slotTime,
//                                           customerName: appointment.customerName,
//                                           phoneNumber: appointment.phoneNumber,
//                                           email: appointment.email,
//                                           genderTypeId: appointment.genderTypeId,
//                                           gender: appointment.gender,
//                                           statusTypeId: appointment.statusTypeId,
//                                           status: appointment.status,
//                                           purposeOfVisit: appointment.purposeOfVisit,
//                                           purposeOfVisitId : appointment.purposeOfVisitId,
//                                           isActive: appointment.isActive,
//                                           slotDuration: appointment.slotDuration, address: appointment.address,
//                                         );
//
//                                         print('Button 1 pressed for ${appointment.customerName}');
//                                         postAppointment(data, 5);
//                                         Get_ApprovedDeclinedSlots(data, 5);
//                                         print('accpteedbuttonisclicked');
//                                       },
//                                       child: Text('Accept'),
//                                       style: ButtonStyle(
//                                         foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                                               (Set<MaterialState> states) {
//                                             if (states.contains(MaterialState.disabled)) {
//                                               return Colors.grey; // Set the text color to gray when disabled
//                                             }
//                                             return Colors.green; // Use the default text color for enabled state
//                                           },
//                                         ),
//                                         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//                                               (Set<MaterialState> states) {
//                                             if (states.contains(MaterialState.disabled)) {
//                                               return Colors.grey.withOpacity(0.5); // Set the background color to gray with opacity when disabled
//                                             }
//                                             return Colors.white; // Use the default background color for enabled state
//                                           },
//                                         ),
//                                         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                           RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(25.0),
//                                             side: BorderSide(color: Colors.green, width: 2.0),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                             // ElevatedButton(
//                             //   onPressed: () { acceptAppointment(index);
//                             //
//                             //   Appointment data = Appointment(id: appointment.id, branchId: appointment.branchId, name: appointment.name
//                             //       , date: appointment.date, slotTime: appointment.slotTime, customerName: appointment.customerName, phoneNumber: appointment.phoneNumber, email: appointment.email,
//                             //       genderTypeId: appointment.genderTypeId, gender: appointment.gender, statusTypeId: appointment.statusTypeId, status: appointment.status, comment: appointment.comment, isActive: appointment.isActive, SlotDuration: '');
//                             //   print('Button 1 pressed for ${appointment.customerName}');
//                             //   postAppointment(data,5);
//                             //   print('accpteedbuttonisclicked');},
//                             //   child: Text('Accept'),
//                             //   style: TextButton.styleFrom(
//                             //     primary: Colors.green,
//                             //     backgroundColor: Colors.white,
//                             //     shape: RoundedRectangleBorder(
//                             //       borderRadius: BorderRadius.circular(25.0),
//                             //       side: BorderSide(color: Colors.green, width: 2.0),
//                             //     ),
//                             //   ),
//                             // ),
//
//                             if (!appointment.isRejected) SizedBox(height: 2),
//                             if (!appointment.isAccepted)
//                               if(!appointment.isRejected)
//                                 if (appointment.statusTypeId == 4)
//                                   ElevatedButton(
//                                     //  onPressed: () {
//                                     onPressed: isPastDate(widget.formattedDate,appointment.slotDuration  ) ? null : () {
//                                       // Handle reject button action
//                                       rejectAppointment(index);
//
//                                       Notifications data = Notifications(
//                                         id: appointment.id,
//                                         branchId: appointment.branchId,
//                                         name: appointment.name,
//                                         date: appointment.date,
//                                         slotTime: appointment.slotTime,
//                                         customerName: appointment.customerName,
//                                         phoneNumber: appointment.phoneNumber,
//                                         email: appointment.email,
//                                         genderTypeId: appointment.genderTypeId,
//                                         gender: appointment.gender,
//                                         statusTypeId: appointment.statusTypeId,
//                                         status: appointment.status,
//                                         purposeOfVisit: appointment.purposeOfVisit,
//                                         purposeOfVisitId : appointment.purposeOfVisitId,
//                                         isActive: appointment.isActive,
//                                         slotDuration: appointment.slotDuration, address: appointment.address,
//                                       );
//
//                                       print('Button 1 pressed for ${appointment.customerName}');
//                                       postAppointment(data, 6);
//                                       print('rejectedbuttonisclciked');
//                                     },
//                                     child: Text('Reject'),
//                                     style: ButtonStyle(
//                                       foregroundColor: MaterialStateProperty.resolveWith<Color>(
//                                             (Set<MaterialState> states) {
//                                           if (states.contains(MaterialState.disabled)) {
//                                             return Colors.grey; // Set the text color to gray when disabled
//                                           }
//                                           return Color(0xFFF44614); // Use the default text color for enabled state
//                                         },
//                                       ),
//                                       backgroundColor: MaterialStateProperty.resolveWith<Color>(
//                                             (Set<MaterialState> states) {
//                                           if (states.contains(MaterialState.disabled)) {
//                                             return Colors.grey.withOpacity(0.5); // Set the background color to gray with opacity when disabled
//                                           }
//                                           return Colors.white; // Use the default background color for enabled state
//                                         },
//                                       ),
//                                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                         RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(25.0),
//                                           side: BorderSide(color: Color(0xFFF44614), width: 2.0),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//
//
//                             if (appointment.isAccepted || appointment.isRejected )
//                               Visibility(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: EdgeInsets.only(top: 10.0),
//                                       child: Container(
//                                         width: 75,
//                                         height: 75,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: appointment.isAccepted ? Colors.green : Colors.red,
//                                             width: 2.0,
//                                           ),
//                                           color: Colors.white,
//                                         ),
//                                         child: Stack(
//                                           alignment: Alignment.center,
//                                           children: [
//                                             Positioned(
//                                               top: 12,
//                                               child: Icon(
//                                                 appointment.isAccepted ? Icons.check : Icons.close,
//                                                 color: appointment.isAccepted ? Colors.green : Colors.red,
//                                                 size: 33,
//                                               ),
//                                             ),
//                                             Positioned(
//                                               bottom: 15,
//                                               child: Text(
//                                                 appointment.isAccepted ? 'Accepted' : 'Rejected',
//                                                 style: TextStyle(
//                                                   color: appointment.isAccepted ? Colors.green : Colors.red,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontFamily: 'Outfit',
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               )
//
//
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         )
//             : Center(
//           child: Text(
//             'No Slots Available',
//             style: TextStyle(
//               fontSize: 18,
//               color: Color(0xFFFB4110),
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Outfit',
//             ),
//           ),
//         ),
//
//       ),
//     );
//   }
//
//   void fetchAppointments(int userId, String? formattedDate) async {
//
//     appointments.clear();
//     final url =  Uri.parse(baseUrl+Getnotificatons+'$userId/null/$formattedDate');
//     print('url==842===$url');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         if (responseData['listResult'] != null) {
//           final List<dynamic> appointmentsData = responseData['listResult'];
//           setState(() {
//             appointments = appointmentsData
//                 .map((appointment) => Notifications.fromJson(appointment))
//                 .toList();
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           //  textFieldController.text = 'No Slots Available';
//           print('No Slots Available');
//         }
//       } else {
//         throw Exception('Failed to fetch appointments');
//       }
//     } catch (error) {
//       throw Exception('Failed to connect to the API');
//     }
//   }
//
//   Future<void> Get_ApprovedDeclinedSlots(Notifications data, int i) async {
//     final url =  Uri.parse(baseUrl+GetApprovedDeclinedSlots);
//     print('url==>55555: $url');
//
//     final request = {
//
//       "Id": data.id,
//       "StatusTypeId": 5,
//       "BranchName":data.name,
//       "Date": data.date,
//       "SlotTime": data.slotTime,
//       "CustomerName": data.customerName,
//       "PhoneNumber": data.phoneNumber,
//       "Email":data.email,
//       "Address": data.address,
//       "SlotDuration": data.slotDuration
//
//     };
//     print('Get_ApprovedSlotsmail: $request');
//     try {
//       // Send the POST request
//       final response = await http.post(
//         url,
//         body: json.encode(request),
//         headers: {
//           'Content-Type': 'application/json', // Set the content type header
//         },
//       );
//
//       // Check the response status code
//       if (response.statusCode == 204) {
//         print('Request sent successfully');
//
//       } else {
//
//         print('Failed to send the request. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   void acceptAppointment(int index) {
//     setState(() {
//       appointments[index].isAccepted = true;
//     });
//   }
//
//   void rejectAppointment(int index) {
//     setState(() {
//       appointments[index].isRejected = true;
//     });
//   }
//
//
//   Future<void> postAppointment(Notifications data, int i) async {
//     final url =  Uri.parse(baseUrl+postApiAppointment);
//     print('url==>890: $url');
//     // final url = Uri.parse('http://182.18.157.215/SaloonApp/API/api/Appointment');
//     DateTime now = DateTime.now();
//
//     // Using toString() method
//     String dateTimeString = now.toString();
//     print('DateTime as String: $dateTimeString');
//
//     // Create the request object
//     final request = {
//
//       "Id": data.id,
//       "BranchId": data.branchId,
//       "Date": data.date,
//       "SlotTime": data.slotTime,
//       "CustomerName":data.customerName,
//       "PhoneNumber": data.phoneNumber,
//       "Email": data.email,
//       "GenderTypeId": data.genderTypeId,
//       "StatusTypeId": i,
//       "PurposeOfVisitId": data.purposeOfVisitId,
//       "PurposeOfVisit": data.purposeOfVisit,
//       "IsActive": true,
//       "CreatedDate": dateTimeString,
//       "UpdatedDate": dateTimeString,
//       "UpdatedByUserId": widget.userId
//     };
//     print('Accept Or reject object: $request');
//     try {
//       // Send the POST request
//       final response = await http.post(
//         url,
//         body: json.encode(request),
//         headers: {
//           'Content-Type': 'application/json', // Set the content type header
//         },
//       );
//
//       // Check the response status code
//       if (response.statusCode == 200) {
//         print('Request sent successfully');
//
//         // showCustomToastMessageLong(
//         //     'Request sent successfully', context, 0, 2);
//         //    Navigator.pop(context);
//       } else {
//         //showCustomToastMessageLong(
//         // 'Failed to send the request', context, 1, 2);
//         print('Failed to send the request. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//
//
//   bool isPastDate(String selectedDate, String time) {
//     final now = DateTime.now();
//     // DateTime currentTime = DateTime.now();
//     //  print('currentTime: $currentTime');
//     //   int hours = currentTime.hour;
//     //  print('current hours: $hours');
//     // Format the time using a specific pattern with AM/PM
//     String formattedTime = DateFormat('hh:mm a').format(now);
//
//     final selectedDateTime = DateTime.parse(selectedDate);
//     final currentDate = DateTime(now.year, now.month, now.day);
//
//
//     // Agent login chey
//
//     bool isBeforeTime = false; // Assume initial value as true
//     bool isBeforeDate = selectedDateTime.isBefore(currentDate);
//     // Parse the desired time for comparison
//     DateTime desiredTime = DateFormat('hh:mm a').parse(time);
//     // Parse the current time for comparison
//     DateTime currentTime = DateFormat('hh:mm a').parse(formattedTime);
//
//     if (selectedDateTime == currentDate) {
//       int comparison = currentTime.compareTo(desiredTime);
//       print('comparison$comparison');
//       // Print the comparison result
//       if (comparison < 0) {
//         isBeforeTime = false;
//         print('The current time is earlier than 10:15 AM.');
//       } else if (comparison > 0) {
//         isBeforeTime = true;
//       } else {
//         isBeforeTime = true;
//       }
//
//       //  isBeforeTime = hours >= time;
//     }
//
//     print('isBeforeTime: $isBeforeTime');
//     print('isBeforeDate: $isBeforeDate');
//     return isBeforeTime || isBeforeDate;
//   }
// }
//
//
