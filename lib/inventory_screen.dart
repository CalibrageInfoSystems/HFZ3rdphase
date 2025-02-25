import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/common_widgets.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/add_inventory.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/models/inventory_model.dart';
import 'package:http/http.dart' as http;

class InventoryScreen extends StatefulWidget {
  final int userId;
  final int branchId;
  final String branchName;
  final String branchImage;
  final String branchNumber;
  final String branchAddress;
  final int? toTheSegment;
  const InventoryScreen({
    super.key,
    required this.userId,
    required this.branchId,
    required this.branchName,
    required this.branchImage,
    required this.branchNumber,
    required this.branchAddress,
    this.toTheSegment,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int? _selectedSegment = 0;
  late Future<List<InventoryModel>> futureinvetories;

  @override
  void initState() {
    super.initState();
    _selectedSegment = widget.toTheSegment ?? 0;
    futureinvetories = getInventories();
  }

  @override
  void didUpdateWidget(covariant InventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toTheSegment != null &&
        widget.toTheSegment != _selectedSegment) {
      setState(() {
        _selectedSegment = widget.toTheSegment;
      });
      print('CustomersView (didUpdateWidget): $_selectedSegment');
    }
  }

  FutureBuilder<List<InventoryModel>> inventoryTab() {
    return FutureBuilder(
      future: futureinvetories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              textAlign: TextAlign.center,
              snapshot.error.toString().replaceFirst('Exception: ', ''),
            ),
          );
        }
        final data = snapshot.data as List<InventoryModel>;
        final activeData =
            data.where((inventory) => inventory.isActive == true).toList();
        if (activeData.isEmpty) {
          return const Center(
            child: Text(
              textAlign: TextAlign.center,
              'No Inventory Found',
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(14),
          child: ListView.separated(
            itemCount: activeData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return invertoryTemplate(context, activeData[index]);
            },
          ),
        );
      },
    );
  }

  IntrinsicHeight invertoryTemplate(
      BuildContext context, InventoryModel inventory) {
    return IntrinsicHeight(
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          // inventory.isActive! ? const Color(0xFFFFFFFF) : Colors.grey[300],
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${inventory.productName}',
                      style: TextStyle(
                        color: inventory.isActive!
                            ? const Color(0xFF0f75bc)
                            : Colors.grey.shade400,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    (inventory.color != null)
                        ? Text(
                            '${inventory.color} - ${inventory.quantity}',
                            style: CommonStyles.txSty_12b_f5.copyWith(
                              color: inventory.isActive!
                                  ? CommonStyles.blackColor
                                  : Colors.grey.shade400,
                            ),
                          )
                        : Text(
                            '${inventory.quantity}',
                            style: CommonStyles.txSty_12b_f5.copyWith(
                              color: inventory.isActive!
                                  ? CommonStyles.blackColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                    if (inventory.desc != null && inventory.desc!.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            '${inventory.desc}',
                            style: CommonStyles.txSty_12b_f5.copyWith(
                              color: inventory.isActive!
                                  ? CommonStyles.blackColor
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            /*   Column(
              children: [
                if (inventory.isActive!)
                  IconButton(
                    onPressed: () {
                      CommonWidgets.customCancelDialog(
                        context,
                        message:
                            'Are You Sure You Want to Delete ${inventory.productName}?',
                        onConfirm: () {
                          deleteInventory(inventory).whenComplete(() {
                            setState(() {
                              futureinvetories = getInventories();
                            });
                          });
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          userId: widget.userId,
                          branchId: widget.branchId,
                          inventory: inventory,
                          branchName: widget.branchName,
                          branchImage: widget.branchImage,
                          branchNumber: widget.branchNumber,
                          branchAddress: widget.branchAddress,
                          isUpdate: true,
                          isActive: inventory.isActive,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
           */
            inventory.isActive!
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updateInventory =
                              await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddInventory(
                                userId: widget.userId,
                                branchId: widget.branchId,
                                inventory: inventory,
                                branchName: widget.branchName,
                                branchImage: widget.branchImage,
                                branchNumber: widget.branchNumber,
                                branchAddress: widget.branchAddress,
                                isUpdate: true,
                                isActive: inventory.isActive,
                              ),
                            ),
                          );
                          if (updateInventory) {
                            setState(() {
                              futureinvetories = getInventories();
                            });
                          }
                        } else if (value == 'delete') {
                          CommonWidgets.customCancelDialog(
                            context,
                            message:
                                'Are You Sure You Want to Delete ${inventory.productName}?',
                            onConfirm: () {
                              deleteInventory(inventory).whenComplete(() {
                                setState(() {
                                  futureinvetories = getInventories();
                                });
                              });
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert),
                    ),
                  )
                : IconButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddInventory(
                            userId: widget.userId,
                            branchId: widget.branchId,
                            inventory: inventory,
                            branchName: widget.branchName,
                            branchImage: widget.branchImage,
                            branchNumber: widget.branchNumber,
                            branchAddress: widget.branchAddress,
                            isUpdate: true,
                            isActive: inventory.isActive,
                          ),
                        ),
                      );
                      if (result) {
                        setState(() {
                          futureinvetories = getInventories();
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteInventory(InventoryModel inventory) async {
    try {
      final apiUrl = '$baseUrl$addUpdateInventory';
      print('ApiUrl: $apiUrl');

      final requestBody = jsonEncode({
        "id": inventory.id,
        "branchId": widget.branchId,
        "productName": inventory.productName,
        "quantity": inventory.quantity,
        "colorTypeId": inventory.colorTypeId,
        "desc": inventory.desc,
        "isActive": false,
        "createdByUserId": widget.userId,
        "createdDate": DateTime.now().toIso8601String(),
        "updatedByUserId": widget.userId,
        "updatedDate": DateTime.now().toIso8601String()
      });

      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          return CommonUtils.showCustomToastMessageLong(
              'Inventory Deleted Successfully', context, 0, 5);
        }
        CommonUtils.showCustomToastMessageLong(
            'Unable to Delete Inventory', context, 0, 5);

        throw Exception('Unable to Delete Inventory');
      }
      throw Exception('Failed to delete inventory');
    } catch (e) {
      print('Catch: $e');
      rethrow;
    }
  }

  FutureBuilder<List<InventoryModel>> deleteInventoryTab() {
    return FutureBuilder(
      future: futureinvetories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              textAlign: TextAlign.center,
              snapshot.error.toString().replaceFirst('Exception: ', ''),
            ),
          );
        }
        final data = snapshot.data as List<InventoryModel>;
        final activeData =
            data.where((inventory) => inventory.isActive != true).toList();
        return Padding(
          padding: const EdgeInsets.all(14),
          child: ListView.separated(
            itemCount: activeData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return invertoryTemplate(context, activeData[index]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _selectedSegment!,
      child: Scaffold(
        appBar: appBar(context),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: branchTemplate(context),
            ),
            const SizedBox(height: 20),
            tabBar(),
            tabBarView(),
            addInventoryBtn(context),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Padding addInventoryBtn(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              buttonText: 'Add Inventory',
              color: CommonUtils.primaryTextColor,
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddInventory(
                      userId: widget.userId,
                      branchId: widget.branchId,
                      branchName: widget.branchName,
                      branchImage: widget.branchImage,
                      branchNumber: widget.branchNumber,
                      branchAddress: widget.branchAddress,
                    ),
                  ),
                );
                if (result) {
                  setState(() {
                    futureinvetories = getInventories();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Expanded tabBarView() {
    return Expanded(
      child: TabBarView(
        children: [
          inventoryTab(),
          deleteInventoryTab(),
        ],
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffe2f0fd),
        title: const Text(
          'Inventory',
          style: TextStyle(
            color: Color(0xFF0f75bc),
            fontSize: 16.0,
            fontFamily: "Outfit",
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: CommonUtils.primaryTextColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ));
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

  Future<List<InventoryModel>> getInventories() async {
    try {
      final apiUrl =
          // 'http://182.18.157.215/SaloonApp/API/Inventory/GetInventoryByBranchId/2';
          '$baseUrl$getInventoryByBranchId${widget.branchId}';
      print('ApiUrl: $apiUrl');
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          List<dynamic>? inventories = response['listResult'];
          if (inventories == null || inventories.isEmpty) {
            return throw Exception('No inventory found');
          }
          return inventories.map((e) => InventoryModel.fromJson(e)).toList();
        }
        /* List<InventoryModel> inventories =
            inventoryModelFromJson(jsonResponse.body);
        if (inventories.isEmpty) {
          return throw Exception('No inventory found');
        }
        return inventories; */
      }
      throw Exception('Failed to load inventory');
    } catch (e) {
      print('Catch: $e');
      rethrow;
    }
  }

  IntrinsicHeight branchTemplate(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
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
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
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
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(
                    10.0), // Optional: Add border radius if needed
              ),
              child: Image.network(
                widget.branchImage.isNotEmpty
                    ? widget.branchImage
                    : 'https://example.com/placeholder-image.jpg',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height / 5.5 / 2,
                width: MediaQuery.of(context).size.width / 3.2,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/hairfixing_logo.png', // Path to your PNG placeholder image
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height / 4 / 2,
                    width: MediaQuery.of(context).size.width / 3.2,
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.branchName,
                    style: const TextStyle(
                      color: Color(0xFF0f75bc),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.branchAddress,
                    style: CommonStyles.txSty_12b_f5,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
