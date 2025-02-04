
import 'dart:convert';

List<MyAppointment_Model> myAppointmentModelFromJson(String str) =>
    List<MyAppointment_Model>.from(
        json.decode(str).map((x) => MyAppointment_Model.fromJson(x)));

String myAppointmentModelToJson(List<MyAppointment_Model> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyAppointment_Model {
  final int id;
  final int branchId;
  final String branch;
  final String imageName;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? locationUrl;
  final String date;
  final String slotTime;
  final String customerName;
  final String contactNumber;
  final String email;
  final int genderTypeId;
  final String genderName;
  final int statusTypeId;
  final String status;
  final int purposeOfVisitId;
  final String purposeOfVisit;
  final bool isActive;
  final String? review;
  final double? rating;
  final String? reviewsubmittedDate;
  final double? price;
  final int customerId;
  final String? timeofSlot;
  final int? paymentTypeId;
  final String? technicianName;
  final int? technicianId;
  final String? paymentType;
  final String slotDuration;
  final String combinedDateTime;

  MyAppointment_Model({
    required this.id,
    required this.branchId,
    required this.branch,
    required this.imageName,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.locationUrl,
    required this.date,
    required this.slotTime,
    required this.customerName,
    required this.contactNumber,
    required this.email,
    required this.genderTypeId,
    required this.genderName,
    required this.statusTypeId,
    required this.status,
    required this.purposeOfVisitId,
    required this.purposeOfVisit,
    required this.isActive,
    required this.review,
    required this.rating,
    required this.reviewsubmittedDate,
    required this.price,
    required this.customerId,
    required this.timeofSlot,
    required this.paymentTypeId,
    required this.technicianName,
    required this.technicianId,
    required this.paymentType,
    required this.slotDuration,
    required this.combinedDateTime,
  });

  factory MyAppointment_Model.fromJson(Map<String, dynamic> json) =>
      MyAppointment_Model(
        id: json["id"],
        branchId: json["branchId"],
        branch: json["branch"],
        imageName: json["imageName"],
        filePath: json["filePath"],
        fileName: json["fileName"],
        fileExtension: json["fileExtension"],
        address: json["address"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        locationUrl :json["locationUrl"],
        date: json["date"],
        slotTime: json["slotTime"],
        customerName: json["customerName"],
        contactNumber: json["contactNumber"],
        email: json["email"],
        genderTypeId: json["genderTypeId"],
        genderName: json["genderName"],
        statusTypeId: json["statusTypeId"],
        status: json["status"],
        purposeOfVisitId: json["purposeOfVisitId"],
        purposeOfVisit: json["purposeOfVisit"],
        isActive: json["isActive"],
        review: json["review"],
        rating: json["rating"],
        reviewsubmittedDate: json["reviewsubmittedDate"],
        price: json["price"],
        customerId: json["customerId"],
        timeofSlot: json["timeofSlot"],
        paymentTypeId: json["paymentTypeId"],
        technicianName: json["technicianName"],
        technicianId: json["technicianId"],
        paymentType: json["paymentType"],
        slotDuration: json["slotDuration"],
        combinedDateTime: json["combinedDateTime"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "branchId": branchId,
        "branch": branch,
        "imageName": imageName,
        "filePath": filePath,
        "fileName": fileName,
        "fileExtension": fileExtension,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "date": date,
        "slotTime": slotTime,
        "customerName": customerName,
        "contactNumber": contactNumber,
        "email": email,
        "genderTypeId": genderTypeId,
        "genderName": genderName,
        "statusTypeId": statusTypeId,
        "status": status,
        "purposeOfVisitId": purposeOfVisitId,
        "purposeOfVisit": purposeOfVisit,
        "isActive": isActive,
        "review": review,
        "rating": rating,
        "reviewsubmittedDate": reviewsubmittedDate,
        "price": price,
        "customerId": customerId,
        "timeofSlot": timeofSlot,
        "paymentTypeId": paymentTypeId,
        "technicianName": technicianName,
        "technicianId": technicianId,
        "paymentType": paymentType,
        "slotDuration": slotDuration,
        "combinedDateTime": combinedDateTime,
      };
}
