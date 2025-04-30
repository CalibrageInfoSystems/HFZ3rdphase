class Appointment {
  final int id;
  final int branchId;
  final String name;
  final String address;
  final String imageName;
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
  final int? technicianId;
  final String? technicianName;
  final int? closingTechnicianId;
  final String? closedTechnicianName;

  Appointment({
    required this.id,
    required this.branchId,
    required this.name,
    required this.address,
    required this.imageName,
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
    required this.technicianId,
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
    required this.closingTechnicianId,
    required this.closedTechnicianName,
  });
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0, // Default to 0 if null
      branchId: json['branchId'] ?? 0, // Default to 0 if null
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageName: json['imageName'] ?? '',
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
      technicianId: json['technicianId'],
      purposeOfVisit: json['purposeOfVisit'] ?? '',
      isActive: json['isActive'] ?? false,
      review: json['review'] ?? '',
      rating: json['rating'], // Nullable, no need to change
      reviewSubmittedDate:
          json['reviewSubmittedDate'], // Nullable, no need to change
      price: json['price'], // Nullable, no need to change
      customerId: json['customerId'] ?? 0, // Default to 0 if null
      timeofSlot: json['timeofSlot'] ?? '',
      slotDuration: json['slotDuration'] ?? '',
      paymentTypeId: json['paymentTypeId'] ?? 0, // Default to 0 if null
      paymentType: json['paymentType'] ?? '',
      technicianName: json['technicianName'] ?? '',
      closingTechnicianId: json['closingTechnicianId'],
      closedTechnicianName: json['closedTechnicianName'] ?? '',
    );
  }
}
