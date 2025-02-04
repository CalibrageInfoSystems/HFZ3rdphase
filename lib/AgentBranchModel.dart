class AgentBranchModel  {
  final int id;
  final String name;
  final String imageName;
  final String address;
  final String startTime;
  final String closeTime;
  final int room;
  final String mobileNumber;
  final bool isActive;
  final int cityId;
  final String city;

  AgentBranchModel ({
    required this.id,
    required this.name,
    required this.imageName,
    required this.address,
    required this.startTime,
    required this.closeTime,
    required this.room,
    required this.mobileNumber,
    required this.isActive,
    required this.cityId,
    required this.city,
  });

  factory AgentBranchModel .fromJson(Map<String, dynamic> json) {
    return AgentBranchModel (
      id: json['id'],
      name: json['name'],
      imageName: json['imageName'],
      address: json['address'],
      startTime: json['startTime'],
      closeTime: json['closeTime'],
      room: json['room'],
      mobileNumber: json['mobileNumber'],
      isActive: json['isActive'],
      cityId: json['cityId'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageName': imageName,
      'address': address,
      'startTime': startTime,
      'closeTime': closeTime,
      'room': room,
      'mobileNumber': mobileNumber,
      'isActive': isActive,
      'cityId': cityId,
      'city': city,
    };
  }
}