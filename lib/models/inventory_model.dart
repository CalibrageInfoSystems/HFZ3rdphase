// To parse this JSON data, do
//
//     final inventoryModel = inventoryModelFromJson(jsonString);

import 'dart:convert';

List<InventoryModel> inventoryModelFromJson(String str) =>
    List<InventoryModel>.from(
        json.decode(str).map((x) => InventoryModel.fromJson(x)));

String inventoryModelToJson(List<InventoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InventoryModel {
  final int? id;
  final int? branchId;
  final String? productName;
  final double? quantity;
  final int? colorTypeId;
  final String? desc;
  final bool? isActive;
  final int? createdByUserId;
  final int? updatedByUserId;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? createdBy;
  final String? updatedBy;
  final String? branch;
  final String? color;
  final int? genderTypeId;
  final String? gender;

  InventoryModel({
    this.id,
    this.branchId,
    this.productName,
    this.quantity,
    this.colorTypeId,
    this.desc,
    this.isActive,
    this.createdByUserId,
    this.updatedByUserId,
    this.createdDate,
    this.updatedDate,
    this.createdBy,
    this.updatedBy,
    this.branch,
    this.color,
    this.genderTypeId,
    this.gender,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) => InventoryModel(
        id: json["id"],
        branchId: json["branchId"],
        productName: json["productName"],
        quantity: json["quantity"]?.toDouble(),
        colorTypeId: json["colorTypeId"],
        desc: json["desc"],
        isActive: json["isActive"],
        createdByUserId: json["createdByUserId"],
        updatedByUserId: json["updatedByUserId"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]),
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        branch: json["branch"],
        color: json["color"],
        genderTypeId: json["genderTypeId"],
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "branchId": branchId,
        "productName": productName,
        "quantity": quantity,
        "colorTypeId": colorTypeId,
        "desc": desc,
        "isActive": isActive,
        "createdByUserId": createdByUserId,
        "updatedByUserId": updatedByUserId,
        "createdDate": createdDate?.toIso8601String(),
        "updatedDate": updatedDate?.toIso8601String(),
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "branch": branch,
        "color": color,
        "genderTypeId": genderTypeId,
        "gender": gender,
      };
}
