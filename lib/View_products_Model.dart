import 'dart:convert';

class ApiResponse {
  final List<ViewProduct> listResult;
  final bool isSuccess;
  final int affectedRecords;
  final String statusMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;
  final dynamic links;

  ApiResponse({
    required this.listResult,
    required this.isSuccess,
    required this.affectedRecords,
    required this.statusMessage,
    required this.validationErrors,
    this.exception,
    this.links,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      listResult: (json['listResult'] as List<dynamic>)
          .map((e) => ViewProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      statusMessage: json['statusMessage'],
      validationErrors: json['validationErrors'] as List<dynamic>,
      exception: json['exception'],
      links: json['links'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listResult': listResult.map((e) => e.toJson()).toList(),
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'statusMessage': statusMessage,
      'validationErrors': validationErrors,
      'exception': exception,
      'links': links,
    };
  }
}

class ViewProduct {
  final int id;
  final String code;
  final String name;
  final int categoryTypeId;
  final int genderTypeId;
  final double? minPrice;
  final double? maxPrice;
  final String imageName;
  final String fileLocation;
  final String fileName;
  final String fileExtension;
  final bool isActive;
  final String categoryName;
  final String gender;
  final bool bestSeller;

  ViewProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryTypeId,
    required this.genderTypeId,
    this.minPrice,
    this.maxPrice,
    required this.imageName,
    required this.fileLocation,
    required this.fileName,
    required this.fileExtension,
    required this.isActive,
    required this.categoryName,
    required this.gender,
    required this.bestSeller,
  });

  factory ViewProduct.fromJson(Map<String, dynamic> json) {
    return ViewProduct(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      categoryTypeId: json['categoryTypeId'],
      genderTypeId: json['genderTypeId'],
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      imageName: json['imageName'],
      fileLocation: json['fileLocation'],
      fileName: json['fileName'],
      fileExtension: json['fileExtension'],
      isActive: json['isActive'],
      categoryName: json['categoryName'],
      gender: json['gender'],
      bestSeller: json['bestSeller'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'categoryTypeId': categoryTypeId,
      'genderTypeId': genderTypeId,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'imageName': imageName,
      'fileLocation': fileLocation,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'isActive': isActive,
      'categoryName': categoryName,
      'gender': gender,
      'bestSeller': bestSeller,
    };
  }
}


