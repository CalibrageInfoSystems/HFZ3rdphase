class Notifications {
  final int id;
  final int branchId;
  final String name;
  final String date;
  final String slotTime;
  final String customerName;
  final String phoneNumber;
  final String email;
  final int genderTypeId;
  final String gender;
  final int statusTypeId;
  final String status;
  final int purposeOfVisitId;
  final String purposeOfVisit;
  final bool isActive;
  final String address;
  final dynamic review;
  final dynamic reviewSubmittedDate;
  final dynamic rating;
  final dynamic price;
  final int customerId;
  final String timeOfSlot;
  final String slotDuration;


  Notifications({
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
    required this.address,
    required this.review,
    required this.reviewSubmittedDate,
    required this.rating,
    required this.price,
    required this.customerId,
    required this.timeOfSlot,
    required this.slotDuration,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      branchId: json['branchId'],
      name: json['name'],
      date: json['date'],
      slotTime: json['slotTime'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      genderTypeId: json['genderTypeId'],
      gender: json['gender'],
      statusTypeId: json['statusTypeId'],
      status: json['status'],
      purposeOfVisitId: json['purposeOfVisitId'],
      purposeOfVisit: json['purposeOfVisit'],
      isActive: json['isActive'],
      address: json['address'],
      review: json['review'],
      reviewSubmittedDate: json['reviewSubmittedDate'],
      rating: json['rating'],
      price: json['price'],
      customerId: json['customerId'],
      timeOfSlot: json['timeOfSlot'],
      slotDuration: json['slotDuration'],
    );
  }
}

