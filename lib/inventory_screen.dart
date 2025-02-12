import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
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

  const InventoryScreen({
    super.key,
    required  this.branchId,
    required this.userId,
    required this.branchName,
    required this.branchImage,
    required this.branchNumber,
    required this.branchAddress,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<InventoryModel>> futureinvetories;

  @override
  void initState() {
    super.initState();
    futureinvetories = getInventories();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(
            children: <Widget>[
              branchTemplate(context),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                    future: futureinvetories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error
                              .toString()
                              .replaceAll('Exception: ', '')),
                        );
                      }
                      final inventories = snapshot.data as List<InventoryModel>;
                      return ListView.separated(
                        itemCount: inventories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return invertoryTemplate(context, inventories[index]);
                        },
                      );
                    }),
              ),
              /*             branchName(context),
              /* if (isGenderSelected)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      child: Text('Please Select Gender',
                          style: CommonStyles.texterrorstyle),
                    ),
                  ],
                ), */
        
              const SizedBox(
                height: 10,
              ),
              productfield(),
              const SizedBox(
                height: 10,
              ),
              quantityField(),
              const SizedBox(height: 10),
              procustColor(context),
              const SizedBox(
                height: 20,
              ), */
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: 'Add Inventory',
                      color: CommonUtils.primaryTextColor,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddInventory(
                                  userId: widget.userId,
                                  branchId: widget.branchId,
                                )));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IntrinsicHeight invertoryTemplate(
      BuildContext context, InventoryModel inventory) {
    return IntrinsicHeight(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: inventory.isActive!
              ? const Color(0xFFFFFFFF)
              : Colors.red.withOpacity(0.2),
          border: Border.all(
            color: Colors.grey,
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
                      style: const TextStyle(
                        color: Color(0xFF0f75bc),
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${inventory.color} - ${inventory.quantity}',
                      style: CommonStyles.txSty_12b_f5,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${inventory.desc}',
                      style: CommonStyles.txSty_12b_f5,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                if (inventory.isActive!)
                  IconButton(
                    onPressed: () {
                      deleteInventory(inventory).whenComplete(() {
                        setState(() {
                          futureinvetories = getInventories();
                        });
                      });
                    },
                    icon: const Icon(Icons.delete),
                  ),
                // const SizedBox(height: 10),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddInventory(
                          userId: widget.userId,
                          branchId: widget.branchId,
                          inventory: inventory,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['statusMessage']),
            duration: const Duration(seconds: 2),
          ));
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response['statusMessage']),
          duration: const Duration(seconds: 2),
        ));
        throw Exception('Failed to delete inventory');
      }
      throw Exception('Failed to delete inventory');
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
