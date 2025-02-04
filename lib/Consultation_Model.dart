class Consultation {
  final int consultationId;
  final String consultationName;
  final int genderTypeId;
  final String gender;
  final String phoneNumber;
  final String email;
  final int branchId;
  final String branchName;
  final bool isActive;
  final String remarks;
  final int createdByUser;
  final String createdDate;
  final int? updatedByUser;
  final String? updatedDate;

  Consultation({
    required this.consultationId,
    required this.consultationName,
    required this.genderTypeId,
    required this.gender,
    required this.phoneNumber,
    required this.email,
    required this.branchId,
    required this.branchName,
    required this.isActive,
    required this.remarks,
    required this.createdByUser,
    required this.createdDate,
    this.updatedByUser,
    this.updatedDate,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      consultationId: json['consultationId'],
      consultationName: json['consultationName'],
      genderTypeId: json['genderTypeId'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      branchId: json['branchId'],
      branchName: json['branchName'],
      isActive: json['isActive'],
      remarks: json['remarks'],
      createdByUser: json['createdByUser'],
      createdDate: json['createdDate'],
      updatedByUser: json['updatedByUser'],
      updatedDate: json['updatedDate'],
    );
  }
}
