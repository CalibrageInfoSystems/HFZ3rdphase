

import 'dart:convert';

Product_Model productModelFromJson(String str) => Product_Model.fromJson(json.decode(str));

String productModelToJson(Product_Model data) => json.encode(data.toJson());

class Product_Model {
  final List<ProductList> productList;
  final bool isSuccess;
  final int affectedRecords;
  final String statusMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;
  final dynamic links;

  Product_Model({
    required this.productList,
    required this.isSuccess,
    required this.affectedRecords,
    required this.statusMessage,
    required this.validationErrors,
    required this.exception,
    required this.links,
  });

  factory Product_Model.fromJson(Map<String, dynamic> json) => Product_Model(
        productList: List<ProductList>.from(json["productList"].map((x) => ProductList.fromJson(x))),
        isSuccess: json["isSuccess"],
        affectedRecords: json["affectedRecords"],
        statusMessage: json["statusMessage"],
        validationErrors: List<dynamic>.from(json["validationErrors"].map((x) => x)),
        exception: json["exception"],
        links: json["links"],
      );

  Map<String, dynamic> toJson() => {
        "productList": List<dynamic>.from(productList.map((x) => x.toJson())),
        "isSuccess": isSuccess,
        "affectedRecords": affectedRecords,
        "statusMessage": statusMessage,
        "validationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
        "exception": exception,
        "links": links,
      };
}

class ProductList {
  final int id;
  final String code;
  final String name;
  final int categoryTypeId;
  final dynamic genderTypeId;
  final double? minPrice;
  final double? maxPrice;
  final double? minDiscountPrice;
  final double? maxDiscountPrice;
  final String imageName;
  final String fileLocation;
  final String fileName;
  final String fileExtension;
  final bool isActive;
  final String categoryName;
  final dynamic gender;
  final String createdBy;
  final String updatedBy;
  dynamic bestseller;
  int farvoirte;
  ProductList(
      {required this.id,
      required this.code,
      required this.name,
      required this.categoryTypeId,
      required this.genderTypeId,
      required this.minPrice,
      required this.maxPrice,
      required this.minDiscountPrice,
      required this.maxDiscountPrice,
      required this.imageName,
      required this.fileLocation,
      required this.fileName,
      required this.fileExtension,
      required this.isActive,
      required this.categoryName,
      required this.gender,
      required this.createdBy,
      required this.updatedBy,
      required this.bestseller,
      required this.farvoirte
      });

  factory ProductList.fromJson(Map<String, dynamic> json) => ProductList(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        categoryTypeId: json["categoryTypeId"],
        genderTypeId: json["genderTypeId"],
        minPrice: json["minPrice"]?.toDouble(),
        maxPrice: json["maxPrice"]?.toDouble(),
        minDiscountPrice: json["minDiscountPrice"]?.toDouble(),
        maxDiscountPrice: json["maxDiscountPrice"]?.toDouble(),
        imageName: json["imageName"],
        fileLocation: json["fileLocation"],
        fileName: json["fileName"],
        fileExtension: json["fileExtension"],
        isActive: json["isActive"],
        categoryName: json["categoryName"],
        gender: json["gender"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        bestseller: json["bestSeller"],
        farvoirte: json["isFavourite"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "categoryTypeId": categoryTypeId,
        "genderTypeId": genderTypeId,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
        "minDiscountPrice": minDiscountPrice,
        "maxDiscountPrice": maxDiscountPrice,
        "imageName": imageName,
        "fileLocation": fileLocation,
        "fileName": fileName,
        "fileExtension": fileExtension,
        "isActive": isActive,
        "categoryName": categoryName,
        "gender": gender,
        "createdBy": createdBy,
        "bestSeller": bestseller,
        "updatedBy": updatedBy,
    "isFavourite":farvoirte
      };
}
