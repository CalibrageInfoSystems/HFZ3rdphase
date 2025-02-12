import 'dart:convert';

List<AgentBranchModel> agentBranchModelFromJson(String str) =>
    List<AgentBranchModel>.from(
        json.decode(str).map((x) => AgentBranchModel.fromJson(x)));

String agentBranchModelToJson(List<AgentBranchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AgentBranchModel {
  final int? id;
  final String? name;
  final String? imageName;
  final String? address;
  final String? startTime;
  final String? closeTime;
  final int? room;
  final String? mobileNumber;
  final bool? isActive;
  final int? cityId;
  final String? city;

  AgentBranchModel({
    this.id,
    this.name,
    this.imageName,
    this.address,
    this.startTime,
    this.closeTime,
    this.room,
    this.mobileNumber,
    this.isActive,
    this.cityId,
    this.city,
  });

  factory AgentBranchModel.fromJson(Map<String, dynamic> json) =>
      AgentBranchModel(
        id: json["id"],
        name: json["name"],
        imageName: json["imageName"],
        address: json["address"],
        startTime: json["startTime"],
        closeTime: json["closeTime"],
        room: json["room"],
        mobileNumber: json["mobileNumber"],
        isActive: json["isActive"],
        cityId: json["cityId"],
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "imageName": imageName,
        "address": address,
        "startTime": startTime,
        "closeTime": closeTime,
        "room": room,
        "mobileNumber": mobileNumber,
        "isActive": isActive,
        "cityId": cityId,
        "city": city,
      };
}
