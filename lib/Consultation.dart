// Model class to represent the consultation data
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
  final String visitingDate;
  // final String updatedByUser;
  // final String? updatedDate;

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
    required this.visitingDate,
    // required this.updatedByUser,
    // required this.updatedDate,
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
      // visitingDate: json['updatedByUser'] ?? 0,
      visitingDate: json['visitingDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consultationId': consultationId,
      'consultationName': consultationName,
      'genderTypeId': genderTypeId,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
      'branchId': branchId,
      'branchName': branchName,
      'isActive': isActive,
      'remarks': remarks,
      'createdByUser': createdByUser,
      'createdDate': createdDate,
      'visitingDate': visitingDate,
    };
  }
}
