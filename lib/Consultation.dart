import 'dart:convert';

List<Consultation> consultationFromJson(String str) => List<Consultation>.from(
    json.decode(str).map((x) => Consultation.fromJson(x)));

String consultationToJson(List<Consultation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Consultation {
  final int? consultationId;
  final String? consultationName;
  final int? genderTypeId;
  final String? gender;
  final String? phoneNumber;
  final String? email;
  final int? branchId;
  final String? branchName;
  final int? cityId;
  final String? city;
  final bool? isActive;
  final String? remarks;
  final int? createdByUser;
  final DateTime? createdDate;
  final int? updatedByUser;
  final DateTime? updatedDate;
  final DateTime? visitingDate;
  final int? statusTypeId;
  final String? status;

  Consultation({
    this.consultationId,
    this.consultationName,
    this.genderTypeId,
    this.gender,
    this.phoneNumber,
    this.email,
    this.branchId,
    this.branchName,
    this.cityId,
    this.city,
    this.isActive,
    this.remarks,
    this.createdByUser,
    this.createdDate,
    this.updatedByUser,
    this.updatedDate,
    this.visitingDate,
    this.statusTypeId,
    this.status,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) => Consultation(
        consultationId: json["consultationId"],
        consultationName: json["consultationName"],
        genderTypeId: json["genderTypeId"],
        gender: json["gender"],
        phoneNumber: json["phoneNumber"],
        email: json["email"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        cityId: json["cityId"],
        city: json["city"],
        isActive: json["isActive"],
        remarks: json["remarks"],
        createdByUser: json["createdByUser"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]),
        updatedByUser: json["updatedByUser"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        visitingDate: json["visitingDate"] == null
            ? null
            : DateTime.parse(json["visitingDate"]),
        statusTypeId: json["statusTypeId"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "consultationId": consultationId,
        "consultationName": consultationName,
        "genderTypeId": genderTypeId,
        "gender": gender,
        "phoneNumber": phoneNumber,
        "email": email,
        "branchId": branchId,
        "branchName": branchName,
        "cityId": cityId,
        "city": city,
        "isActive": isActive,
        "remarks": remarks,
        "createdByUser": createdByUser,
        "createdDate": createdDate?.toIso8601String(),
        "updatedByUser": updatedByUser,
        "updatedDate": updatedDate?.toIso8601String(),
        "visitingDate": visitingDate?.toIso8601String(),
        "statusTypeId": statusTypeId,
        "status": status,
      };
}
