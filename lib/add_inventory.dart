import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hairfixingzone/Common/common_styles.dart';
import 'package:hairfixingzone/Common/custom_button.dart';
import 'package:hairfixingzone/Common/custome_form_field.dart';
import 'package:hairfixingzone/CommonUtils.dart';
import 'package:hairfixingzone/api_config.dart';
import 'package:hairfixingzone/models/colors_model.dart';
import 'package:hairfixingzone/models/inventory_model.dart';
import 'package:http/http.dart' as http;

class AddInventory extends StatefulWidget {
  final int userId;
  final bool? isUpdate;
  final bool? isActive;

  final InventoryModel? inventory;
  final int branchId;

  final String branchName;
  final String branchImage;
  final String branchNumber;
  final String branchAddress;

  const AddInventory({
    super.key,
    required this.userId,
    this.inventory,
    required this.branchId,
    this.isUpdate = false,
    this.isActive = true,
    required this.branchName,
    required this.branchImage,
    required this.branchNumber,
    required this.branchAddress,
  });

  @override
  State<AddInventory> createState() => _AddInventoryState();
}

class _AddInventoryState extends State<AddInventory> {
  final formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController descNameController = TextEditingController();
  int? selectedTypeCdId;
  bool isProductActive = true;
  bool isRequestProcessing = false;

  bool _productNameError = false;
  String? _productNameErrorMsg;
  bool isProductNameValidate = false;

  bool _productQuantityError = false;
  String? _productQuantityErrorMsg;
  bool isProductQuantityValidate = false;

  bool isProductColorValidate = false;

  late Future<List<ColorsModel>> futureColors;

  @override
  void initState() {
    super.initState();
    futureColors = getColors();
    print('isUpdate: ${widget.isUpdate}');

    if (widget.inventory != null) {
      productNameController.text = widget.inventory!.productName ?? '';
      quantityController.text = widget.inventory!.quantity!.toString();
      print('www: ${widget.inventory!.colorTypeId}');
      selectedTypeCdId = widget.inventory!.colorTypeId;
      isProductActive = widget.inventory!.isActive!;
      descNameController.text = widget.inventory!.desc ?? '';
    }
  }

  void validateProductColor(String? value) {
    print('validateProductColor: $value');

    setState(() {
      if (value == null || value.isEmpty) {
        isProductColorValidate = true;
      } else {
        isProductColorValidate = false;
      }
      print('validateProductColor: $isProductColorValidate');
    });
  }

  Future<void> addInventory() async {
    try {
      final apiUrl = '$baseUrl$addUpdateInventory';
      print('ApiUrl: $apiUrl');

      final requestBody = jsonEncode({
        "id": widget.inventory?.id,
        "branchId": widget.branchId,
        "productName": productNameController.text,
        "quantity": double.parse(quantityController.text),
        "colorTypeId": selectedTypeCdId,
        "desc": descNameController.text,
        "isActive": isProductActive,
        "createdByUserId": widget.userId,
        "createdDate": DateTime.now().toIso8601String(),
        "updatedByUserId": widget.userId,
        "updatedDate": DateTime.now().toIso8601String()
      }
          /* {
      'Id': widget.inventory != null ? widget.inventory!.id.toString() : '0',
      'ProductName': productNameController.text,
      'Quantity': quantityController.text,
      'BranchId': selectedBranchId.toString(),
      'ColorTypeId': selectedColorId.toString(),
      'IsActive': isProductActive.toString(),
    } */

          );
      print('requestBody: $requestBody');
      final jsonResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      setState(() {
        isRequestProcessing = false;
      });
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          /*  Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InventoryScreen(
                branchId: widget.branchId,
                userId: widget.userId,
                branchName: widget.branchName,
                branchImage: widget.branchImage,
                branchNumber: widget.branchNumber,
                branchAddress: widget.branchAddress,
                toTheSegment: !widget.isActive! ? 1 : 0,
              ),
            ),
          ); */
          Navigator.pop(context, true);
          return CommonUtils.showCustomToastMessageLong(
              response['statusMessage'], context, 0, 5);
        }

        CommonUtils.showCustomToastMessageLong(
            response['statusMessage'], context, 0, 5);

        throw Exception('Failed to add inventory');
      }
      throw Exception('Failed to add inventory');
    } catch (e) {
      setState(() {
        isRequestProcessing = false;
      });
      print('Catch: $e');
      rethrow;
    }
  }

/* 
  Future<List<BranchModel>> getBranchList() async {
    try {
      final apiUrl = '$baseUrl$GetBranchByUserId${widget.userId}/null';
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      /* if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          List<dynamic>? colors = response['listResult'];
          if (colors == null || colors.isEmpty) {
            return throw Exception('No colors found');
          }
          return colors.map((e) => BranchModel.fromJson(e)).toList();
        }
      throw Exception('No colors found');
      } */

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
 */
  Future<List<ColorsModel>> getColors() async {
    try {
      const apiUrl = 'http://182.18.157.215/SaloonApp/API/api/TypeCdDmt/8';
      final jsonResponse = await http.get(Uri.parse(apiUrl));
      if (jsonResponse.statusCode == 200) {
        final response = jsonDecode(jsonResponse.body);
        if (response['isSuccess']) {
          List<dynamic>? colors = response['listResult'];
          if (colors == null || colors.isEmpty) {
            return throw Exception('No colors found');
          }
          return colors.map((e) => ColorsModel.fromJson(e)).toList();
        }
        throw Exception('No colors found');
      }
      throw Exception('Failed to load branches');
    } catch (e) {
      print('Catch: $e');
      rethrow;
    }
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffe2f0fd),
        title: Text(
          widget.isUpdate! ? 'Update Inventory' : 'Add Inventory',
          style: const TextStyle(
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                productfield(),
                const SizedBox(height: 10),
                quantityField(),
                const SizedBox(height: 10),
                productColorName(context),
                /*  if (isProductColorValidate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        child: Text(
                          'Please Select Product Color',
                          // style: CommonStyles.texthintstyle,
                          style: CommonStyles.texthintstyle.copyWith(
                            color: const Color.fromARGB(255, 175, 15, 4),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ), */

                // procustColor(context),
                const SizedBox(height: 10),
                descriptionfield(),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    if (widget.isUpdate!) {
                      setState(() {
                        isProductActive = !isProductActive;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: isProductActive,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          activeColor: widget.isUpdate!
                              ? CommonUtils.primaryTextColor
                              : Colors.grey.shade400,
                          onChanged: (value) {
                            if (widget.isUpdate!) {
                              setState(() {
                                isProductActive = value!;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Active',
                        style: TextStyle(
                          color: widget.isUpdate!
                              ? Colors.black
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'Submit',
                        color: CommonUtils.primaryTextColor,
                        onPressed: validateForm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void validateForm() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final connection = await CommonUtils.checkInternetConnectivity();
    if (!connection) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No internet connection'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    setState(() {
      isRequestProcessing = true;
    });
    // validateProductColor(selectedTypeCdId?.toString());
// formKey.currentState!.validate() &&
    print(
        'formValidation: ${formKey.currentState!.validate()}  | $isProductNameValidate | $isProductQuantityValidate');
    if (formKey.currentState!.validate() &&
        isProductNameValidate &&
        isProductQuantityValidate) {
      addInventory();
    }
  }

/* 
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
 */

  //MARK: Product Name
  CustomeFormField productfield() {
    return CustomeFormField(
      label: 'Product Name',
      controller: productNameController,
      errorText: _productNameError ? _productNameErrorMsg : null,
      validator: validateProductName,
      onChanged: (value) {
        setState(() {
          if (value.startsWith(' ')) {
            productNameController.value = TextEditingValue(
              text: value.trimLeft(),
              selection:
                  TextSelection.collapsed(offset: value.trimLeft().length),
            );
          }
          _productNameError = false;
        });
      },
      maxLength: 25,
      keyboardType: TextInputType.name,
    );
  }

  String? validateProductName(String? value) {
    print('validatefullname: $value');
    if (value!.isEmpty) {
      setState(() {
        _productNameError = true;
        _productNameErrorMsg = 'Please Enter Product Name';
      });
      isProductNameValidate = false;
      return null;
    }
    isProductNameValidate = true;
    return null;
  }

  //MARK: Quantity
  CustomeFormField quantityField() {
    return CustomeFormField(
      label: 'Product Quantity',
      controller: quantityController,
      /* validator: (value) {
        if (value!.isEmpty) {
          return 'Please Enter Product Quantity';
        }
        return null;
      }, */
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      validator: validateProductQuantity,
      errorText: _productQuantityError ? _productQuantityErrorMsg : null,
      onChanged: (value) {
        setState(() {
          if (value.startsWith(' ')) {
            quantityController.value = TextEditingValue(
              text: value.trimLeft(),
              selection:
                  TextSelection.collapsed(offset: value.trimLeft().length),
            );
          }
          _productQuantityError = false;
        });
      },
    );
  }

  String? validateProductQuantity(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        _productQuantityError = true;
        _productQuantityErrorMsg = 'Please Enter Product Quantity';
      });
      isProductQuantityValidate = false;
      return null;
    }

    if (!widget.isUpdate! && int.tryParse(value) == 0) {
      // Apply "cannot be 0" validation only when isUpdate is false (adding new data)
      setState(() {
        _productQuantityError = true;
        _productQuantityErrorMsg = 'Product Quantity cannot be 0';
      });
      isProductQuantityValidate = false;
      return null;
    }

    setState(() {
      _productQuantityError = false;
    });
    isProductQuantityValidate = true;
    return null;
  }


  CustomeFormField descriptionfield() {
    return CustomeFormField(
      label: 'Product Description',
      controller: descNameController,
      maxLines: 3,
      maxLength: 200,
      isMandatory: false,
      // errorText:
      // _fullNameError ? _fullNameErrorMsg : null,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

/* 
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
        widget.inventory != null
            ? Container(
                padding: const EdgeInsets.all(13),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isGenderSelected
                        ? const Color.fromARGB(255, 175, 15, 4)
                        : CommonUtils.primaryTextColor,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Text('${widget.inventory!.branch}'),
              )
            : Container(
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
                    future: futureBranches,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(13),
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
                              ]),
                        ),
                      );
                    }),
              ),
      ],
    );
  } 
 */

//MARK: Product Color
  Column productColorName(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'Product Color ',
              style: CommonUtils.txSty_12b_fb,
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
              color: isProductColorValidate
                  ? const Color.fromARGB(255, 175, 15, 4)
                  : CommonUtils.primaryTextColor,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: FutureBuilder(
              future: futureColors,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(13),
                    child: Text('Loading Colors'),
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
                final List<ColorsModel> branchList =
                    snapshot.data as List<ColorsModel>;
                return DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<int>(
                        value: selectedTypeCdId,
                        iconSize: 30,
                        icon: null,
                        hint: const Text(
                          'Select Product Color',
                          style: CommonStyles.texthintstyle,
                        ),
                        style: CommonUtils.txSty_12b_fb,
                        onChanged: (value) {
                          if (value != -1) {
                            setState(() {
                              selectedTypeCdId = value;
                            });
                          }
                        },
                        items: [
                         const DropdownMenuItem<int>(
                            value: -1,
                            child: Text(
                              'Select Product Color',
                              style: CommonStyles.texthintstyle,
                            ),
                          ),
                          ...branchList.map((branch) {
                            return DropdownMenuItem<int>(
                              value: branch.typeCdId,
                              child: Text(
                                '${branch.desc}',
                                style: CommonUtils.txSty_12b_fb,
                              ),
                            );
                          }).toList()
                        ]),
                  ),
                );
              }),
        ),
      ],
    );
  }
}
