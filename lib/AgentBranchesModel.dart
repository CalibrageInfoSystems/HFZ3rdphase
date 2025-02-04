import 'dart:convert';

AgentBranchesModel agentBranchesModelFromJson(String str) =>
    AgentBranchesModel.fromJson(json.decode(str));

String agentBranchesModelToJson(AgentBranchesModel data) =>
    json.encode(data.toJson());

class AgentBranchesModel {
  final int id;
  final String firstName;
  final String userName;
  final String password;
  final bool isActive;
  final int roleId;
  final String email;
  final String contactNumber;
  final DateTime dateofbirth;
  final String validate;
  final int branchId;
  final String branchName;
  final String gender;
  final int genderTypeId;
  final String roleName;

  AgentBranchesModel({
    required this.id,
    required this.firstName,
    required this.userName,
    required this.password,
    required this.isActive,
    required this.roleId,
    required this.email,
    required this.contactNumber,
    required this.dateofbirth,
    required this.validate,
    required this.branchId,
    required this.branchName,
    required this.gender,
    required this.genderTypeId,
    required this.roleName,
  });

  factory AgentBranchesModel.fromJson(Map<String, dynamic> json) =>
      AgentBranchesModel(
        id: json["id"],
        firstName: json["firstName"],
        userName: json["userName"],
        password: json["password"],
        isActive: json["isActive"],
        roleId: json["roleID"],
        email: json["email"],
        contactNumber: json["contactNumber"],
        dateofbirth: DateTime.parse(json["dateofbirth"]),
        validate: json["validate"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        gender: json["gender"],
        genderTypeId: json["genderTypeId"],
        roleName: json["roleName"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "userName": userName,
    "password": password,
    "isActive": isActive,
    "roleID": roleId,
    "email": email,
    "contactNumber": contactNumber,
    "dateofbirth": dateofbirth.toIso8601String(),
    "validate": validate,
    "branchId": branchId,
    "branchName": branchName,
    "gender": gender,
    "genderTypeId": genderTypeId,
    "roleName": roleName,
  };
}
