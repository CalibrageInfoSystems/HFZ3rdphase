// To parse this JSON data, do
//
//     final techniciansModel = techniciansModelFromJson(jsonString);

import 'dart:convert';

List<TechniciansModel> techniciansModelFromJson(String str) =>
    List<TechniciansModel>.from(
        json.decode(str).map((x) => TechniciansModel.fromJson(x)));

String techniciansModelToJson(List<TechniciansModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TechniciansModel {
  final int? id;
  final String? firstName;
  final String? userName;
  final String? roleName;
  final String? code;

  TechniciansModel({
    this.id,
    this.firstName,
    this.userName,
    this.roleName,
    this.code,
  });

  factory TechniciansModel.fromJson(Map<String, dynamic> json) =>
      TechniciansModel(
        id: json["id"],
        firstName: json["firstName"],
        userName: json["userName"],
        roleName: json["roleName"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "userName": userName,
        "roleName": roleName,
        "code": code,
      };
}
