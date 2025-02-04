// Define a Model_branch class to represent a branch
class Model_branch {
  final int id;
  final String branchName;
  final String address;
  final String mobileNumber;
  final String imageName;
  final double? latitude;
  final double? longitude;

  Model_branch({
    required this.id,
    required this.branchName,
    required this.address,
    required this.mobileNumber,
    required this.imageName,
    this.latitude,
    this.longitude,
  });

  // Factory method to create a Model_branch object from JSON
  factory Model_branch.fromJson(Map<String, dynamic> json) {
    return Model_branch(
      id: json['id'],
      branchName: json['branchName'],
      address: json['address'],
      mobileNumber: json['mobileNumber'],
      imageName: json['imageName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}