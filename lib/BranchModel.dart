class BranchModel {
  final int? id;
  final String name;
  final String? imageName;
  final String address;
  final String startTime;
  final String closeTime;
  final int room;
  final String mobileNumber;
  final bool isActive;
  final String? cityName;
  final dynamic createdBy; // Assuming createdBy can be of any type
  final dynamic updatedBy; // Assuming updatedBy can be of any type
  final double? latitude;
  final double? longitude;
  final String? locationUrl;
  BranchModel({
    required this.id,
    required this.name,
    this.imageName,
    required this.address,
    required this.startTime,
    required this.closeTime,
    required this.room,
    required this.mobileNumber,
    required this.isActive,
    this.cityName,
    this.createdBy,
    this.updatedBy,
    this.latitude,
    this.longitude,
    required this.locationUrl,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageName: json['imageName'],
      address: json['address'] ?? '',
      startTime: json['startTime'] ?? 0,
      closeTime: json['closeTime'] ?? 0,
      room: json['room'] ?? 0,
      mobileNumber: json['mobileNumber'] ?? '',
      isActive: json['isActive'] ?? false,
      cityName: json['cityName'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      locationUrl: json['LocationUrl'],
    );
  }
}
