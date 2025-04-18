import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hairfixingzone/MyProductsProvider.dart';
import 'package:hairfixingzone/Product_Model.dart';
import 'package:hairfixingzone/slotbookingscreen.dart';
import 'package:icon_decoration/icon_decoration.dart';

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
import 'Common/common_styles.dart';
import 'Commonutils.dart';
import 'CustomRadioButton.dart';

// import 'LatestAppointment.dart';
import 'MyAppointment_Model.dart';
import 'ProductCategory.dart';
import 'api_config.dart';

class ProductsMy extends StatefulWidget {
  const ProductsMy({super.key});

  @override
  MyProducts_screenState createState() => MyProducts_screenState();
}

class MyProducts_screenState extends State<ProductsMy> {
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
  int? Id;
  final orangeColor = const Color(0xFFe78337);

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
        getUserDataFromSharedPreferences();
        // initializeData();
        fetchRadioButtonOptions();

        proCatogary = fetchProductsCategory();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  Future<void> initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Id = prefs.getInt('userId') ?? 0;
      fetchproducts(Id).then((data) {
        myProductProvider.getProProducts = data;
      }).catchError((error) {
        print('catchError: Error occurred.');
      });

      apiData = fetchproducts(Id);
    });
  }

  Future<void> getUserDataFromSharedPreferences() async {}

  late MyProductProvider myProductProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    myProductProvider = Provider.of<MyProductProvider>(context);
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

  Future<bool> onBackPressed(BuildContext context) {
    // Navigate back when the back button is pressed
    Navigator.pop(context);
    // Return false to indicate that we handled the back button press
    return Future.value(false);
  }

  /*  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: DefaultTabController(
        length: 2,
        child: Consumer<MyProductProvider>(
          builder: (context, provider, _) => Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xffe2f0fd),
              title: const Text(
                'My Products',
                style: TextStyle(
                  color: Color(0xFF0f75bc),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              titleSpacing: 0.0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: CommonUtils.primaryTextColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  provider.clearFilter();
                },
              ),
              bottom: TabBar(
                indicatorColor: CommonStyles.primaryTextColor,
                indicatorWeight: 4.0,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: CommonStyles.primaryTextColor,
                unselectedLabelColor: CommonStyles.blackColorShade,
                tabs: const [
                  Tab(text: 'Male'),
                  Tab(text: 'Female'),
                ],
              ),
            ),
            body: Column(
              children: [
                // Search and Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10)
                      .copyWith(top: 10),
                  child: _searchBarAndFilter(),
                ),
                // TabBarView
                Expanded(
                  child: TabBarView(
                    children: [
                      productsTemplate(), // Tab 1 content
                      Center(
                        child: const Text(
                          'Female Products will be displayed here.',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Outfit",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 */

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPressed(context),
      child: DefaultTabController(
        length: 2,
        child: Consumer<MyProductProvider>(
          builder: (context, provider, _) => Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xffe2f0fd),
              title: const Text(
                'My Products',
                style: TextStyle(
                  color: Color(0xFF0f75bc),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              titleSpacing: 0.0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: CommonUtils.primaryTextColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  provider.clearFilter();
                },
              ),
            ),
            body: Column(
              children: [
                // Search and Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10)
                      .copyWith(top: 10),
                  child: _searchBarAndFilter(),
                ),
                // TabBarView
                const TabBar(
                  indicatorColor: CommonStyles.primaryTextColor,
                  indicatorWeight: 4.0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: CommonStyles.primaryTextColor,
                  unselectedLabelColor: CommonStyles.blackColorShade,
                  tabs: [
                    Tab(text: 'Male'),
                    Tab(text: 'Female'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      productsTemplate('Male'),
                      productsTemplate('Female'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<ProductList>> fetchproducts(int? customerid,
      {int? id, int? categoryTypeId, int? genderTypeId}) async {
    final apiurl = baseUrl + getproductsbyid;
    print('API URL: $apiurl');
    try {
      final request = {
        "id": id,
        "categoryTypeId": categoryTypeId,
        "genderTypeId": genderTypeId,
        "isActive": true,
        "customerId": customerid
      };
      final response = await http.post(
        Uri.parse(apiurl),
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('API Request: ${json.encode(request)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response: $data'); // Log the entire response

        if (data['listResult'] != null) {
          List<dynamic> list = data['listResult'];
          List<ProductList> result =
              list.map((item) => ProductList.fromJson(item)).toList();
          return result;
        } else {
          print('listResult is null');
          return []; // Return an empty list instead of throwing an exception
        }
      } else {
        print('API failed with status code: ${response.statusCode}');
        throw Exception('API failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while fetching products: $error');
      throw Exception('Failed to fetch products: $error');
    }
  }

  // Future<List<ProductList>> fetchproducts(
  //     {int? id, int? categoryTypeId, int? genderTypeId}) async {
  //   final apiurl = baseUrl + getproductsbyid;
  //   print('apiurl=======: ${apiurl}');
  //   try {
  //     final request = {
  //       "id": id,
  //       "categoryTypeId": categoryTypeId,
  //       "genderTypeId": genderTypeId,
  //       "isActive": true
  //     };
  //     final response = await http.post(
  //       Uri.parse(apiurl),
  //       body: json.encode(request),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //     print('api: ${json.encode(request)}');
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['listResult'] != null) {
  //         List<dynamic> list = data['listResult'];
  //         List<ProductList> result =
  //         list.map((item) => ProductList.fromJson(item)).toList();
  //         return result;
  //       } else {
  //         print('listResult is null');
  //         throw Exception('else: listResult is null');
  //       }
  //       // myProductProvider.proProducts = productlist;
  //     } else {
  //       print('api failed');
  //       throw Exception('else: api failed');
  //     }
  //   } catch (error) {
  //     print('Error data is not getting from the api: $error');
  //     throw Exception('catch: $error');
  //   }
  // }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFf15f22),
      title: const Text(
        'Products',
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          myProductProvider.clearFilter();
          Navigator.of(context).pop();
        },
      ),
    );
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
                  hintStyle: CommonStyles.texthintstyle,
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
                color: myProductProvider.filterStatus
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
                    child: FilterBottomSheet(
                      customerid: Id!,
                    ),
                  ),
                );
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

  TabBar tabBar() {
    return const TabBar(
      indicatorColor: CommonStyles.primaryTextColor, // Underline color
      indicatorWeight: 4.0, // Thickness of the underline
      indicatorSize: TabBarIndicatorSize.tab, // Full-width indicator
      labelColor: CommonStyles.primaryTextColor, // Selected tab text color
      unselectedLabelColor:
          CommonStyles.blackColorShade, // Unselected tab text color
      tabs: [
        Tab(text: 'Inventory'),
        Tab(text: 'Deleted Inventory'),
      ],
    );
  }

  List<ProductList> filterProductsByGender(
      List<ProductList>? products, String gender) {
    if (products == null) return [];
    return products
        .where(
            (product) => product.gender?.toLowerCase() == gender.toLowerCase())
        .toList();
  }

  Widget productsTemplate(String gender) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<MyProductProvider>(
        builder: (context, provider, _) => FutureBuilder(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error.toString()}',
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
              final filteredData = filterProductsByGender(data, gender);
              if (filteredData.isNotEmpty) {
                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredData[index],
                      customerid: Id!,
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'No Products Available',
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
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final int customerid;
  FilterBottomSheet({required this.customerid});

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
      print('catchError: Error occurred.');
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

    try {
      final request = {
        "id": id,
        "categoryTypeId": categoryTypeId,
        "genderTypeId": genderTypeId,
        "isActive": true,
        "customerId": widget.customerid
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
      builder: (context, provider, child) => SingleChildScrollView(
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
                    /*  Padding(
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
                    ), */

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
                              return Text('Error: ${snapshot.error}');
                            } else {
                              List<ProductCategory> data = snapshot.data!;
                              return SizedBox(
                                height: 38,
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
                                                        horizontal: 15.0),
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
                              filterProducts().whenComplete(() {
                                Navigator.of(context).pop();
                                provider.filterStatus = true;
                              });
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

class ProductCard extends StatefulWidget {
  final ProductList product;
  final int customerid;

  ProductCard({super.key, required this.product, required this.customerid});

  @override
  _MyProducts_screenState createState() => _MyProducts_screenState();
}

class _MyProducts_screenState extends State<ProductCard> {
  bool _isLoading = false;
  bool _isFavorited = false;

  late ScrollController _scrollController;
  double _scrollPosition = 0;

  // Save the current scroll position

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      _scrollPosition = _scrollController.position.pixels;
    });
    // TODO: implement initState
    super.initState();
  }

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
                      color: const Color(0xffe2f0fd),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GestureDetector(
                      onTap: () => showZoomedAttachments(
                          widget.product.imageName, context),
                      child: Image.network(widget.product.imageName),
                    ),
                  ),
                  if (widget.product.bestseller == true)
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
                    width: MediaQuery.of(context).size.width / 1.92,
                    // width: MediaQuery.of(context).size.width / 1.9,
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

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollController.jumpTo(_scrollPosition);
                            });
                            addfavoriteproduct(
                                widget.product.id, widget.customerid);
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
                              //         color: widget.product.farvoirte==1 ? Colors.red : Colors.white, // Change color based on favorited status
                              //         size: 18,
                              //       ),
                              //       decoration: IconDecoration(border: IconBorder(color: widget.product.farvoirte==1 ? Colors.red : Colors.black54, width: 1.5)),
                              //     ),
                              //   ),
                              // ),
                              Card(
                                shape:
                                    const CircleBorder(), // Make the card circular
                                child: CircleAvatar(
                                  radius: 14, // Adjust the size of the circle
                                  backgroundColor: Colors
                                      .white, // Set background color for the circle
                                  child: widget.product.farvoirte == 1
                                      ? SvgPicture.asset(
                                          'assets/favoritesvgrepo.svg',
                                          width: 18,
                                          height: 18,
                                        )
                                      : const DecoratedIcon(
                                          icon: Icon(
                                            Icons.favorite,
                                            color: Colors
                                                .white, // Change color based on favorited status
                                            size: 18,
                                          ),
                                          decoration: IconDecoration(
                                            border: IconBorder(
                                                color: Colors.black54,
                                                width: 1.5),
                                          ),
                                        ),
                                ),
                              ),

                              if (_isLoading)
                                const Positioned(
                                  child: CircularProgressIndicator
                                      .adaptive(), // Show loading indicator
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
                        const Text(
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
          // _isFavorited = !_isFavorited;
          _isLoading = false;
        });
        showCustomToastMessageLong(data['statusMessage'], context, 0, 4);
        //showCustomToastMessageLong('Successfully Added to Favorites', context, 0, 4);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProductsMy()),
        );
        print('data$data');
      } else {
        setState(() {
          _isLoading = false;
        });
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
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
}
