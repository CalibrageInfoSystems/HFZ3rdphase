import 'dart:convert';

class User {
  int id;
  String userId;
  String firstname;
  String? lastname;
  String? middleName;
  String contactNumber;
  String? mobileNumber;
  String userName;
  String password;
  String email;
  bool isActive;
  int? createdByUserId;
  DateTime createdDate;
  int updatedByUserId;
  DateTime updatedDate;
  String rolename;
  int roleID;
  String fullName;
  int genderId;
  String gender;
  DateTime dateOfBirth;
  dynamic activityRights;
  dynamic branchIds;

  User({
    required this.id,
    required this.userId,
    required this.firstname,
    this.lastname,
    this.middleName,
    required this.contactNumber,
    this.mobileNumber,
    required this.userName,
    required this.password,
    required this.email,
    required this.isActive,
    this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.rolename,
    required this.roleID,
    required this.fullName,
    required this.genderId,
    required this.gender,
    required this.dateOfBirth,
    this.activityRights,
    this.branchIds,
  });

  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return User(
      id: jsonMap['id'],
      userId: jsonMap['userid'],
      firstname: jsonMap['firstname'],
      lastname: jsonMap['lastname'],
      middleName: jsonMap['middleName'],
      contactNumber: jsonMap['contactNumber'],
      mobileNumber: jsonMap['mobileNumber'],
      userName: jsonMap['userName'],
      password: jsonMap['password'],
      email: jsonMap['email'],
      isActive: jsonMap['isActive'],
      createdByUserId: jsonMap['createdByUserId'],
      createdDate: DateTime.parse(jsonMap['createdDate']),
      updatedByUserId: jsonMap['updatedByUserId'],
      updatedDate: DateTime.parse(jsonMap['updatedDate']),
      rolename: jsonMap['rolename'],
      roleID: jsonMap['roleID'],
      fullName: jsonMap['fullName'],
      genderId: jsonMap['genderId'],
      gender: jsonMap['gender'],
      dateOfBirth: DateTime.parse(jsonMap['dateofbirth']),
      activityRights: jsonMap['activityRights'],
      branchIds: jsonMap['branchIds'],
    );
  }
}
