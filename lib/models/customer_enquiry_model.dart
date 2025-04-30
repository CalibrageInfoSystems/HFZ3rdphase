// To parse this JSON data, do
//
//     final customerEnquiry = customerEnquiryFromJson(jsonString);

import 'dart:convert';

List<CustomerEnquiryModel> customerEnquiryFromJson(String str) =>
    List<CustomerEnquiryModel>.from(
        json.decode(str).map((x) => CustomerEnquiryModel.fromJson(x)));

String customerEnquiryToJson(List<CustomerEnquiryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerEnquiryModel {
  final int? id;
  final String? customerName;
  final String? mobileNumber;
  final String? email;
  final int? branchId;
  final String? branchName;
  final int? cityId;
  final String? city;
  final bool? isActive;
  final String? remarks;
  final int? createdByUserId;
  final String? createdBy;
  final DateTime? createdDate;
  final int? updatedByUserId;
  final String? updatedBy;
  final DateTime? updatedDate;

  CustomerEnquiryModel({
    this.id,
    this.customerName,
    this.mobileNumber,
    this.email,
    this.branchId,
    this.branchName,
    this.cityId,
    this.city,
    this.isActive,
    this.remarks,
    this.createdByUserId,
    this.createdBy,
    this.createdDate,
    this.updatedByUserId,
    this.updatedBy,
    this.updatedDate,
  });

  factory CustomerEnquiryModel.fromJson(Map<String, dynamic> json) =>
      CustomerEnquiryModel(
        id: json["id"],
        customerName: json["customerName"],
        mobileNumber: json["mobileNumber"],
        email: json["email"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        cityId: json["cityId"],
        city: json["city"],
        isActive: json["isActive"],
        remarks: json["remarks"],
        createdByUserId: json["createdByUserId"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]),
        updatedByUserId: json["updatedByUserId"],
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "customerName": customerName,
        "mobileNumber": mobileNumber,
        "email": email,
        "branchId": branchId,
        "branchName": branchName,
        "cityId": cityId,
        "city": city,
        "isActive": isActive,
        "remarks": remarks,
        "createdByUserId": createdByUserId,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedByUserId": updatedByUserId,
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };
}
