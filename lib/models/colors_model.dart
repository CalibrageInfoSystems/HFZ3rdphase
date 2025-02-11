import 'dart:convert';

List<ColorsModel> colorsModelFromJson(String str) => List<ColorsModel>.from(
    json.decode(str).map((x) => ColorsModel.fromJson(x)));

String colorsModelToJson(List<ColorsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ColorsModel {
  final int? typeCdId;
  final int? classTypeId;
  final String? name;
  final String? desc;
  final String? tableName;
  final String? columnName;
  final int? sortOrder;
  final bool? isActive;

  ColorsModel({
    this.typeCdId,
    this.classTypeId,
    this.name,
    this.desc,
    this.tableName,
    this.columnName,
    this.sortOrder,
    this.isActive,
  });

  factory ColorsModel.fromJson(Map<String, dynamic> json) => ColorsModel(
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
