import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/inventory_screen.dart';
import 'package:hairfixingzone/screens/customer_enquiry/add_customer_enquiry.dart';
import 'package:hairfixingzone/screens/customer_enquiry/customer_enquiries.dart';
import 'package:hairfixingzone/test_agent_oplist.dart';
import 'package:hairfixingzone/test_screen.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'Agentappointmentlist.dart';
import 'BranchModel.dart';
import 'Common/common_styles.dart';
import 'CommonUtils.dart';

import 'api_config.dart';
// import 'consultation_creation_screen.dart';
// import 'consultation_creation_screen.dart';

class Branches_screen extends StatefulWidget {
  final int userId;
  final String? isBranchFrom;

  const Branches_screen({super.key, required this.userId, this.isBranchFrom});

  @override
  _BranchesscreenState createState() => _BranchesscreenState();
}

class _BranchesscreenState extends State<Branches_screen> {
  List<BranchModel> brancheslist = [];
  bool _isLoading = false;

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
// Print the userId
    print('User ID: ${widget.userId}');

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('Connected to the internet');
        // _getBranchData(widget.userId);
        fetchData();
      } else {
        CommonUtils.showCustomToastMessageLong(
            'Please Check Your Internet Connection', context, 1, 4);
        print('Not connected to the internet'); // Not connected to the internet
      }
    });
  }

  void retryDataFetching() {
    // setState(() {
    //   isLoading = true; // Set isLoading to true to show loading indicator
    // });
    // _getData(); // Call your API method to fetch data
    // fetchImages(); // Call your API method to fetch images
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        fetchData();
        print('Connected to the internet');
        // _getBranchData(widget.userId);
      } else {
        CommonUtils.showCustomToastMessageLong(
            'No Internet Connection', context, 1, 4);
        print('Not connected to the internet'); // Not connected to the internet
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final desiredWidth = screenWidth;

    return Scaffold(
        appBar: widget.isBranchFrom == 'CustomerEnquiry'
            ? AppBar(
                backgroundColor: const Color(0xffffffff),
                automaticallyImplyLeading: false,
                title: const Text(
                  'Branch Selection',
                  style: CommonStyles.txSty_20b_fb,
                ),
              )
            : null,
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: brancheslist.length,
                itemBuilder: (context, index) {
                  BranchModel branchnames = brancheslist[index];
                  String? imageUrl = branchnames.imageName;
                  if (imageUrl == null || imageUrl.isEmpty) {
                    imageUrl = 'assets/top_image.png';
                  }
                  return BranchTemplate(
                      branchnames: branchnames,
                      imageUrl: imageUrl,
                      userId: widget.userId,
                      isBranchFrom: widget.isBranchFrom);
                },
              )

                  //   ListView.builder(
                  //     itemCount: brancheslist.length,
                  //     // shrinkWrap: true,
                  //     // physics: const PageScrollPhysics(),
                  //     itemBuilder: (context, index) {
                  //       BranchModel branchnames = brancheslist[index];
                  //       String? imageUrl = branchnames.imageName;
                  //       if (imageUrl == null || imageUrl.isEmpty) {
                  //         imageUrl = 'assets/top_image.png';
                  //       }
                  //       return BranchTemplate(
                  //           branchnames: branchnames, imageUrl: imageUrl, userId: widget.userId);
                  //     },
                  //   ),
                  // ),
                  ),
            ],
          ),
        ));
  }

  void _handleButtonPress() {
    setState(() {
      _isLoading = true;
    });

    // Perform your operations here

    // After the operations are completed, update the state to hide the progress indicator
    setState(() {
      _isLoading = false;
    });
  }

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });

    // Add a timeout of 8 seconds using Future.delayed
    Future.delayed(const Duration(seconds: 15), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          brancheslist.clear(); // Clear the list if timeout occurs
        });
      }
    });

    await _getBranchData(widget.userId); // Call your API method
  }

  Future<void> _getBranchData(int userId) async {
    setState(() {
      _isLoading = true; // Set isLoading to true before making the API call
    });

    String apiUrl = '$baseUrl$GetBranchByUserId$userId/null';
    const maxRetries = 1; // Set maximum number of retries
    int retries = 0;

    while (retries < maxRetries) {
      try {
        // Make the HTTP GET request with a timeout of 30 seconds
        final response = await http.get(Uri.parse(apiUrl));
        print('apiUrl: $apiUrl');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          List<BranchModel> branchList = [];
          for (var item in data['listResult']) {
            branchList.add(BranchModel(
                id: item['id'],
                name: item['name'],
                imageName: item['imageName'],
                address: item['address'],
                startTime: item['startTime'],
                closeTime: item['closeTime'],
                room: item['room'],
                mobileNumber: item['mobileNumber'],
                isActive: item['isActive'],
                locationUrl: item['LocationUrl']));
          }

          setState(() {
            brancheslist = branchList;
            _isLoading = false;
          });
          return; // Exit the function after successful response
        } else {
          print('Request failed with status: ${response.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }
    retries++;
    await Future.delayed(Duration(seconds: 2 * retries)); // Exponential backoff
  }

// Handle the case where all retries failed
// print('All retries failed. Unable to fetch data from the API.');
//  setState(() {
//    _isLoading = false;
//  });
}

class BranchTemplate extends StatelessWidget {
  final BranchModel branchnames;
  final String imageUrl;
  final int userId;
  final String? isBranchFrom;
  const BranchTemplate(
      {super.key,
      required this.branchnames,
      required this.imageUrl,
      required this.userId,
      this.isBranchFrom});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
          onTap: () {
            if (isBranchFrom == 'inventory') {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => InventoryScreen(
                        branchId: branchnames.id!,
                        userId: userId,
                        branchName: branchnames.name,
                        branchImage: imageUrl,
                        branchNumber: branchnames.mobileNumber,
                        branchAddress: branchnames.address)),
              );
            } else if (isBranchFrom == 'CustomerEnquiry') {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => CustomerEnquiries(
                          branchId: branchnames.id,
                          userId: userId,
                          agentBranch: branchnames,
                        )),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TestAgentOplist(
                    branchId: branchnames.id!,
                    userId: userId,
                  ),
                  /* Agentappointmentlist(
                    userId: userId,
                    branchid: branchnames.id!,
                    branchname: branchnames.name,
                    filepath: branchnames.imageName != null
                        ? branchnames.imageName!
                        : 'assets/top_image.png',
                    phonenumber: branchnames.mobileNumber,
                    branchaddress: branchnames.address,
                  ), */
                ),
              );
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 10,
            width: MediaQuery.of(context).size.width,
            // decoration: BoxDecoration(
            //   border: Border.all(color: Color(0xFF662e91), width: 1.0),
            //   borderRadius: BorderRadius.circular(10.0),
            // ),
            decoration: BoxDecoration(
              color: Color(0xFFdbeaff),
              borderRadius: BorderRadius.circular(10.0),
              // borderRadius: BorderRadius.circular(30), //border corner radius
              // boxShadow: [
              //   BoxShadow(
              //     color: Color(0xFF11528f).withOpacity(0.2), //color of shadow
              //     spreadRadius: 2, //spread radius
              //     blurRadius: 4, // blur radius
              //     offset: Offset(0, 2), // changes position of shadow
              //   ),
              // ],
            ),
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 6,
                  margin: EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13.0),
                    child: Image.network(
                      imageUrl.isNotEmpty
                          ? imageUrl
                          : 'https://example.com/placeholder-image.jpg',
                      width: 65,
                      height: 60,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return Center(
                            child: CircularProgressIndicator.adaptive());
                      },
                    ),
                  ),
                  //  width: 65,
                  height: 60,
                ),
                // width: MediaQuery.of(context).size.width / 4,

                Container(
                  // height: MediaQuery.of(context).size.height / 4 / 2,

                  width: MediaQuery.of(context).size.width / 1.5,
                  padding: EdgeInsets.only(top: 7),
                  // width: MediaQuery.of(context).size.width / 4,
                  child: Column(
                    //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${branchnames.name}',
                        style: CommonUtils.txSty_18b_fb,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('${branchnames.address}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: CommonStyles.txSty_12b_f5),
                    ],
                  ),
                )
              ],
            ),
          )
          // Container(
          //   height: MediaQuery.of(context).size.height / 8,
          //   width: MediaQuery.of(context).size.width,
          //   // decoration: BoxDecoration(
          //   //   border: Border.all(color: Color(0xFF662e91), width: 1.0),
          //   //   borderRadius: BorderRadius.circular(10.0),
          //   // ),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(10.0),
          //     // borderRadius: BorderRadius.circular(30), //border corner radius
          //     boxShadow: [
          //       BoxShadow(
          //         color:
          //         const Color(0xFF960efd).withOpacity(0.2), //color of shadow
          //         spreadRadius: 2, //spread radius
          //         blurRadius: 4, // blur radius
          //         offset: const Offset(0, 2), // changes position of shadow
          //       ),
          //     ],
          //   ),
          //   child: Row(
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.only(left: 15.0, top: 0.0),
          //         child: SizedBox(
          //           width: MediaQuery.of(context).size.width / 3,
          //           height: 65,
          //           // decoration: BoxDecoration(
          //           //   borderRadius: BorderRadius.circular(10.0),
          //           //   border: Border.all(
          //           //     color: Color(0xFF9FA1EE),
          //           //     width: 3.0,
          //           //   ),
          //           // ),
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(8.0),
          //             child: Image.network(
          //               imageUrl.isNotEmpty
          //                   ? imageUrl
          //                   : 'https://example.com/placeholder-image.jpg',
          //               fit: BoxFit.cover,
          //               height: MediaQuery.of(context).size.height / 4 / 2,
          //               width: MediaQuery.of(context).size.width / 3.2,
          //               errorBuilder: (context, error, stackTrace) {
          //                 return Image.asset(
          //                   'assets/hairfixing_logo.png', // Path to your PNG placeholder image
          //                   fit: BoxFit.cover,
          //                   height: MediaQuery.of(context).size.height / 4 / 2,
          //                   width: MediaQuery.of(context).size.width / 3.2,
          //                 );
          //               },
          //             ),
          //           ),
          //         ),
          //       ),
          //       const SizedBox(
          //         width: 5,
          //       ),
          //       Padding(
          //           padding: const EdgeInsets.only(left: 5.0, top: 10.0),
          //           child: SizedBox(
          //             width: MediaQuery.of(context).size.width / 2.5,
          //             //    padding: EdgeInsets.only(top: 7),
          //             // width: MediaQuery.of(context).size.width / 4,
          //             child: Column(
          //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   branchnames.name,
          //                   style: const TextStyle(
          //                     color: Color(0xFF0f75bc),
          //                     fontSize: 14.0,
          //                     fontWeight: FontWeight.w600,
          //                   ),
          //                 ),
          //                 const SizedBox(
          //                   height: 5,
          //                 ),
          //                 Text(
          //                   branchnames.address,
          //                   style: const TextStyle(
          //                       color: Colors.black,
          //                       fontSize: 12.0,
          //                       fontWeight: FontWeight.w600),
          //                   maxLines: 3,
          //                   overflow: TextOverflow.ellipsis,
          //                 ),
          //               ],
          //             ),
          //           ))
          //     ],
          //   ),
          // ),
          ),
    );
  }
}
