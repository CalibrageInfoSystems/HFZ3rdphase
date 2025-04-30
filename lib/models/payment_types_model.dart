// To parse this JSON data, do
//
//     final paymentTypesModel = paymentTypesModelFromJson(jsonString);

import 'dart:convert';

List<PaymentTypesModel> paymentTypesModelFromJson(String str) =>
    List<PaymentTypesModel>.from(
        json.decode(str).map((x) => PaymentTypesModel.fromJson(x)));

String paymentTypesModelToJson(List<PaymentTypesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaymentTypesModel {
  final int? typeCdId;
  final int? classTypeId;
  final String? name;
  final String? desc;
  final String? tableName;
  final String? columnName;
  final int? sortOrder;
  final bool? isActive;

  PaymentTypesModel({
    this.typeCdId,
    this.classTypeId,
    this.name,
    this.desc,
    this.tableName,
    this.columnName,
    this.sortOrder,
    this.isActive,
  });

  factory PaymentTypesModel.fromJson(Map<String, dynamic> json) =>
      PaymentTypesModel(
        typeCdId: json["typeCdId"],
        classTypeId: json["classTypeId"],
        name: json["name"],
        desc: json["desc"],
        tableName: json["tableName"],
        columnName: json["columnName"],
        sortOrder: json["sortOrder"],
        isActive: json["isActive"],
      );

  Map<String, dynamic> toJson() => {
        "typeCdId": typeCdId,
        "classTypeId": classTypeId,
        "name": name,
        "desc": desc,
        "tableName": tableName,
        "columnName": columnName,
        "sortOrder": sortOrder,
        "isActive": isActive,
      };
}
