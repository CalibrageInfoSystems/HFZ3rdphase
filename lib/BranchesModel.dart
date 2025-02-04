import 'package:meta/meta.dart';
import 'dart:convert';

BranchesModel branchesModelFromJson(String str) =>
    BranchesModel.fromJson(json.decode(str));

String branchesModelToJson(BranchesModel data) => json.encode(data.toJson());

class BranchesModel {
  final List<BranchList> branchList;
  final bool isSuccess;
  final int affectedRecords;
  final String statusMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;
  final dynamic links;

  BranchesModel({
    required this.branchList,
    required this.isSuccess,
    required this.affectedRecords,
    required this.statusMessage,
    required this.validationErrors,
    required this.exception,
    required this.links,
  });

  factory BranchesModel.fromJson(Map<String, dynamic> json) => BranchesModel(
        branchList: List<BranchList>.from(
            json["branchList"].map((x) => BranchList.fromJson(x))),
        isSuccess: json["isSuccess"],
        affectedRecords: json["affectedRecords"],
        statusMessage: json["statusMessage"],
        validationErrors:
            List<dynamic>.from(json["validationErrors"].map((x) => x)),
        exception: json["exception"] ?? '',
        links: json["links"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "branchList": List<dynamic>.from(branchList.map((x) => x.toJson())),
        "isSuccess": isSuccess,
        "affectedRecords": affectedRecords,
        "statusMessage": statusMessage,
        "validationErrors": List<dynamic>.from(validationErrors.map((x) => x)),
        "exception": exception,
        "links": links,
      };
}

class BranchList {
  final int id;
  final String name;
  final String imageName;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final String address;
  final int startTime;
  final int closeTime;
  final int room;
  final String mobileNumber;
  final bool isActive;
  final String cityName;
  final String createdBy;
  final String updatedBy;
  final int breakStartTime;
  final int breakEndTime;
  final int cityId;

  BranchList({
    required this.id,
    required this.name,
    required this.imageName,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.address,
    required this.startTime,
    required this.closeTime,
    required this.room,
    required this.mobileNumber,
    required this.isActive,
    required this.cityName,
    required this.createdBy,
    required this.updatedBy,
    required this.breakStartTime,
    required this.breakEndTime,
    required this.cityId,
  });

  factory BranchList.fromJson(Map<String, dynamic> json) => BranchList(
        id: json["id"],
        name: json["name"],
        imageName: json["imageName"],
        filePath: json["filePath"],
        fileName: json["fileName"],
        fileExtension: json["fileExtension"],
        address: json["address"],
        startTime: json["startTime"],
        closeTime: json["closeTime"],
        room: json["room"],
        mobileNumber: json["mobileNumber"],
        isActive: json["isActive"],
        cityName: json["cityName"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        breakStartTime: json["breakStartTime"],
        breakEndTime: json["breakEndTime"],
        cityId: json["cityId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "imageName": imageName,
        "filePath": filePath,
        "fileName": fileName,
        "fileExtension": fileExtension,
        "address": address,
        "startTime": startTime,
        "closeTime": closeTime,
        "room": room,
        "mobileNumber": mobileNumber,
        "isActive": isActive,
        "cityName": cityName,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "breakStartTime": breakStartTime,
        "breakEndTime": breakEndTime,
        "cityId": cityId,
      };
}
// test change