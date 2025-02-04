class Appointment {
  final int id;
  final int branchId;
  final String name;
  final String date;
  final String slotTime;
  final String customerName;
  final String? phoneNumber;
  final String? email;
  final int? genderTypeId;
  final String? gender;
  final int statusTypeId;
  final String status;
  final int purposeOfVisitId;
  final String purposeOfVisit;
  final bool isActive;
  final String? review;
  final double? rating;
  final String? reviewSubmittedDate;
  final double? price;
  final int customerId;
  final String? timeofSlot;
  final String slotDuration;
  final int? paymentTypeId;
  final String? paymentType;
  final String? technicianName;

  Appointment({
    required this.id,
    required this.branchId,
    required this.name,
    required this.date,
    required this.slotTime,
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.genderTypeId,
    required this.gender,
    required this.statusTypeId,
    required this.status,
    required this.purposeOfVisitId,
    required this.purposeOfVisit,
    required this.isActive,
    required this.review,
    required this.rating,
    required this.reviewSubmittedDate,
    required this.price,
    required this.customerId,
    required this.timeofSlot,
    required this.slotDuration,
    required this.paymentTypeId,
    required this.paymentType,
    required this.technicianName,
  });
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0, // Default to 0 if null
      branchId: json['branchId'] ?? 0, // Default to 0 if null
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      slotTime: json['slotTime'] ?? '',
      customerName: json['customerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      genderTypeId: json['genderTypeId'] ?? 0, // Default to 0 if null
      gender: json['gender'] ?? '',
      statusTypeId: json['statusTypeId'] ?? 0, // Default to 0 if null
      status: json['status'] ?? '',
      purposeOfVisitId: json['purposeOfVisitId'] ?? 0, // Default to 0 if null
      purposeOfVisit: json['purposeOfVisit'] ?? '',
      isActive: json['isActive'] ?? false,
      review: json['review'] ?? '',
      rating: json['rating'], // Nullable, no need to change
      reviewSubmittedDate: json['reviewSubmittedDate'], // Nullable, no need to change
      price: json['price'], // Nullable, no need to change
      customerId: json['customerId'] ?? 0, // Default to 0 if null
      timeofSlot: json['timeofSlot'] ?? '',
      slotDuration: json['slotDuration'] ?? '',
      paymentTypeId: json['paymentTypeId'] ?? 0, // Default to 0 if null
      paymentType: json['paymentType'] ?? '',
      technicianName: json['technicianName'] ?? '',
    );
  }


// factory Appointment.fromJson(Map<String, dynamic> json) {
  //   return Appointment(
  //     id: json['id'],
  //     branchId: json['branchId'],
  //     name: json['name'],
  //     date: json['date'],
  //     slotTime: json['slotTime'],
  //     customerName: json['customerName'],
  //     phoneNumber: json['phoneNumber'],
  //     email: json['email'],
  //     genderTypeId: json['genderTypeId']??null,
  //     gender: json['gender']??null,
  //     statusTypeId: json['statusTypeId'],
  //     status: json['status'],
  //     purposeOfVisitId: json['purposeOfVisitId'],
  //     purposeOfVisit: json['purposeOfVisit'],
  //     isActive: json['isActive'],
  //     review: json['review']??null,
  //     rating: json['rating']??null,
  //     reviewSubmittedDate: json['reviewSubmittedDate'],
  //     price: json['price'],
  //     customerId: json['customerId'],
  //     timeofSlot: json['timeofSlot'],
  //     slotDuration: json['slotDuration'],
  //     paymentTypeId: json['paymentTypeId'],
  //     paymentType: json['paymentType'],
  //     technicianName: json['technicianName'],
  //   );
  // }
}

//
//   final int id;
//   final int branchId;
//   final String name;
//   final String date;
//   final int slotTime;
//   final String customerName;
//   final String phoneNumber;
//   final String email;
//   final int? genderTypeId;
//   final String? gender;
//   final int statusTypeId;
//   final String status;
//   final int purposevisitid;
//   final String purposeofvisit;
//   final bool isActive;
//   bool isAccepted;
//   bool isRejected;
//   bool isClosed;
//   final String SlotDuration;
//   final String? review;
//   final double? rating;
//   final int? CustomerId;
//   final String? timeofslot;
//
//   Appointment(
//       {required this.id,
//       required this.branchId,
//       required this.name,
//       required this.date,
//       required this.slotTime,
//       required this.customerName,
//       required this.phoneNumber,
//       required this.email,
//       required this.genderTypeId,
//       required this.gender,
//       required this.statusTypeId,
//       required this.status,
//       required this.purposevisitid,
//       required this.purposeofvisit,
//       required this.isActive,
//       this.isAccepted = false,
//       this.isRejected = false,
//       this.isClosed = false,
//       required this.SlotDuration,
//       required this.review,
//       required this.rating,
//       required this.timeofslot,
//       required this.CustomerId});
//
//   factory Appointment.fromJson(Map<String, dynamic> json) {
//     return Appointment(
//       id: json['id'],
//       branchId: json['branchId'],
//       name: json['name'],
//       date: json['date'],
//       slotTime: json['slotTime'],
//       customerName: json['customerName'],
//       phoneNumber: json['phoneNumber'],
//       email: json['email'],
//       genderTypeId: json['genderTypeId'],
//       gender: json['gender'],
//       statusTypeId: json['statusTypeId'],
//       status: json['status'],
//       purposevisitid: json['purposeOfVisitId'],
//       purposeofvisit: json['purposeOfVisit'],
//       isActive: json['isActive'],
//       SlotDuration: json['slotDuration'],
//       review: json['review'],
//       rating: json['rating'] != null ? json['rating'].toDouble() : null,
//       CustomerId: json['customerId'],
//       timeofslot: json['timeofSlot'],
//     );
//   }
// }
