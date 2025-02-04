import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/MyProductsProvider.dart';
import 'package:hairfixingzone/Product_Model.dart';
import 'package:hairfixingzone/slotbookingscreen.dart';

// import 'package:hrms/api%20config.dart';
// import 'package:hrms/home_screen.dart';
// import 'package:hrms/personal_details.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'Commonutils.dart';
import 'CustomRadioButton.dart';
// import 'LatestAppointment.dart';
import 'MyAppointment_Model.dart';
import 'ProductCategory.dart';
import 'api_config.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  MyProducts_screenState createState() => MyProducts_screenState();
}

class MyProducts_screenState extends State<MyProducts> {
  bool isLoading = true;
  List<Product_Model> products_List = [];
  late Future<List<ProductList>> apiData;

  List<RadioButtonOption> options = [];
  int? gender;
  int? categoryid;
  bool isGenderSelected = false;
  List<ProductCategory> products = [];
  late Future<List<ProductCategory>> proCatogary;
  ProductCategory? selectedCategory;

  final orangeColor = const Color(0xFFe78337);
  bool isOpVisited = true;

  @override
  void initState() {
    super.initState();
    initializeData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    CommonUtils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');

        // initializeData();
        fetchRadioButtonOptions();
        proCatogary = fetchProductsCategory();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  void initializeData() {
    fetchproducts().then((data) {
      myProductProvider.getProProducts = data;
    }).catchError((error) {
      print('catchError: Error occurred.');
    });
    apiData = fetchproducts();
  }

  late MyProductProvider myProductProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    myProductProvider = Provider.of<MyProductProvider>(context);

    if (isOpVisited) {
      myProductProvider.clearFilter();
    }
    print('xxx: isOpVisited did: $isOpVisited');
    isOpVisited = false;
  }

  Future<void> fetchRadioButtonOptions() async {
    final url = Uri.parse(baseUrl + getgender);
    print('url==>946: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData != null &&
            responseData['listResult'] is List<dynamic>) {
          final List<dynamic> optionsData = responseData['listResult'];
          setState(() {
            options = optionsData
                .map((data) => RadioButtonOption.fromJson(data))
                .toList();
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

  Future<List<ProductCategory>> fetchProductsCategory() async {
    final response = await http.get(Uri.parse('$baseUrl$getproductsbyid/6'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['listResult'];
      List<ProductCategory> result =
          responseData.map((json) => ProductCategory.fromJson(json)).toList();
      print('fetchProductsCategory: ${result[0].desc}');
      return result;
    } else {
      throw Exception('Failed to load products');
    }
  }

  void refreshTheScreen() {
    CommonUtils.checkInternetConnectivity().then(
      (isConnected) {
        if (isConnected) {
          try {
            initializeData();
          } catch (e) {
            print('catch: $e');
            rethrow;
          }
        } else {
          CommonUtils.showCustomToastMessageLong(
              'Please Check Your Internet Connection', context, 1, 4);
          print('The Internet Is not  Connected');
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
      child: Consumer<MyProductProvider>(
        builder: (context, provider, _) => Scaffold(
          backgroundColor: CommonStyles.whiteColor,
          body: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                // search and filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0)
                      .copyWith(top: 10),
                  child: _searchBarAndFilter(),
                ),

                // products
                Expanded(
                  child: Consumer<MyProductProvider>(
                    builder: (context, provider, _) => FutureBuilder(
                      future: apiData,  // Ensure this future is initialized properly
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'No Products',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Outfit",
                              ),
                            ),
                          );
                        } else {
                          List<ProductList>? data = provider.getProProducts;
                          if (data != null && data.isNotEmpty) {
                            return ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return ProductCard(product: data[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No Products Found',
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
                )

                // Expanded(
                //   child: Consumer<MyProductProvider>(
                //     builder: (context, provider, _) => FutureBuilder(
                //       future: apiData,
                //       builder: (context, snapshot) {
                //         if (snapshot.connectionState ==
                //             ConnectionState.waiting) {
                //           return const Center(
                //             child: CircularProgressIndicator.adaptive(),
                //           );
                //         } else if (snapshot.hasError) {
                //           return Center(
                //             child: Text(
                //               'No Products',
                //               style: const TextStyle(
                //                 fontSize: 12.0,
                //                 color: Colors.black,
                //                 fontWeight: FontWeight.bold,
                //                 fontFamily: "Outfit",
                //               ),
                //             ),
                //           );
                //         } else {
                //           List<ProductList>? data = provider.getProProducts;
                //           if (provider.getProProducts.isNotEmpty) {
                //             return ListView.builder(
                //               itemCount: data.length,
                //               itemBuilder: (context, index) {
                //                 return ProductCard(product: data[index]);
                //               },
                //             );
                //           } else {
                //             return const Center(
                //               child: Text(
                //                 'No Products Found',
                //                 style: TextStyle(
                //                   fontSize: 12.0,
                //                   color: Colors.black,
                //                   fontWeight: FontWeight.bold,
                //                   fontFamily: "Outfit",
                //                 ),
                //               ),
                //             );
                //           }
                //         }
                //       },
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ProductList>> fetchproducts(
      {int? id, int? categoryTypeId, int? genderTypeId}) async {
    // final apiurl = 'http://182.18.157.215/SaloonApp/API/GetProductById';
    final apiurl = baseUrl + getproductsbyid;

    try {
      final request = {
        "id": id,
        "categoryTypeId": categoryTypeId,
        "genderTypeId": genderTypeId,
        "isActive": true
      };
      final response = await http.post(
        Uri.parse(apiurl),
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('api: ${json.encode(request)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['listResult'] != null) {
          List<dynamic> list = data['listResult'];
          List<ProductList> result =
              list.map((item) => ProductList.fromJson(item)).toList();
          return result;
        } else {
          print('listResult is null');
          throw Exception('else: listResult is null');
          return [];
        }
        // myProductProvider.proProducts = productlist;
      } else {
        print('api failed');
        throw Exception('else: api failed');
      }
    } catch (error) {
      print('Error data is not getting from the api: $error');
      throw Exception('catch: $error');
    }
  }

  Widget _searchBarAndFilter() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 5.0, right: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextField(
                onChanged: (input) => filterProducts(input),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),

                  hintText: 'Search Products',
                  // hintStyle: CommonStyles.txSty_14bs_fb,
                  // suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: CommonUtils.primaryTextColor),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF0f75bc),
                    ),
                    borderRadius: BorderRadius.circular(10.0),
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
              color: myProductProvider.filterStatus
                  ? const Color.fromARGB(255, 171, 111, 211)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CommonUtils.primaryTextColor,
              ),
            ),
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/filter.svg', // Path to your SVG asset
                color: myProductProvider.filterStatus
                    ? Colors.black
                    : const Color(0xFF662e91),
                width: 24, // Adjust width as needed
                height: 24, // Adjust height as needed
              ),
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const FilterBottomSheet(),
                  ),
                );
                // Add logout functionality here
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterProducts(String input) {
    apiData.then((data) {
      setState(() {
        myProductProvider.storeIntoProvider(data
            .where(
                (item) => item.name.toLowerCase().contains(input.toLowerCase()))
            .toList());
      });
    });
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<RadioButtonOption> options = [];

  bool isGenderSelected = false;
  List<ProductCategory> products = [];
  late Future<List<ProductCategory>> proCatogary;
  ProductCategory? selectedCategory;

  final orangeColor = CommonUtils.primaryTextColor;
  late Future<List<ProductList>> apiData;

  @override
  void initState() {
    // Initialize state
    super.initState();
    fetchRadioButtonOptions();
    proCatogary = fetchProductsCategory();
  }

  Future<void> filterProducts() async {
    apiData = fetchproducts(
        genderTypeId: myProductProvider.getGender,
        categoryTypeId: myProductProvider.getCategory);
    apiData.then((data) {
      myProductProvider.getProProducts = data;
      // Navigator.of(context).pop();
    }).catchError((error) {
      print('catchError:$error');
    });
  }

  Future<void> clearFilter() async {
    apiData = fetchproducts();
    apiData.then((data) {
      myProductProvider.getProProducts = data;
      // myProductProvider.clearFilter();
      // Navigator.of(context).pop();
    }).catchError((error) {
      print('catchError: Error occurred.');
    });
  }

  late MyProductProvider myProductProvider;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    myProductProvider = Provider.of<MyProductProvider>(context);
  }

  Future<List<ProductList>> fetchproducts(
      {int? id, int? categoryTypeId, int? genderTypeId}) async {
    final apiurl = baseUrl + getproductsbyid;
    print('apiurl$apiurl');
    try {
      final request = {
        "id": id,
        "categoryTypeId": categoryTypeId,
        "genderTypeId": genderTypeId,
        "isActive": true
      };
      final response = await http.post(
        Uri.parse(apiurl),
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('fetchproducts: ${json.encode(request)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['listResult'] != null) {
          List<dynamic> list = data['listResult'];
          List<ProductList> result =
              list.map((item) => ProductList.fromJson(item)).toList();
          return result;
        } else {
          print('listResult is null');
          return [];
        }
        // myProductProvider.proProducts = productlist;
      } else {
        print('api failed');
        throw Exception('else: api failed');
      }
    } catch (error) {
      print('Error data is not getting from the api: $error');
      throw Exception('catch: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyProductProvider>(
      builder: (context, provider, _) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Filter By',
                    style: CommonUtils.Mediumtext_o_14,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Clear filters
                      myProductProvider.clearFilter();
                      clearFilter().whenComplete(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: const Text(
                      'Clear All Filters',
                      style: CommonUtils.Mediumtext_o_14,
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 0.3,
                color: CommonUtils.primaryTextColor,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // radio buttons
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        children: options.map((option) {
                          return Row(
                            children: [
                              CustomRadioButton(
                                selected:
                                    provider.selectedGender == option.typeCdId,
                                onTap: () {
                                  setState(() {
                                    provider.getGender = option.typeCdId;
                                    provider.selectedGender = option.typeCdId!;

                                    isGenderSelected = true;
                                  });
                                  print(option.typeCdId);
                                  print(option.desc);
                                  print('filter: ${provider.getGender}');
                                },
                              ),
                              const SizedBox(width: 5),
                              Text(
                                option.desc,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  color: CommonUtils.primaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 26),
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // category
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: FutureBuilder(
                          future: proCatogary,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.transparent,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(orangeColor),
                              );
                            } else if (snapshot.hasError) {
                              return Text('No Products');
                            } else {
                              List<ProductCategory> data = snapshot.data!;
                              return SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: data.length + 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    bool isSelected =
                                        index == provider.selectedCategory;
                                    ProductCategory productCategory;

                                    if (index == 0) {
                                      productCategory = ProductCategory(
                                        typecdid: null,
                                        desc: 'All',
                                      );
                                    } else {
                                      productCategory = data[index - 1];
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          provider.selectedCategory = index;

                                          provider.getCategory =
                                              productCategory.typecdid;
                                          print(
                                              'filter: ${provider.getCategory}');
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
                                                        horizontal: 10.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      productCategory.desc
                                                          .toString(),
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Row(
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
                              Radius.circular(10),
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
                              filterProducts().whenComplete(() {
                                Navigator.of(context).pop();
                                provider.filterStatus = true;
                              });
                            },
                            child: Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchRadioButtonOptions() async {
    final url = Uri.parse(baseUrl + getgender);
    print('url==>946: $url');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData != null &&
            responseData['listResult'] is List<dynamic>) {
          final List<dynamic> optionsData = responseData['listResult'];
          setState(() {
            options = optionsData
                .map((data) => RadioButtonOption.fromJson(data))
                .toList();
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

  Future<List<ProductCategory>> fetchProductsCategory() async {
    final response = await http.get(Uri.parse('$baseUrl$getproducts/6'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(response.body)['listResult'];
      List<ProductCategory> result =
          responseData.map((json) => ProductCategory.fromJson(json)).toList();
      print('fetchProductsCategory: ${result[0].desc}');
      return result;
    } else {
      throw Exception('Failed to load products');
    }
  }
}

class ProductCard extends StatelessWidget {
  final ProductList product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
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
            width:
            1.0, // Set the border width
          ),
          borderRadius: BorderRadius.circular(
              10.0), // Optional: Add border radius if needed
        ),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(10.0),
        //   boxShadow: [
        //     BoxShadow(
        //       color: const Color.fromARGB(255, 193, 193, 194)
        //           .withOpacity(0.2), // Shadow color
        //       spreadRadius: 2, // Spread radius
        //       blurRadius: 4, // Blur radius
        //       offset: const Offset(0, 2), // Shadow position
        //     ),
        //   ],
        // ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.height / 10,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CommonUtils.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        showZoomedAttachments(product.imageName, context),
                    child: Image.network(product.imageName),
                  ),
                ),
                if (product.bestseller == true)
                  Positioned(
                    top: -8,
                    left: -10,
                    child: SvgPicture.asset(
                      'assets/bs_v5.svg',
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
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    "${product.name} (${product.code}) ",
                    style: CommonUtils.txSty_18p_f7,
                  ),
                ),
                const SizedBox(height: 8), // Add space here
                Text(
                  product.categoryName,
                  style: CommonUtils.txSty_12bs_fb,
                ),
                const SizedBox(height: 8), // Add space here
                Text(
                  product.gender ?? ' ',
                  style: CommonUtils.txSty_12bs_fb,
                ),
                const SizedBox(height: 8), // Add space here

                if(product.maxPrice != null)
                Text(
                  '₹ ${formatNumber(product.maxPrice! )}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Outfit",
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Color(0xFF662d91),
                  ),
                ),
              ],
            ),
          ],
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
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
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
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
}
