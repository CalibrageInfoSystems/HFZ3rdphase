import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Consultation.dart';
import 'package:hairfixingzone/Dashboard_Screen.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'AddConsulationscreen.dart';

import 'AgentBranchModel.dart';
import 'Branches_screen.dart';
import 'api_config.dart';

class AgentDashBoard extends StatefulWidget {
  final int agentid;
  const AgentDashBoard({super.key, required this.agentid});

  @override
  State<AgentDashBoard> createState() => _AgentDashBoardState();
}

class _AgentDashBoardState extends State<AgentDashBoard> {
  List<Item> _items = [];
  late Timer _timer;
  String? marqueeText;
  final int _currentPage = 0;
  late Future<List<AgentBranchModel>> apiData;
  String userFullName = '';
  String email = '';
  String phonenumber = '';
  int? AgentId;
//  String gender ='';
  String Gender = '';
  final bool _shouldStartMarquee =
      true; // Variable to control Marquee scrolling

  @override
  void initState() {
    super.initState();

    checkLoginAgentdata();
    _fetchItems();
    apiData = getBranches(widget.agentid);
    // apiData = getAgentBranches(widget.agentId);
  }

  void checkLoginAgentdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userFullName = prefs.getString('userFullName') ?? '';
      email = prefs.getString('email') ?? '';
      phonenumber = prefs.getString('contactNumber') ?? '';
      Gender = prefs.getString('gender') ?? '';
      AgentId = prefs.getInt('userId');
      // _fullnameController1.text = userFullName;
      // _emailController3.text = email;
      // _phonenumberController2.text = phonenumber;
      // gender = selectedGender;
      print('AgentId:$AgentId');
      print('userFullName:$userFullName');
      print('gender:$Gender');
      // if (gender == 1) {
      //   Gender = 'Female';
      // } else if (gender == 2) {
      //   Gender = 'Male';
      // } else if (gender == 3) {
      //   Gender = 'Other';
      // }
    });
  }

  void _fetchItems() async {
    final response = await http.get(Uri.parse(baseUrl + getbanner));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (data['listResult'] != null &&
            (data['listResult'] as List).isNotEmpty) {
          _items = (data['listResult'] as List)
              .map((item) => Item.fromJson(item))
              .toList();
        } else {
          _items = []; // Set to an empty list if listResult is null or empty
        }
      });
    } else {
      setState(() {
        _items = []; // Set to an empty list in case of a failed request
      });
    }
  }

  //
  // void _fetchItems() async {
  //   final response = await http.get(Uri.parse(baseUrl + getbanner));
  //
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _items = (json.decode(response.body)['listResult'] as List)
  //           .map((item) => Item.fromJson(item))
  //           .toList();
  //     });
  //   } else {
  //     _items =[];
  //    // throw Exception('Failed to load items');
  //   }
  // }

  Future<List<Consultation>?> getAgentBranches(int agentId) async {
    final apiUrl = Uri.parse(
        baseUrl + getconsulationbranchesbyagentid + agentId.toString());
    try {
      final response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['listResult'] != null) {
          final List<dynamic> appointmentsData = responseData['listResult'];
          return appointmentsData
              .map((appointment) => Consultation.fromJson(appointment))
              .toList();
        } else {
          print('No data found');
          return null;
        }
      } else {
        print(
            'Failed to fetch appointments. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to fetch appointments. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to connect to the API: $error');
      throw Exception('Failed to connect to the API: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CommonStyles.whiteColor,
        body: SingleChildScrollView(
            child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              wishSection(context),
              //MARK: Carousel view
              carousel(context),
              const SizedBox(height: 10),
              //MARK: Marquee Text
              //marqueeScroll(),

              //MARK: Branches
              // const SizedBox(
              //   height: 15,
              // ),
              //     screens(),
              //  const SizedBox(
              //    height: 0,
              //  ),
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       'Branches',
              //       style: CommonStyles.txSty_20p_fb,
              //     ),
              //   ],
              // ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Branches",
                    style: CommonStyles.txSty_20b_fb,
                  ),
                ),
              ),
              agentBranches()
              // newBranches()
            ],
          ),
        )));
  }

  Padding wishSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Hello, ',
                // style: CommonStyles.txSty_20b_fb.copyWith(fontSize: 24),
                style: CommonStyles.txSty_20b_fb,
              ),
              Text(
                userFullName,
                style: CommonStyles.txSty_20b_fb
                    .copyWith(color: Color(0xFF11528f)),
                //  style: CommonStyles.txSty_20b_fb.copyWith(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          // Text(
          //   'Welcome to Hair Fixing Zone',
          //   style: TextStyle(
          //     fontSize: MediaQuery.of(context).size.width * 0.05,
          //     fontFamily: "Outfit",
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black,
          //   ),
          // ),
          Row(
            children: [
              Text(
                'Welcome to ',
                //    style: CommonStyles.txSty_20b_fb.copyWith(fontSize: 22),Hair Fixing Zone
                style: CommonStyles.txSty_16b_fb,
              ),
              Text(
                'HAIR FIXING ZONE',
                style: CommonStyles.txSty_16p_fb,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget newBranches() {
    return FutureBuilder(
      future: apiData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Center(
            child:
                Text(snapshot.error.toString().replaceAll('Exception: ', '')),
          );
        } else {
          List<AgentBranchModel>? data = snapshot.data!;
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height / 3.5,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                AgentBranchModel branch = data[index];
                return IntrinsicHeight(
                  child: GestureDetector(
                    onTap: () {
                      // print('branchid${branch.id}');
                    },
                    child: Card(
                      shadowColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      child: ClipRRect(
                        // borderRadius: const BorderRadius.only(
                        //   topRight: Radius.circular(29.0),
                        //   bottomLeft: Radius.circular(29.0),
                        // ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 110,
                                height: 65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7.0),
                                  child: Image.network(
                                    branch.imageName!,
                                    width: 110,
                                    height: 65,
                                    fit: BoxFit.fill,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      }

                                      return const Center(
                                          child: CircularProgressIndicator
                                              .adaptive());
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${branch.name}',
                                        style: CommonStyles.txSty_18b_fb),
                                    const SizedBox(height: 4.0),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                //MARK: location_icon
                                                // Image.asset(
                                                //   'assets/location_icon.png',
                                                //   width: 20,
                                                //   height: 18,
                                                // ),
                                                // const SizedBox(
                                                //     width:
                                                //         4.0),
                                                Expanded(
                                                  child: Text(
                                                      '${branch.address}',
                                                      style: CommonStyles
                                                          .txSty_12b_fb),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    /*
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        height: 26,
                                        margin: const EdgeInsets.only(
                                            bottom: 10.0, right: 10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color:
                                                const Color(0xFF8d97e2),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF8d97e2),
                                            backgroundColor:
                                                Colors.transparent,
                                            elevation: 0,
                                            shadowColor:
                                                Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10.0),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/datepicker_icon.svg',
                                                width: 15.0,
                                                height: 15.0,
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                'Book Now',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      Color(0xFF8d97e2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                 */
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  FutureBuilder<Object?> marqueeScroll() {
    return FutureBuilder(
      future: getMarqueeText(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else if (snapshot.hasError) {
          return const SizedBox();
        } else {
          if (marqueeText != null) {
            return Container(
              height: 40,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/wave_background.png',
                  ),
                ),
              ),
              child: Marquee(
                text: marqueeText!,
                style: CommonStyles.text16white,
                velocity: _shouldStartMarquee ? 30 : 0,
              ),
            );
          } else {
            return const SizedBox();
          }
        }
      },
    );
  }

  Widget carousel(BuildContext context) {
    if (_items.isEmpty) {
      return SizedBox
          .shrink(); // This hides the carousel by returning an empty widget
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: FlutterCarousel(
        options: CarouselOptions(
          floatingIndicator: true,
          height: 180,
          viewportFraction: 1.0,
          enlargeCenterPage: true,
          autoPlay: _items.length > 1,
          enableInfiniteScroll: _items.length > 1,
          aspectRatio: 16 / 9,
          autoPlayCurve: Curves.fastOutSlowIn,
          //  enableInfiniteScroll: true,
          slideIndicator: CircularSlideIndicator(
            slideIndicatorOptions: SlideIndicatorOptions(
              itemSpacing: 10,
              padding: const EdgeInsets.only(bottom: 10.0),
              indicatorBorderColor: const Color(0xFF11528f),
              currentIndicatorColor: const Color(0xFF11528f),
              indicatorRadius: 4,
            ),
          ),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
        ),
        items: _items.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imageName,
                      height: 200,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  // Container carousel(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
  //     width: MediaQuery.of(context).size.width,
  //     height: 180,
  //     child: _items.isNotEmpty
  //         ? FlutterCarousel(
  //       options: CarouselOptions(
  //         floatingIndicator: true,
  //         height: 180,
  //         viewportFraction: 1.0,
  //         enlargeCenterPage: true,
  //         autoPlay: true,
  //         aspectRatio: 16 / 9,
  //         autoPlayCurve: Curves.fastOutSlowIn,
  //         enableInfiniteScroll: true,
  //         slideIndicator: CircularSlideIndicator(
  //           slideIndicatorOptions: SlideIndicatorOptions(
  //             itemSpacing: 10,
  //             padding: const EdgeInsets.only(bottom: 10.0),
  //             indicatorBorderColor: const Color(0xFF11528f),
  //             currentIndicatorColor: const Color(0xFF11528f),
  //             indicatorRadius: 4,
  //           ),
  //         ),
  //         autoPlayAnimationDuration: const Duration(milliseconds: 800),
  //       ),
  //       items: _items.map((item) {
  //         return Builder(
  //           builder: (BuildContext context) {
  //             return SizedBox(
  //               width: MediaQuery.of(context).size.width,
  //               child: Card(
  //                 shadowColor: Colors.transparent,
  //                 surfaceTintColor: Colors.transparent,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 elevation: 4,
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Image.network(
  //                     item.imageName,
  //                     height: 200,
  //                     fit: BoxFit.fill,
  //                     loadingBuilder: (context, child, loadingProgress) {
  //                       if (loadingProgress == null) return child;
  //                       return const Center(
  //                         child: CircularProgressIndicator.adaptive(),
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       }).toList(),
  //     )
  //         : const Center(
  //       child: Text(
  //         'No Banners Available',
  //         style: TextStyle(
  //           fontSize: 16.0,
  //           color: Colors.black,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Container carousel(BuildContext context) {
  //   return    Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
  //     width: MediaQuery.of(context).size.width,
  //     height: 180,
  //     child:  FlutterCarousel(
  //       options: CarouselOptions(
  //         floatingIndicator: true,
  //         height: 180,
  //         viewportFraction: 1.0,
  //         enlargeCenterPage: true,
  //         autoPlay: true,
  //         aspectRatio: 16 / 9,
  //         autoPlayCurve: Curves.fastOutSlowIn,
  //         enableInfiniteScroll: true,
  //         slideIndicator: CircularSlideIndicator(
  //           slideIndicatorOptions: SlideIndicatorOptions(itemSpacing: 10,
  //           padding: const EdgeInsets.only(bottom: 10.0),
  //           indicatorBorderColor: Color(0xFF11528f),
  //           currentIndicatorColor: Color(0xFF11528f),
  //           indicatorRadius: 4,
  //         ),),
  //         autoPlayAnimationDuration: const Duration(milliseconds: 800),
  //       ),
  //       items: _items.map((item) {
  //         return Builder(
  //           builder: (BuildContext context) {
  //             return SizedBox(
  //               width: MediaQuery.of(context).size.width,
  //               child: Card(
  //                 shadowColor: Colors.transparent,
  //                 surfaceTintColor: Colors.transparent,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 elevation: 4,
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(10),
  //                   child: Image.network(
  //                     item.imageName,
  //                     height: 200,
  //                     fit: BoxFit.fill,
  //                     loadingBuilder: (context, child, loadingProgress) {
  //                       if (loadingProgress == null) return child;
  //                       return const Center(child: CircularProgressIndicator.adaptive());
  //                     },
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       }).toList(),
  //     ),
  //   );
  //   //   Container(
  //   //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //   //   width: MediaQuery.of(context).size.width,
  //   //   height: 180,
  //   //   child: FlutterCarousel(
  //   //     options: CarouselOptions(
  //   //       floatingIndicator: false,
  //   //       height: 180,
  //   //       viewportFraction: 1.0,
  //   //       enlargeCenterPage: true,
  //   //       autoPlay: true,
  //   //       aspectRatio: 16 / 9,
  //   //       autoPlayCurve: Curves.fastOutSlowIn,
  //   //       enableInfiniteScroll: true,
  //   //       slideIndicator: const CircularSlideIndicator(
  //   //         indicatorBorderColor: CommonStyles.blackColor,
  //   //         currentIndicatorColor: CommonStyles.primaryTextColor,
  //   //         indicatorRadius: 2, // Decrease the size of the indicator
  //   //       ),
  //   //       autoPlayAnimationDuration: const Duration(milliseconds: 800),
  //   //     ),
  //   //     items: _items.map((item) {
  //   //       return Builder(
  //   //         builder: (BuildContext context) {
  //   //           return SizedBox(
  //   //             width: MediaQuery.of(context).size.width,
  //   //             child: Card(
  //   //               shape: RoundedRectangleBorder(
  //   //                 borderRadius: BorderRadius.circular(10),
  //   //               ),
  //   //               elevation: 4,
  //   //               child: ClipRRect(
  //   //                 borderRadius: BorderRadius.circular(10),
  //   //                 child: Image.network(
  //   //                   item.imageName,
  //   //                   height: 100,
  //   //                   fit: BoxFit.cover,
  //   //                   loadingBuilder: (context, child, loadingProgress) {
  //   //                     if (loadingProgress == null) return child;
  //   //                     return const Center(
  //   //                         child: CircularProgressIndicator.adaptive());
  //   //                   },
  //   //                 ),
  //   //               ),
  //   //             ),
  //   //           );
  //   //         },
  //   //       );
  //   //     }).toList(),
  //   //   ),
  //   // );
  // }

  getMarqueeText() async {
    final apiUrl = Uri.parse(baseUrl + getcontent);

    try {
      final jsonResponse = await http.get(apiUrl);

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);

        if (response['isSuccess']) {
          int records = response['affectedRecords'];
          String resultText = '';
          for (var i = 0; i < records; i++) {
            if (response['listResult'][i]['text'] != null) {
              resultText += '${response['listResult'][i]['text']}  -  ';
            }
          }
          marqueeText = resultText.isEmpty ? null : resultText;
        } else {
          print('api failed');
          throw Exception('api failed');
        }
      } else {
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFf3e3ff),
      title: const Text(
        'Agent DashBoard',
        style: TextStyle(
            color: Color(0xFF0f75bc),
            fontSize: 16.0,
            fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: CommonStyles.primaryTextColor,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Widget welcomeText() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
  //     height: 80,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Text(
  //           'Hello!',
  //           style: CommonStyles.txSty_16w_fb,
  //         ),
  //         Text(
  //           userFullName,
  //           style: CommonStyles.txSty_18w_fb,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget marquee() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: FutureBuilder(
        future: getMarqueeText(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else if (snapshot.hasError) {
            return const SizedBox();
          } else {
            if (marqueeText != null) {
              return SizedBox(
                height: 30,
                child: Marquee(
                  text: marqueeText!,
                  style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "Outfit",
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFff0176)),
                ),
              );
            } else {
              return const SizedBox();
            }
          }
        },
      ),
    );
  }

  Widget agentBranches() {
    return Container(
      //height: MediaQuery.of(context).size.height / 4,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: FutureBuilder(
        future: apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Expanded(
              child: Center(
                  child: Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''))),
            );
          } else {
            List<AgentBranchModel>? data = snapshot.data!;
            return SizedBox(
              //  width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height / 3.5,
              child:
                  // ListView.builder(
                  //   scrollDirection: Axis.horizontal,
                  //   itemCount: data.length,
                  GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    mainAxisExtent: 250,
                    childAspectRatio: 8 / 2),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return BranchCard(
                    branch: data[index],
                    agentid: widget.agentid,
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  // Future<List<BranchList>> getBranchsData() async {
  // //  var apiUrl = 'http://182.18.157.215/SaloonApp/API/GetBranchById/null/true';
  //   var apiUrl = baseUrl + GetBranchByUserId + '$AgentId';
  //   try {
  //     final jsonResponse = await http.get(
  //       Uri.parse(apiUrl),
  //     );
  //
  //     if (jsonResponse.statusCode == 200) {
  //       Map<String, dynamic> response = jsonDecode(jsonResponse.body);
  //       List<dynamic> branchesData = response['listResult'];
  //       List<BranchList> result = branchesData.map((e) => BranchList.fromJson(e)).toList();
  //       print('result: ${result[0].name}');
  //       print('result: ${result[0].address}');
  //       print('result: ${result[0].imageName}');
  //       return result;
  //     } else {
  //       throw Exception('api failed');
  //     }
  //   } catch (e) {
  //     print('errorin$e');
  //     rethrow;
  //   }
  // }
  Future<List<AgentBranchModel>> getBranches(int userId) async {
    String apiUrl = '$baseUrl$GetBranchByUserId$userId/null';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('apiUrl: $apiUrl');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic>? listResult = data['listResult']; // Add a check for null
        if (listResult != null) {
          List<AgentBranchModel> result =
              listResult.map((e) => AgentBranchModel.fromJson(e)).toList();
          return result;
        } else {
          print('No Branches found!');
          throw Exception('No Branches found!');
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      // throw Exception('Error: $error');
      rethrow;
    }
  }

  // Future<List<BranchList>> getBranches(int userId) async {
  //   String apiUrl = '$baseUrl$GetBranchByUserId$userId';
  //
  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //     print('apiUrl: $apiUrl');
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       List<dynamic> listresult = data['listResult'];
  //       print('response$listresult');
  //       List<BranchList> result = listresult.map((e) => BranchList.fromJson(e)).toList();
  //       return result;
  //     } else {
  //       print('Request failed with status: ${response.statusCode}');
  //       throw Exception('Request failed with status: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //     throw Exception('Error: $error');
  //   }
  // }

  Widget screens() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Branches_screen(userId: AgentId!)),
          );
        },
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 11,
          //height: 60,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: CommonStyles.primaryTextColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CommonStyles.primaryTextColor),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/noun-appointment-date-2417776.svg',
                    width: 30.0,
                    height: 30.0,
                    color: CommonStyles.whiteColor,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Click Here To',
                      style: CommonStyles.txSty_16p_f5,
                    ),
                    Text(
                      'Check Appointment',

                      /// style: CommonStyles.txSty_20p_fb,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Calibri",
                        fontWeight: FontWeight.bold,
                        color: CommonStyles.primaryTextColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class BranchCard extends StatelessWidget {
  final AgentBranchModel branch;
  final int agentid;

  const BranchCard({super.key, required this.branch, required this.agentid});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddConsulationscreen(agentId: agentid, branch: branch),
              ));

          print('branchid${branch.id}');
        },
        child: Container(

            //padding: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Color(0xFFdbeaff),
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                // BoxShadow(
                //   color: Colors.grey.withOpacity(0.3),
                //   spreadRadius: 2,
                //   blurRadius: 5,
                //   offset: Offset(1, 3),
                //   blurStyle: BlurStyle.solid
                // ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  // top: 0,
                  //     right: 20,
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 10),
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
                        branch.imageName!,
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
                    width: 65,
                    height: 60,
                  ),
                ),
                // SizedBox(height: 8.0),
                Padding(
                  padding: EdgeInsets.only(
                      left: 10.0, right: 5.0, top: 5.0, bottom: 5.0),
                  child: Text(
                    '${branch.name}',
                    maxLines: 3,
                    style: CommonStyles.txSty_20b_fb,
                  ),
                ),
                // SizedBox(height: 8.0),
                Padding(
                    padding:
                        EdgeInsets.only(left: 10.0, right: 5.0, bottom: 5.0),
                    child: SizedBox(
                      height: 70.0,
                      child: Text(
                        '${branch.address}',
                        maxLines: 4,
                        style: CommonStyles.txSty_12b_fb.copyWith(
                            wordSpacing: 1.2,
                            color: Colors.black.withOpacity(0.8)),
                        //  style:  GoogleFonts.outfit(fontSize: 12,fontWeight: FontWeight.w500,wordSpacing: 1.2,color: Colors.black.withOpacity(0.8)),
                      ),
                    )),
                //  SizedBox(height: 5.0),
                // Display from date and to date multiple times
                Expanded(
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          height: 30,
                          margin: const EdgeInsets.only(
                              bottom: 10.0, left: 10.0, top: 5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFF11528f),
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddConsulationscreen(
                                        agentId: agentid, branch: branch),
                                  ));
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      10.0), // Adjust padding as needed, // Remove padding
                              foregroundColor: Color(0xFF8d97e2),
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Add Consultation',
                                    style: CommonStyles.txSty_14blu_f5),
                                SizedBox(width: 5),
                                SvgPicture.asset(
                                  'assets/calendarplus.svg',
                                  width: 12.0,
                                  height: 12.0,
                                  color: Color(0xFF11528f),
                                ),
                              ],
                            ),
                          ),
                        )))
              ],
            )));
  }
}
