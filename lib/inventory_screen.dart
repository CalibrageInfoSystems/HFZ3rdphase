import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hairfixingzone/BranchModel.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/Common/custome_form_field.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:http/http.dart' as http;

class InventoryScreen extends StatefulWidget {
  final int userId;
  const InventoryScreen({super.key, required this.userId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int? selectedBranchId = -1;
  int? selectedColorId = -1;
  bool isGenderSelected = false;

  List<Map<String, String>> dropdownForBranch = [
    {'id': '0', 'desc': 'Google'},
    {'id': '1', 'desc': 'Apple'},
    {'id': '2', 'desc': 'Microsoft'},
  ];

  List<Map<String, String>> dropdownForColor = [
    {'id': '0', 'desc': 'Red'},
    {'id': '1', 'desc': 'Blue'},
    {'id': '2', 'desc': 'Green'},
    {'id': '3', 'desc': 'Yellow'},
    {'id': '4', 'desc': 'Purple'},
  ];

  late Future<List<BranchModel>> branchList;

  @override
  void initState() {
    super.initState();
    branchList = getBranchList();
  }

  Future<List<BranchModel>> getBranchList() async {
    try {
      final apiUrl = '$baseUrl$GetBranchByUserId${widget.userId}/null';
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        List<dynamic> branchList = jsonDecode(jsonResponse.body)['listResult'];
        if (branchList.isEmpty) {
          return throw Exception('No branch found');
        }
        return branchList.map((e) => BranchModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load branches');
    } catch (e) {
      print('Catch: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              branchName(context),
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
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      buttonText: 'Add Inventory',
                      color: CommonUtils.primaryTextColor,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column procustColor(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Product Color ',
              style: CommonUtils.txSty_12b_fb,
            ),
            Text(
              '*',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0, top: 0.0, right: 0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: isGenderSelected
                    ? const Color.fromARGB(255, 175, 15, 4)
                    : CommonUtils.primaryTextColor,
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<int>(
                    value: selectedColorId,
                    iconSize: 30,
                    icon: null,
                    style: CommonUtils.txSty_12b_fb,
                    onChanged: (value) {
                      if (value != -1) {
                        setState(() {
                          selectedColorId = value;
                        });
                      }
                    },
                    items: [
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text(
                          'Select Color',
                          style: CommonStyles.texthintstyle,
                        ),
                      ),
                      ...dropdownForColor.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            item['desc']!,
                            style: CommonUtils.txSty_12b_fb,
                          ),
                        );
                      }).toList(),
                    ]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  CustomeFormField quantityField() {
    return CustomeFormField(
      //MARK: Quantity
      label: 'Product Quantity',
      // validator: validatefullname,
      // controller: fullNameController,
      // maxLength: 50,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // errorText:
      // _fullNameError ? _fullNameErrorMsg : null,
      onChanged: (value) {},
    );
  }

  CustomeFormField productfield() {
    return CustomeFormField(
      //MARK: Product Name
      label: 'Product Name',
      // validator: validatefullname,
      // controller: fullNameController,
      maxLength: 50,
      keyboardType: TextInputType.name,
      // errorText:
      // _fullNameError ? _fullNameErrorMsg : null,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Column branchName(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Branch Name ',
              style: CommonUtils.txSty_12b_fb,
            ),
            Text(
              '*',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(
              color: isGenderSelected
                  ? const Color.fromARGB(255, 175, 15, 4)
                  : CommonUtils.primaryTextColor,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: FutureBuilder(
              future: branchList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.all(13),
                    child: Text('Loading Branches'),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(13),
                    child: Text(snapshot.error
                        .toString()
                        .replaceAll('Exception: ', '')),
                  );
                }
                final List<BranchModel> branchList =
                    snapshot.data as List<BranchModel>;
                return DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<int>(
                        value: selectedBranchId,
                        iconSize: 30,
                        icon: null,
                        style: CommonUtils.txSty_12b_fb,
                        onChanged: (value) {
                          if (value != -1) {
                            setState(() {
                              selectedBranchId = value;
                            });
                          }
                        },
                        items: [
                          const DropdownMenuItem<int>(
                            value: -1,
                            child: Text(
                              'Select Branch',
                              style: CommonStyles.texthintstyle,
                            ),
                          ),
                          ...branchList.map((branch) {
                            return DropdownMenuItem<int>(
                              value: branch.id,
                              child: Text(
                                branch.name,
                                style: CommonUtils.txSty_12b_fb,
                              ),
                            );
                          }).toList()
                          /*  ...dropdownForBranch.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return DropdownMenuItem<int>(
                                    value: index,
                                    child: Text(
                                      item['desc']!,
                                      style: CommonUtils.txSty_12b_fb,
                                    ),
                                  );
                                }).toList(), */
                        ]),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
