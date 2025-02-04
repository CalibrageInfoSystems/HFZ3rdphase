import 'dart:convert';
import 'package:hairfixingzone/View_products_Model.dart';
import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Product_Model.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'CommonUtils.dart';
import 'HomeScreen.dart';

class FavouritesScreen extends StatefulWidget {
  @override
  _MyFavouritesScreenscreenState createState() => _MyFavouritesScreenscreenState();
}

class _MyFavouritesScreenscreenState extends State<FavouritesScreen> {
  List<ViewProduct> viewproductslist = [];
  int Id = 0;

  @override
  void initState() {
    // TODO: implement initState.

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');

        setState(() {
          getUserDataFromSharedPreferences();
          // initializeData();
        });
      } else {
        print('The Internet Is not  Connected');
      }
    });

    super.initState();
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Id = prefs.getInt('userId') ?? 0;
      viewfavoriteproduct(Id);
    });
  }

  Future<List<ViewProduct>> viewfavoriteproduct(int customerid) async {
    final url = Uri.parse(baseUrl + Viewfavourites + "/${customerid}");
    print('urlviewfavourites: $url');

    print('customerid$customerid');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> productList = data['listResult'];

        // Convert the list of dynamic data to a list of ViewProduct
        return productList.map((item) => ViewProduct.fromJson(item)).toList();
      } else {
        return [];
        print('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // ProgressManager.stopProgress();
      print('Error slot: $e');
      return [];
    }
  }

  Future<bool> onBackPressed(BuildContext context) {
    // Navigate back when the back button is pressed
    Navigator.pop(context);
    // Return false to indicate that we handled the back button press
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => onBackPressed(context),
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color(0xffe2f0fd),
              title: const Text(
                'Favourites',
                style: TextStyle(color: Color(0xFF0f75bc), fontSize: 16.0, fontFamily: "Outfit", fontWeight: FontWeight.w600),
              ),
              titleSpacing: 0.0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: CommonUtils.primaryTextColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Container(
                color: Colors.white,
                child: FutureBuilder<List<ViewProduct>>(
                  future: viewfavoriteproduct(Id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While waiting for the data
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // If there is an error
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      // If data is available but empty
                      return Container(color: Colors.white, child: Center(child: errorMessage()));
                    } else if (snapshot.hasData) {
                      // If data is available
                      final viewproductslist = snapshot.data!;
                      return ListView.builder(
                        itemCount: viewproductslist.length,
                        itemBuilder: (context, index) {
                          final data = viewproductslist[index];
                          return ProductCard(
                            product: data,
                            customerid: Id, // Replace with actual customer ID
                          );
                        },
                      );
                    } else {
                      // Fallback for unexpected cases
                      return Center(child: errorMessage());
                    }
                  },
                ))));
  }

  Widget errorMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/favoritesvgrepo.svg',
          width: 24,
          height: 24,
        ),

        const SizedBox(height: 10),
        const Text('No favourites', style: CommonStyles.txSty_20black_fb),
        const SizedBox(height: 5),
        const Text('Your favourites list is empty, Let\'s fill it up!', style: CommonStyles.txSty_16black_f5),
        const SizedBox(height: 8),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     // backgroundColor: CommonStyles.primaryTextColor,
        //     padding: const EdgeInsets.all(10),
        //     shape: RoundedRectangleBorder(
        //       side: const BorderSide(color: Colors.black),
        //       borderRadius: BorderRadius.circular(20.0),
        //     ),
        //     // shape: const StadiumBorder(),
        //   ),
        //   onPressed: () {},
        //   child: const Text(
        //     'Start searching',
        //     style: TextStyle(color: Colors.black),
        //   ),
        // )
      ],
    );
  }
}

class ProductCard extends StatefulWidget {
  final ViewProduct product;
  final int customerid;

  ProductCard({super.key, required this.product, required this.customerid});

  @override
  _MyProducts_screenState createState() => _MyProducts_screenState();
}

class _MyProducts_screenState extends State<ProductCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      //   shadowColor: CommonUtils.primaryColor, // Set the shadow color here
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: const Color(0xFF960efd).withOpacity(0.2), // Shadow color
            //     spreadRadius: 2, // Spread radius
            //     blurRadius: 4, // Blur radius
            //     offset: const Offset(0, 2), // Shadow position
            //   ),
            // ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.height / 10,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xffe2f0fd),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GestureDetector(
                      onTap: () => showZoomedAttachments(widget.product.imageName, context),
                      child: Image.network(widget.product.imageName),
                    ),
                  ),
                  if (widget.product.bestSeller == true)
                    Positioned(
                      top: -8,
                      left: -10,
                      child: SvgPicture.asset(
                        'assets/bs_v3.svg',
                        width: 80.0,
                        height: 35.0,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${widget.product.name} (${widget.product.code}) ",
                            style: CommonUtils.txSty_18p_f7,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('product${widget.product.id}');
                            print('customerid${widget.customerid}');
                            addfavoriteproduct(widget.product.id, widget.customerid);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Card(
                              //   shape: CircleBorder(), // Make the card circular
                              //   child: CircleAvatar(
                              //     radius: 14, // Adjust the size of the circle
                              //     backgroundColor: Colors.white, // Set background color for the circle
                              //     child: DecoratedIcon(
                              //       icon: Icon(
                              //         Icons.favorite,
                              //         color: Colors.red, // Change color based on favorited status
                              //         size: 18,
                              //       ),
                              //       decoration: IconDecoration(border: IconBorder(color: Colors.red, width: 1.5)),
                              //     ),
                              //   ),
                              // ),
                              Card(
                                shape: CircleBorder(), // Make the card circular
                                child: CircleAvatar(
                                  radius: 14, // Adjust the size of the circle
                                  backgroundColor: Colors.white, // Set background color for the circle
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.transparent, width: 1.5), // Add the border
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/favoritesvgrepo.svg', // Add your SVG file here
                                      width: 18, // Adjust the width as needed
                                      height: 18, // Adjust the height as needed
                                    ),
                                  ),
                                ),
                              ),

                              if (_isLoading)
                                Positioned(
                                  child: CircularProgressIndicator.adaptive(), // Show loading indicator
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4), // Add space here
                  Text(
                    widget.product.categoryName,
                    style: CommonUtils.txSty_12bs_fb,
                  ),
                  const SizedBox(height: 4), // Add space here
                  Text(
                    widget.product.gender ?? ' ',
                    style: CommonStyles.txSty_14b_fb,
                  ),
                  const SizedBox(height: 4), // Add space here
                  if (widget.product.minPrice != null)
                    Row(
                      children: [
                        Text(
                          '₹ ${formatNumber(widget.product.minPrice!)} ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: "Outfit",
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          ' On wards',
                          style: CommonStyles.texthintstyle,
                        ),
                      ],
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatNumber(double number) {
    NumberFormat formatter = NumberFormat("#,##,##,##,##,##,##0.00", "en_US");
    return formatter.format(number);
  }

  void showZoomedAttachments(String imageString, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
            width: double.infinity,
            height: 500,
            child: Stack(
              children: [
                Center(
                  child: PhotoViewGallery.builder(
                    itemCount: 1,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(imageString),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollDirection: Axis.vertical,
                    scrollPhysics: const PageScrollPhysics(),
                    allowImplicitScrolling: true,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addfavoriteproduct(int productid, int customerid) async {
    final url = Uri.parse(baseUrl + Addfavourites);
    print('urlAddfavourites: $url');

    final request = {"customerId": customerid, "productId": productid};

    print('Addfavouritesreqobject: ${json.encode(request)}');
    try {
      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _isLoading = false;
        });
        print('data$data');
        showCustomToastMessageLong(data['statusMessage'], context, 0, 4);
       // showCustomToastMessageLong('Successfully Removed from Favorites', context, 0, 4);
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => FavouritesScreen()),
        //       (Route<dynamic> route) => false, // Removes all previous routes
        // );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavouritesScreen()),
        );


      } else {
        setState(() {
          _isLoading = false;
        });
        showCustomToastMessageLong('Please Try Again', context, 1, 4);
        print('Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // ProgressManager.stopProgress();
      print('Error slot: $e');
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
}
