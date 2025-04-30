import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';

import 'package:flutter_svg/svg.dart';

import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/aboutus_screen.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/offers_model.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Booking_Screen.dart';
import 'BranchModel.dart';
import 'CommonUtils.dart';
import 'HomeScreen.dart';
import 'Model_Branch.dart';

class Branch {
  final int branchId;
  final String branchname;
  final String branchaddress;
  final String phonenumber;
  final String branchImage;
  final double? latitude;
  final double? longitude;
  final String? LocationUrl;

  Branch(
      {required this.branchId,
      required this.branchname,
      required this.branchaddress,
      required this.phonenumber,
      required this.branchImage,
      required this.latitude,
      required this.longitude,
      required this.LocationUrl});
}

class CustomerDashBoard extends StatefulWidget {
  final void Function()? bookNowButtonPressed;
  final Function(Branch data) toNavigate;
  final bool popupbool;

  const CustomerDashBoard(
      {super.key,
      this.bookNowButtonPressed,
      required this.toNavigate,
      required this.popupbool});

  @override
  State<CustomerDashBoard> createState() => _CustomerDashBoardState();
}

class _CustomerDashBoardState extends State<CustomerDashBoard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  String? marqueeText;
  Completer<void>? _offersCompleter;
  List<BannerImages> imageList = [];

  List<BranchModel> brancheslist = [];
  // final CarouselController carouselController = CarouselController();
  int currentIndex = 0;
  bool isLoading = true;
  bool isDataBinding = false;
  bool apiAllowed = true;
  late Timer _timer;
  final bool _shouldStartMarquee = true;
  List<Item> _items = [];

  String userFullName = '';
  List<String> marqueeTexts = [];
  int currentTextIndex = 0;
  bool ismatchedlogin = false;
  String apiimagename = '';

  // static final CustomerDashBoard _instance = CustomerDashBoard._internal();
  // factory CustomerDashBoard() => _instance;
  // CustomerDashBoard._internal();

  bool _isFetching = false;

  bool _isApiCalled = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    print('popupflag:${widget.popupbool}');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_animationController.value *
              _scrollController.position.maxScrollExtent);
        }
      });

    _animationController.repeat();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    _checkConnectivityAndFetchData();
    // CommonUtils.checkInternetConnectivity().then((isConnected) {
    //   if (isConnected) {
    //     print('Connected to the internet');
    //     getMarqueeText();
    //     fetchCarouselData();
    //     fetchData();
    //     fetchLoginUserInfo();
    //    // print('fetchoffers${fetchoffers()}');
    //
    //     if (!_isApiCalled) {
    //       _isApiCalled = true;
    //       fetchoffers();
    //     }
    //
    //     //fetchimagesslider();
    //     fetchImages();
    //
    //   } else {
    //     CommonUtils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
    //     print('Not connected to the internet');
    //   }
    // });
  }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   fetchoffers();
  //   // Your API call here
  // }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   // if (state == AppLifecycleState.resumed) {
//   //   print('state:${state}');
//   //    // Reset the popup flag when the app is restarted
//   // }
//   if(state==AppLifecycleState.resumed){
//     print('state:${state}');
//     fetchoffers();
//   }
// }

  Future<void> _resetPopupFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownPopup', false); // Reset the flag
    await fetchoffers();
    print('Popup flag reset. Popup will show again when entering the screen.');
  }

  Future<void> _checkConnectivityAndFetchData() async {
    if (_isApiCalled) return; // Avoid calling API again
    _isApiCalled = true;

    bool isConnected = await CommonUtils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');

      await getMarqueeText();
      await fetchCarouselData();
      await fetchData();
      await fetchLoginUserInfo();
      await fetchoffers();
      await fetchImages();
    } else {
      CommonUtils.showCustomToastMessageLong(
          'No Internet Connection', context, 1, 4);
      print('Not connected to the internet');
    }
  }

  Future<void> fetchLoginUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userFullName = prefs.getString('userFullName') ?? '';
    });
  }

  Future<void> getMarqueeText() async {
    final apiUrl = Uri.parse(baseUrl + getcontent);
    print('apiUrl$apiUrl');
    try {
      final jsonResponse = await http.get(apiUrl);

      if (jsonResponse.statusCode == 200) {
        final response = json.decode(jsonResponse.body);

        if (response['isSuccess']) {
          int records = response['affectedRecords'];
          for (var i = 0; i < records; i++) {
            String text = response['listResult'][i]['text'] ?? '';
            if (text.isNotEmpty) {
              marqueeTexts.add(text);
            }
          }
          setState(() {});
        } else {
          print('API failed');
          throw Exception('API failed');
        }
      } else {
        throw Exception(
            'Request failed with status: ${jsonResponse.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  void nextText() {
    setState(() {
      currentTextIndex = (currentTextIndex + 1) % marqueeTexts.length;
    });
  }

  // Future<void> getMarqueeText() async {
  //   final apiUrl = Uri.parse(baseUrl + getcontent);
  //   print('apiUrl$apiUrl');
  //   try {
  //     final jsonResponse = await http.get(apiUrl);
  //
  //     if (jsonResponse.statusCode == 200) {
  //       final response = json.decode(jsonResponse.body);
  //
  //       if (response['isSuccess']) {
  //         int records = response['affectedRecords'];
  //         for (var i = 0; i < records; i++) {
  //           marqueeText = response['listResult'][i]['text'] != null ? '${response['listResult'][i]['text']} ' : null;
  //           print('marqueeTextA$marqueeText');
  //         }
  //       } else {
  //         print('api failed');
  //         throw Exception('api failed');
  //       }
  //     } else {
  //       throw Exception('Request failed with status: ${jsonResponse.statusCode}');
  //     }
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
          brancheslist.clear();
        });
      }
    });

    await _getData();
  }

  void fetchimagesslider() async {
    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 15), () {
      if (isLoading) {
        setState(() {
          isLoading = false;
          imageList.clear();
        });
      }
    });

    await fetchImages();
  }

  // void fetchCarouselData() async {
  //   final response = await http.get(Uri.parse(baseUrl + getbanner));
  //   setState(() {
  //     isDataBinding = true;
  //     isLoading = true;
  //   });
  //   if (response.statusCode == 200) {
  //     final decodedResponse = json.decode(response.body);
  //     final listResult = decodedResponse['listResult'];
  //
  //     setState(() {
  //       if (listResult != null && listResult.isNotEmpty) {
  //         _items = (listResult as List)
  //             .map((item) => Item.fromJson(item))
  //             .toList();
  //       } else {
  //         _items = []; // or null depending on how you handle it in the UI
  //         noBannerFound = true; // Add this flag to show "No banner found"
  //       }
  //       isDataBinding = false;
  //       isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       isDataBinding = false;
  //       isLoading = false;
  //     });
  //     throw Exception('Failed to load items');
  //   }
  // }

  Future<void> fetchCarouselData() async {
    final response = await http.get(Uri.parse(baseUrl + getbanner));
    setState(() {
      isDataBinding = true;
      isLoading = true;
    });
    if (response.statusCode == 200) {
      setState(() {
        _items = (json.decode(response.body)['listResult'] as List)
            .map((item) => Item.fromJson(item))
            .toList();
        isDataBinding = false;
        isLoading = false;
      });
    } else {
      isDataBinding = false;
      isLoading = false;
      throw Exception('Failed to load items');
    }
  }

  Future<void> _getData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl + getbranches);
    print('url==>135: $url');

    bool success = false;
    int retries = 0;
    const maxRetries = 1;

    while (!success && retries < maxRetries) {
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Failed to fetch data:  $data');

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
              cityName: item['cityName'],
              createdBy: item['createdBy'],
              updatedBy: item['updatedBy'],
              latitude: item['latitude'],
              longitude: item['longitude'],
              locationUrl: item['locationUrl'],
            ));
          }

          setState(() {
            brancheslist = branchList;
            isLoading = false;
          });

          success = true;
        } else {
          print('Request failed with status: ${response.statusCode}');
          setState(() {
            isLoading = false;
          });
        }
      } catch (error) {
        print('Error data is not getting from the api: $error');
        setState(() {
          isLoading = false;
        });
      }

      retries++;
    }

    if (!success) {
      print('All retries failed. Unable to fetch data from the API.');
    }
  }

  Future<void> fetchImages() async {
    setState(() {
      isDataBinding = true;
      isLoading = true;
    });
    final url = Uri.parse(baseUrl + getBanners);
    print('url==>127: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        List<BannerImages> bannerImages = [];
        for (var item in jsonData['listResult']) {
          bannerImages.add(BannerImages(
              imageName: item['imageName'] ?? '', id: item['id'] ?? 0));
        }

        setState(() {
          imageList = bannerImages;
          isDataBinding = false;
          isLoading = false;
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          isDataBinding = false;
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error images are not from the api: $error');
      setState(() {
        isDataBinding = false;
        isLoading = false;
      });
    }
  }

  void retryDataFetching() {
    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('Connected to the internet');
        //fetchImages();

        fetchData();
        fetchimagesslider();
      } else {
        CommonUtils.showCustomToastMessageLong(
            'No Internet Connection', context, 1, 4);
        print('Not connected to the internet');
      }
    });
  }

  // showDialog(
  //   barrierDismissible: true,
  //   context: context,
  //   builder: (BuildContext context) {
  //     return StatefulBuilder(
  //       builder: (context, setState) {
  //         return Dialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(15),
  //           ),
  //           // Wrap the Dialog in a SizedBox to set a fixed height
  //           child: SizedBox(
  //             height: MediaQuery.of(context).size.height / 2, // Set height for both dialog and image
  //             width: double.infinity,
  //             child: Stack(
  //               children: [
  //                 // Image inside the dialog
  //                 ClipRRect(
  //                   borderRadius: BorderRadius.circular(15),
  //                   child: Image.network(
  //                     '$imagename',
  //                     height: MediaQuery.of(context).size.height / 2, // Same height as the dialog
  //                     width: double.infinity,
  //                     fit: BoxFit.cover,
  //                     loadingBuilder: (context, child, loadingProgress) {
  //                       if (loadingProgress == null) return child;
  //                       return Center(
  //                         child: CircularProgressIndicator(
  //                           value: loadingProgress.expectedTotalBytes != null
  //                               ? loadingProgress.cumulativeBytesLoaded /
  //                               (loadingProgress.expectedTotalBytes ?? 1)
  //                               : null,
  //                         ),
  //                       );
  //                     },
  //                     errorBuilder: (context, error, stackTrace) {
  //                       return Container(
  //                         height: MediaQuery.of(context).size.height / 2,
  //                         color: Colors.grey,
  //                         child: Center(
  //                           child: Text(
  //                             'Failed to load image',
  //                             style: TextStyle(color: Colors.white),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //
  //                 ),
  //                 // Close Button (X)
  //                 Positioned(
  //                   right: 10,
  //                   // top: 10,
  //                   child: IconButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     icon: Icon(Icons.close),
  //                     color: Colors.grey,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   },
  // );
  void _showpopupdialog(BuildContext context) {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                // Wrap the Dialog in a SizedBox to set a fixed height
                child: Container(
                  height: MediaQuery.of(context).size.height /
                      2, // Set height for both dialog and image
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white, // White border color
                      width: 2, // Border width
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      //   Container(
                      //   decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(15),
                      //   border: Border.all(
                      //     color: Colors.white, // White border color
                      //     width: 4, // Border width
                      //   ),
                      // ),),
                      // Image inside the dialog
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          '$apiimagename',
                          height: MediaQuery.of(context).size.height / 2,
                          // Same height as the dialog
                          width: double.infinity,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: MediaQuery.of(context).size.height / 2,
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  'Failed to load Image',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Close Button (X)
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey,
                          child: Center(
                            child: InkResponse(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: CircleAvatar(
                                radius: 12,
                                child: Icon(Icons.close,
                                    size: 18, color: Colors.white),
                                backgroundColor: Colors.grey,
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
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return SizedBox.shrink();
        });
  }

  Future<void> fetchoffers() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    // // Check if the popup has already been shown
    // bool? hasShownPopup = prefs.getBool('hasShownPopup') ?? false;
    //
    // if (!hasShownPopup) {
    //   // Popup has already been shown, don't fetch offers or show the popup again
    //   print('Popup already shown. Skipping...');
    //   return;
    // }

    final url = Uri.parse(baseUrl + DisplayOffers);
    print('displayoffers: $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        bool offerFound = false;
        Map<String, dynamic> data = json.decode(response.body);
        // Parse the response to the ListResultResponse model
        ListResultResponse resultResponse = ListResultResponse.fromJson(data);
        // Filter for offers where isActive is true and print imageName and fileName
        if (resultResponse.listResult != null) {
          for (var offer in resultResponse.listResult!) {
            if (offer.isActive == true) {
              print('Image Name: ${offer.imageName}');
              print('File Name: ${offer.fileName}');
              setState(() {
                ismatchedlogin = true;
                apiimagename = offer.imageName!;
              });
              if (ismatchedlogin) {
                if (widget.popupbool == true) {
                  _showpopupdialog(context);
                  //await prefs.setBool('hasShownPopup', true);
                }
              }
              offerFound = true;
              break;
            }
          }
          if (!offerFound) {
            setState(() {
              ismatchedlogin = false;
            });
            print('No active offers found.');
          }
        } else {
          setState(() {
            ismatchedlogin = false;
          });
          print('No offers found.');
        }
        // Convert the list of dynamic data to a list of ViewProduct
      } else {
        setState(() {
          ismatchedlogin = false;
        });
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _offersCompleter!.completeError(e);
      // ProgressManager.stopProgress();
      print('Error slot: $e');
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    // if (ismatchedlogin) {
    //   Future.microtask(() => _showtimeoutdialog(context));
    // }
    return Scaffold(
      backgroundColor: CommonStyles.whiteColor,
      body: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              //  height: MediaQuery.of(context).size.height,
              child: Column(
                //    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello ',
                              style: CommonStyles.txSty_20b_fb
                                  .copyWith(fontSize: 22),
                              //style: GoogleFonts.outfit(fontWeight: FontWeight.w700,fontSize: 22,color: Colors.black),
                            ),
                            Text(
                              userFullName,
                              style: CommonStyles.txSty_20b_fb.copyWith(
                                  fontSize: 22, color: const Color(0xFF11528f)),
                              //  style:GoogleFonts.outfit(fontWeight: FontWeight.w700,fontSize: 22,color: Color(0xFF11528f)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        const Row(
                          children: [
                            Text(
                              'Welcome to ',
                              //    style: CommonStyles.txSty_20b_fb.copyWith(fontSize: 22),
                              style: CommonStyles.txSty_16b_fb,
                            ),
                            Text(
                              'HAIR FIXING ZONE',
                              style: CommonStyles.txSty_16p_f5,
                            ),
                          ],
                        ),
                        // Text(Hair Fixing Zone
                        //   'Welcome to Hair Fixing Zone',
                        //   style: TextStyle(
                        //     //  fontSize: MediaQuery.of(context).size.width * 0.04,
                        //     fontSize: 10,
                        //     fontFamily: "Muli",
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.black,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child:
                  Column(
                    children: [
                      // if ( imageList.isEmpty)
                      //   Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      //     child: Container(
                      //       width: MediaQuery.of(context).size.width,
                      //       height: 200,
                      //       padding: const EdgeInsets.all(15.0),
                      //       child: Center(
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Text(
                      //               'No Banners Found',style:CommonStyles.txSty_14b_fb,),
                      //            // const SizedBox(height: 20),
                      //             // ElevatedButton(
                      //             //   onPressed: retryDataFetching,
                      //             //   child: const Text('Retry'),
                      //             // ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      if (!imageList.isEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : FlutterCarousel(
                                  options: CarouselOptions(
                                    floatingIndicator: true,
                                    height: 200,
                                    viewportFraction: 1.0,
                                    enlargeCenterPage: true,
                                    autoPlay: imageList.length > 1,
                                    aspectRatio: 16 / 9,
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enableInfiniteScroll: imageList.length > 1,
                                    slideIndicator:
                                        const CircularSlideIndicator(
                                      slideIndicatorOptions:
                                          SlideIndicatorOptions(
                                        itemSpacing: 10,
                                        padding: EdgeInsets.only(bottom: 10.0),
                                        indicatorBorderColor: Color(0xFF11528f),
                                        currentIndicatorColor:
                                            Color(0xFF11528f),
                                        indicatorRadius: 4,
                                      ),
                                    ),
                                    //autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                  ),
                                  items: _items.map((item) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Card(
                                            shadowColor: Colors.transparent,
                                            surfaceTintColor:
                                                Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 4,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                item.imageName,
                                                height: 200,
                                                fit: BoxFit.fill,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator
                                                              .adaptive());
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),

                      const SizedBox(height: 10),
                      if (marqueeTexts.isNotEmpty)
                        SizedBox(
                          height: 70.0,
                          child: Container(
                            color: Color(0xFF11528f).withOpacity(
                                0.9), // Set the background color here
                            child: Stack(children: [
                              // Assets/images/stacked-steps-haikei.png

                              Positioned.fill(
                                child: InfiniteMarquee(
                                  frequency: const Duration(milliseconds: 100),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Image.asset(
                                      'assets/bar_texture_rec.png',
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                    );
                                  },
                                ),
                              ),

                              // Center(
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(left: 10.0, right: 20.0,bottom: 10), // Add padding to icon
                              //     child: Text(
                              //       marqueeTexts.isNotEmpty ? marqueeTexts[currentTextIndex] : '',
                              //       style: CommonStyles.text14white.copyWith(height: 1.5),
                              //     ),
                              //   ),
                              // ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 30.0,
                                      bottom: 10,
                                      top: 5), // Add padding to icon
                                  child: Scrollbar(
                                    //thumbVisibility: true, // Show the scrollbar when scrolling
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis
                                          .vertical, // Scroll horizontally for long text
                                      child: Text(
                                        marqueeTexts.isNotEmpty
                                            ? marqueeTexts[currentTextIndex]
                                            : '',
                                        style: CommonStyles.text14white
                                            .copyWith(height: 1.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (marqueeTexts.length > 1)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0.0,
                                        right: 0.0), // Add padding to icon
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios,
                                          color: Colors.white),
                                      onPressed: nextText,
                                    ),
                                  ),
                                ),
                            ]),

                            /*
                            Stack(
                              children: [
                                ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      2, // Ensures the image can scroll infinitely
                                  physics:
                                      const SlowScrollPhysics(), // Apply custom scroll physics here
                                  itemBuilder: (context, index) {
                                    return Image.asset(
                                      'assets/bar_texture_rec.png',
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width,
                                    );
                                  },
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 20.0), // Add padding to icon
                                    child: Text(
                                      marqueeTexts.isNotEmpty
                                          ? marqueeTexts[currentTextIndex]
                                          : '',
                                      style: CommonStyles.text14white
                                          .copyWith(height: 1.5),
                                      // style:
                                      // GoogleFonts.outfit(
                                      //   fontWeight: FontWeight.w600,
                                      //   fontSize: 14,
                                      //   color: Colors.white,
                                      //   height: 1.5, // Adjust line spacing here
                                      //   ),
                                    ),
                                  ),
                                ),
                                if (marqueeTexts.length > 1)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0.0,
                                          right: 0.0), // Add padding to icon
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white),
                                        onPressed: nextText,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                           */
                          ),
                        ),

                      const SizedBox(height: 10),

                      //MARK: Branches
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 5.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Our Branches",
                            style: CommonStyles.txSty_20b_fb,
                          ),

                          // Text(
                          //   'Select a Branch',
                          //   textAlign: TextAlign.left,
                          //   //style: CommonStyles.txSty_20b_fb,
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     fontFamily: "Muli",
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.black,
                          //   ),
                          // //  style:  GoogleFonts.outfit(fontWeight: FontWeight.w500,fontSize: 16,color: Color(0xFF11528f)),
                          //
                          // ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isLoading)
                        const Text(
                            'Please Wait Loading Slow Internet Connection !')
                      else if (brancheslist.isEmpty && imageList.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            padding: const EdgeInsets.all(15.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No Branches Found',
                                    style: CommonStyles.txSty_14b_fb,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: retryDataFetching,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      //   child: LayoutBuilder(
                      //     builder: (context, constraints) {
                      //       // Get the text scale factor based on device font size settings
                      //       double textScaleFactor = MediaQuery.of(context).textScaleFactor;
                      //
                      //       // Clamp the textScaleFactor to be between 0.9 and 2.0
                      //       double adjustedTextScaleFactor = textScaleFactor.clamp(0.9, 2.0);
                      //
                      //       // Get the base text style's font size
                      //       double baseFontSize = Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16.0;
                      //
                      //       // Calculate the effective font size based on the adjusted text scale factor
                      //       double textSize = baseFontSize * adjustedTextScaleFactor;
                      //       print('textSize====$textSize');
                      //
                      //       // Determine the aspect ratio based on the text size
                      //       double childAspectRatio = textSize > 16.0 ? 0.65 : 0.65;
                      //       print('childAspectRatio====$childAspectRatio');
                      //       return GridView.builder(
                      //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //           crossAxisCount: 2,
                      //           crossAxisSpacing: 16.0,
                      //           mainAxisSpacing: 16.0,
                      //           childAspectRatio: childAspectRatio,
                      //         ),
                      //         physics: const NeverScrollableScrollPhysics(),
                      //         shrinkWrap: true,
                      //         itemCount: isLoading ? 5 : brancheslist.length,
                      //         itemBuilder: (context, index) {
                      //           if (isLoading) {
                      //             return Padding(
                      //               padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
                      //               child: Shimmer.fromColors(
                      //                 baseColor: Colors.grey.shade300,
                      //                 highlightColor: Colors.grey.shade100,
                      //                 child: Container(
                      //                   height: 150,
                      //                   decoration: BoxDecoration(
                      //                     color: Colors.white,
                      //                     borderRadius: BorderRadius.circular(15.0),
                      //                   ),
                      //                 ),
                      //               ),
                      //             );
                      //           } else {
                      //             BranchModel branch = brancheslist[index];
                      //             // Color backgroundColor = index % 2 == 0
                      //             //     ? const Color(0xFFdbeaff)
                      //             //     : const Color(0xFFcdeac3);
                      //             Color backgroundColor = const Color(0xFFdbeaff);
                      //
                      //             return GestureDetector(
                      //               onTap: () {},
                      //               child: Container(
                      //                 decoration: BoxDecoration(
                      //                   color: backgroundColor,
                      //                   borderRadius: BorderRadius.circular(15.0),
                      //                 ),
                      //                 child: Column(
                      //                   crossAxisAlignment: CrossAxisAlignment.start,
                      //                   children: [
                      //                     Align(
                      //                       alignment: Alignment.topLeft,
                      //                       child: Container(
                      //                         margin: const EdgeInsets.only(top: 20, left: 10),
                      //                         decoration: BoxDecoration(
                      //                           border: Border.all(
                      //                             color: Colors.grey,
                      //                             width: 2.5,
                      //                           ),
                      //                           borderRadius: BorderRadius.circular(15.0),
                      //                         ),
                      //                         width: 65,
                      //                         height: 60,
                      //                         child: ClipRRect(
                      //                           borderRadius: BorderRadius.circular(13.0),
                      //                           child: Image.network(
                      //                             branch.imageName!,
                      //                             width: 65,
                      //                             height: 60,
                      //                             fit: BoxFit.fill,
                      //                             loadingBuilder: (context, child, loadingProgress) {
                      //                               if (loadingProgress == null) {
                      //                                 return child;
                      //                               }
                      //                               return const Center(
                      //                                   child: CircularProgressIndicator.adaptive());
                      //                             },
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     Padding(
                      //                       padding: const EdgeInsets.only(
                      //                           left: 10.0, right: 5.0, top: 5.0, bottom: 5.0),
                      //                       child: Text(
                      //                         branch.name,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         maxLines: 1,
                      //                         style: CommonUtils.txSty_18b_fb,
                      //                       ),
                      //                     ),
                      //                     Padding(
                      //                       padding: const EdgeInsets.only(
                      //                           left: 10.0, right: 5.0, bottom: 5.0),
                      //                       child: Text(
                      //                         branch.address,
                      //                         maxLines: 4,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         style: CommonStyles.txSty_12b_fb
                      //                       ),
                      //                     ),
                      //                     const Spacer(),
                      //                     Align(
                      //                       alignment: Alignment.bottomLeft,
                      //                       child: Container(
                      //                         height: 30,
                      //                         margin: const EdgeInsets.only(
                      //                             bottom: 5.0, left: 10.0, top: 5.0),
                      //                         decoration: BoxDecoration(
                      //                           border: Border.all(
                      //                             color: const Color(0xFF11528f),
                      //                           ),
                      //                           borderRadius: BorderRadius.circular(20.0),
                      //                         ),
                      //                         child: ElevatedButton(
                      //                           onPressed: () {
                      //                             Navigator.push(
                      //                               context,
                      //                               MaterialPageRoute(
                      //                                 builder: (context) => Bookingscreen(
                      //                                   branchId: branch.id!,
                      //                                   branchname: branch.name,
                      //                                   branchaddress: branch.address,
                      //                                   phonenumber: branch.mobileNumber,
                      //                                   branchImage: branch.imageName!,
                      //                                   latitude: branch.latitude,
                      //                                   longitude: branch.longitude,
                      //                                   LocationUrl: branch.locationUrl,
                      //                                 ),
                      //                               ),
                      //                             );
                      //                           },
                      //                           style: ElevatedButton.styleFrom(
                      //                             padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      //                             foregroundColor: const Color(0xFF8d97e2),
                      //                             backgroundColor: Colors.transparent,
                      //                             elevation: 0,
                      //                             shadowColor: Colors.transparent,
                      //                             shape: RoundedRectangleBorder(
                      //                               borderRadius: BorderRadius.circular(20.0),
                      //                             ),
                      //                           ),
                      //                           child: Row(
                      //                             mainAxisSize: MainAxisSize.min,
                      //                             mainAxisAlignment: MainAxisAlignment.center,
                      //                             children: [
                      //                               const Text('Book Now',
                      //                                   style: CommonStyles.txSty_14p_f5),
                      //                               const SizedBox(width: 5),
                      //                               SvgPicture.asset(
                      //                                 'assets/squareupright.svg',
                      //                                 width: 12.0,
                      //                                 height: 12.0,
                      //                                 color: const Color(0xFF11528f),
                      //                               ),
                      //                             ],
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //             );
                      //           }
                      //         },
                      //       );
                      //     },
                      //   ),
                      // )
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    mainAxisExtent: 250,
                                    childAspectRatio: 8 / 2),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: isLoading ? 5 : brancheslist.length,
                            // ListView.builder(
                            //   shrinkWrap: true,
                            //   itemCount: isLoading ? 5 : brancheslist.length,
                            itemBuilder: (context, index) {
                              if (isLoading) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0, vertical: 5.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                BranchModel branch = brancheslist[index];
                                Color backgroundColor = index % 2 == 0
                                    ? const Color(0xFFdbeaff)
                                    : const Color(0xFFcdeac3);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Bookingscreen(
                                            branchId: branch.id!,
                                            branchname: branch.name,
                                            branchaddress: branch.address,
                                            phonenumber: branch.mobileNumber,
                                            branchImage: branch.imageName!,
                                            latitude: branch.latitude,
                                            longitude: branch.longitude,
                                            LocationUrl: branch.locationUrl),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFdbeaff),
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: const [
                                        // You can uncomment the shadow if needed
                                        // BoxShadow(
                                        //   color: Colors.grey.withOpacity(0.3),
                                        //   spreadRadius: 2,
                                        //   blurRadius: 5,
                                        //   offset: Offset(1, 3),
                                        // ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 20, left: 10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 2.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            width: 65,
                                            height: 60,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(13.0),
                                              child: Image.network(
                                                branch.imageName!,
                                                width: 65,
                                                height: 60,
                                                fit: BoxFit.fill,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 5.0,
                                            top: 5.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            branch.name,
                                            maxLines: 3,
                                            style: CommonUtils.txSty_18b_fb
                                                .copyWith(
                                              fontSize: 18 *
                                                  MediaQuery.of(context)
                                                      .textScaleFactor,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 5.0,
                                            bottom: 5.0,
                                          ),
                                          child: SizedBox(
                                            height: 70.0,
                                            child: Text(
                                              branch.address,
                                              maxLines: 4,
                                              style: CommonStyles.txSty_12b_fb
                                                  .copyWith(
                                                fontSize: 12 *
                                                    MediaQuery.of(context)
                                                        .textScaleFactor,
                                                wordSpacing: 1.2,
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            height: 30,
                                            margin: const EdgeInsets.only(
                                              bottom: 2.0,
                                              left: 10.0,
                                              top: 5.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFF11528f),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        Bookingscreen(
                                                            branchId:
                                                                branch.id!,
                                                            branchname:
                                                                branch.name,
                                                            branchaddress:
                                                                branch.address,
                                                            phonenumber: branch
                                                                .mobileNumber,
                                                            branchImage: branch
                                                                .imageName!,
                                                            latitude:
                                                                branch.latitude,
                                                            longitude: branch
                                                                .longitude,
                                                            LocationUrl: branch
                                                                .locationUrl),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0),
                                                foregroundColor:
                                                    const Color(0xFF8d97e2),
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'Book Now',
                                                    style: CommonStyles
                                                        .txSty_14p_f5,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  SvgPicture.asset(
                                                    'assets/squareupright.svg',
                                                    width: 12.0,
                                                    height: 12.0,
                                                    color:
                                                        const Color(0xFF11528f),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },

                            // Expanded(
                            //     //flex: 3,
                            //     child:
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            //   child: GridView.builder(
                            //     gridDelegate:
                            //     const SliverGridDelegateWithFixedCrossAxisCount(
                            //         crossAxisCount: 2,
                            //         crossAxisSpacing: 16.0,
                            //         mainAxisSpacing: 16.0,
                            //       //  mainAxisExtent: 250,
                            //
                            //         childAspectRatio:0.5),
                            //     physics: const NeverScrollableScrollPhysics(),
                            //     shrinkWrap: true,
                            //     itemCount: isLoading ? 5 : brancheslist.length,
                            //     // ListView.builder(
                            //     //   shrinkWrap: true,
                            //     //   itemCount: isLoading ? 5 : brancheslist.length,
                            //     itemBuilder: (context, index) {
                            //       if (isLoading) {
                            //         return Padding(
                            //           padding: const EdgeInsets.symmetric(
                            //               horizontal: 0.0, vertical: 5.0),
                            //           child: Shimmer.fromColors(
                            //             baseColor: Colors.grey.shade300,
                            //             highlightColor: Colors.grey.shade100,
                            //             child: Container(
                            //               height: 150,
                            //               decoration: BoxDecoration(
                            //                 color: Colors.white,
                            //                 borderRadius: BorderRadius.circular(15.0),
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       } else {
                            //         BranchModel branch = brancheslist[index];
                            //         Color backgroundColor = index % 2 == 0
                            //             ? const Color(0xFFdbeaff)
                            //             : const Color(0xFFcdeac3);
                            //
                            //         return GestureDetector(
                            //             onTap: () {},
                            //             child: Container(
                            //
                            //               //padding: EdgeInsets.only(top: 10),
                            //                 decoration: BoxDecoration(
                            //                   color: const Color(0xFFdbeaff),
                            //                   borderRadius:
                            //                   BorderRadius.circular(15.0),
                            //                   boxShadow: const [
                            //                     // BoxShadow(
                            //                     //   color: Colors.grey.withOpacity(0.3),
                            //                     //   spreadRadius: 2,
                            //                     //   blurRadius: 5,
                            //                     //   offset: Offset(1, 3),
                            //                     //   blurStyle: BlurStyle.solid
                            //                     // ),
                            //                   ],
                            //                 ),
                            //                 child: Column(
                            //                   crossAxisAlignment:
                            //                   CrossAxisAlignment.start,
                            //                   mainAxisAlignment:
                            //                   MainAxisAlignment.start,
                            //                   children: [
                            //                     Align(
                            //                       alignment: Alignment.topLeft,
                            //                       // top: 0,
                            //                       //     right: 20,
                            //                       child: Container(
                            //                         margin: const EdgeInsets.only(
                            //                             top: 20, left: 10),
                            //                         decoration: BoxDecoration(
                            //                           border: Border.all(
                            //                             color: Colors.grey,
                            //                             width: 2.5,
                            //                           ),
                            //                           borderRadius:
                            //                           BorderRadius.circular(15.0),
                            //                         ),
                            //                         width: 65,
                            //                         height: 60,
                            //                         child: ClipRRect(
                            //                           borderRadius:
                            //                           BorderRadius.circular(13.0),
                            //                           child: Image.network(
                            //                             branch.imageName!,
                            //                             width: 65,
                            //                             height: 60,
                            //                             fit: BoxFit.fill,
                            //                             loadingBuilder: (context,
                            //                                 child, loadingProgress) {
                            //                               if (loadingProgress ==
                            //                                   null) {
                            //                                 return child;
                            //                               }
                            //
                            //                               return const Center(
                            //                                   child:
                            //                                   CircularProgressIndicator
                            //                                       .adaptive());
                            //                             },
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     // SizedBox(height: 8.0),
                            //                     Padding(
                            //                       padding: const EdgeInsets.only(
                            //                           left: 10.0,
                            //                           right: 5.0,
                            //                           top: 5.0,
                            //                           bottom: 5.0),
                            //                       child: Text(
                            //                         branch.name,
                            //                         overflow: TextOverflow.ellipsis,
                            //                         maxLines: 1,
                            //                         style: CommonUtils.txSty_18b_fb,
                            //                         // style:  GoogleFonts.outfit(fontWeight: FontWeight.w700,fontSize: 18,color: Color(0xFF11528f)),
                            //                       ),
                            //                     ),
                            //                     // SizedBox(height: 8.0),
                            //                     Padding(
                            //                         padding: const EdgeInsets.only(
                            //                             left: 10.0,
                            //                             right: 5.0,
                            //                             bottom: 5.0),
                            //
                            //                           child: Text(
                            //                             branch.address,
                            //                             maxLines: 4,
                            //                             overflow: TextOverflow.ellipsis,
                            //                             style: CommonStyles
                            //                                 .txSty_12b_fb
                            //                                 .copyWith(
                            //                                 wordSpacing: 1.2,
                            //                                 color: Colors.black
                            //                                     .withOpacity(
                            //                                     0.8)),
                            //
                            //                         )),
                            //                     //  SizedBox(height: 5.0),
                            //                     // Display from date and to date multiple times
                            //                     Spacer(),
                            //                     Align(
                            //                         alignment: Alignment.bottomLeft,
                            //                         child: Container(
                            //                           height: 30,
                            //                           margin: const EdgeInsets.only(
                            //                               bottom: 5.0,
                            //                               left: 10.0,
                            //                               top: 5.0),
                            //                           decoration: BoxDecoration(
                            //                             border: Border.all(
                            //                               color:
                            //                               const Color(0xFF11528f),
                            //                             ),
                            //                             borderRadius:
                            //                             BorderRadius.circular(
                            //                                 20.0),
                            //                           ),
                            //                           child: ElevatedButton(
                            //                             onPressed: () {
                            //                               Navigator.push(
                            //                                 context,
                            //                                 MaterialPageRoute(
                            //                                   builder: (context) =>
                            //                                       Bookingscreen(
                            //                                           branchId: branch.id!,
                            //                                           branchname:
                            //                                           branch.name,
                            //                                           branchaddress:
                            //                                           branch.address,
                            //                                           phonenumber: branch
                            //                                               .mobileNumber,
                            //                                           branchImage:
                            //                                           branch.imageName!,
                            //                                           latitude:
                            //                                           branch.latitude,
                            //                                           longitude:
                            //                                           branch.longitude,
                            //                                           LocationUrl : branch.locationUrl
                            //                                       ),
                            //                                 ),
                            //                               );
                            //                             },
                            //                             style:
                            //                             ElevatedButton.styleFrom(
                            //                               padding: const EdgeInsets
                            //                                   .symmetric(
                            //                                   horizontal:
                            //                                   10.0), // Adjust padding as needed, // Remove padding
                            //                               foregroundColor:
                            //                               const Color(0xFF8d97e2),
                            //                               backgroundColor:
                            //                               Colors.transparent,
                            //                               elevation: 0,
                            //                               shadowColor:
                            //                               Colors.transparent,
                            //                               shape:
                            //                               RoundedRectangleBorder(
                            //                                 borderRadius:
                            //                                 BorderRadius.circular(
                            //                                     20.0),
                            //                               ),
                            //                             ),
                            //                             child: Row(
                            //                               mainAxisSize:
                            //                               MainAxisSize.min,
                            //                               mainAxisAlignment:
                            //                               MainAxisAlignment
                            //                                   .center,
                            //                               children: [
                            //                                 const Text('Book Now',
                            //                                     style: CommonStyles
                            //                                         .txSty_14p_f5
                            //                                   // GoogleFonts.outfit(
                            //                                   //   fontWeight: FontWeight.w500,
                            //                                   //   fontSize: 14,
                            //                                   //   color: Color(0xFF11528f),
                            //                                   // ),
                            //                                 ),
                            //                                 const SizedBox(width: 5),
                            //                                 SvgPicture.asset(
                            //                                   'assets/squareupright.svg',
                            //                                   width: 12.0,
                            //                                   height: 12.0,
                            //                                   color: const Color(
                            //                                       0xFF11528f),
                            //                                 ),
                            //                               ],
                            //                             ),
                            //                           ),
                            //                         ))
                            //                   ],
                            //                 )));
                            //       }
                            //     },
                            //   ),
                            // )
                            // //),
                          ))
                    ],
                  ),
                  // ),
                ],
              ))),
    );
  }

  //   Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
  //   child: IntrinsicHeight(
  //     child: Container(
  //         decoration: BoxDecoration(
  //           color: Color(0xFFf3e7bc), // Set your desired background color here
  //           borderRadius: BorderRadius.circular(15.0), // Match this with the border radius of the image
  //         ),
  //         child: GestureDetector(
  //             onTap: () {
  //               Branch branchData = Branch(
  //                 branchId: branch.id!,
  //                 branchname: branch.name,
  //                 branchaddress: branch.address,
  //                 phonenumber: branch.mobileNumber,
  //                 branchImage: branch.imageName!,
  //                 latitude: branch.latitude,
  //                 longitude: branch.longitude,
  //               );
  //
  //               widget.toNavigate(branchData);
  //             },
  //             child: Stack(
  //               alignment: Alignment.topRight,
  //               children: <Widget>[
  //                 Container(
  //                   width: MediaQuery.of(context).size.width,
  //
  //                   height: MediaQuery.of(context).size.height / 28,
  //                   padding: EdgeInsets.only(right: 20),
  //                   color: Colors.white,
  //                 ),
  //                 Container(
  //                   width: 75,
  //                   height: 60,
  //                   decoration: BoxDecoration(
  //                     border: Border.all(
  //                       color: Colors.white,
  //                       width: 2.5,
  //                     ),
  //                     borderRadius: BorderRadius.circular(15.0),
  //                   ),
  //                   //padding: EdgeInsets.symmetric(horizontal: 8),
  //                   margin: EdgeInsets.only(right: 10.0),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(15.0),
  //                     child: Image.network(
  //                       branch.imageName!,
  //                       width: 110,
  //                       height: 70,
  //                       fit: BoxFit.fill,
  //                       loadingBuilder: (context, child, loadingProgress) {
  //                         if (loadingProgress == null) return child;
  //
  //                         return Center(child: CircularProgressIndicator.adaptive());
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                  // height: 60,
  //                   padding: EdgeInsets.only(top: 40.0 / 2.0,right: 10.0, left: 10),
  //
  //                   decoration: BoxDecoration(
  //                     // color: Colors.grey[200], // Set your desired background color here
  //                     borderRadius: BorderRadius.circular(15.0), // Match this with the border radius of the image
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       // Text(branch.name, style: CommonStyles.txSty_18b_fb),
  //                       Expanded(
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                             // color: Colors.grey[200], // Set your desired background color here
  //                             borderRadius: BorderRadius.circular(10.0), // Match this with the border radius of the image
  //                           ),
  //                           padding:  EdgeInsets.only(right: 10.0, left: 0,top: 10.0),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Text(branch.name, style: CommonStyles.txSty_18b_fb),
  //                               // Row(
  //                               //  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                               //   children: [
  //                               //     Expanded(
  //                               //       child: Text(branch.name, style: CommonStyles.txSty_18b_fb),
  //                               //     ),
  //                               //   ],
  //                               // ),
  //                               //const Spacer(flex: 3),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //
  //                       Expanded(
  //                         child: Padding(
  //                           padding:  EdgeInsets.only(right: 10.0, bottom: 10.0, left: 0),
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                                 children: [
  //                                   Expanded(
  //                                     child: Text(branch.address, style: CommonStyles.txSty_12b_fb),
  //                                   ),
  //                                 ],
  //                               ),
  //                               //  const Spacer(flex: 3),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   // Some content
  //                 ),
  //
  //
  //
  //               ],
  //             ))),
  //   ),
  // );
  Widget buildIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == currentIndex ? Colors.orange : Colors.grey,
      ),
    );
  }
}

class SlowScrollPhysics extends ScrollPhysics {
  const SlowScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get maxFlingVelocity => super.maxFlingVelocity * 0.2;

  @override
  double get minFlingVelocity => super.minFlingVelocity * 0.2;

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity.abs() >= minFlingVelocity)) {
      return super.createBallisticSimulation(position, velocity * 0.1);
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

class BranchCard extends StatelessWidget {
  final Model_branch branch;

  const BranchCard({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 5.0),
        color: Colors.white,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CommonStyles.branchBg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Image.network(
                        branch.imageName,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: CommonStyles.branchBg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                branch.branchName,
                                style: CommonStyles.txSty_16p_fb.copyWith(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                openMap(branch);
                              },
                              child: SvgPicture.asset(
                                'assets/map_marker.svg',
                                width: 20,
                                height: 20,
                                color: CommonStyles.statusGreenText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Expanded(
                          child: Text(
                            branch.address,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: CommonStyles.txSty_12b_f5.copyWith(
                              fontSize: 16,
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
        ));
  }

  Future<void> openMap(Model_branch branchnames) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${branchnames.latitude},${branchnames.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ItemBuilder extends StatelessWidget {
  const ItemBuilder({
    super.key,
    required this.items,
    required this.index,
  });

  final List<Item> items;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      height: 180,
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            items[index].imageName,
            height: 100,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return const Center(child: CircularProgressIndicator.adaptive());
            },
          ),
        ),
      ),
    );
  }
}

class Item {
  final String name;
  final Color color;
  final String imageName;

  Item(this.name, this.color, this.imageName);

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      json['name'] as String,
      Colors.blue,
      json['imageName'] as String? ?? '',
    );
  }
}
