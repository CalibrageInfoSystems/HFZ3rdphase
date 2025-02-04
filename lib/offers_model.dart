class ListResultResponse {
  List<Offermodel>? listResult;
  bool? isSuccess;
  int? affectedRecords;
  String? statusMessage;
  List<dynamic>? validationErrors;
  dynamic exception;
  dynamic links;

  ListResultResponse({
    this.listResult,
    this.isSuccess,
    this.affectedRecords,
    this.statusMessage,
    this.validationErrors,
    this.exception,
    this.links,
  });

  factory ListResultResponse.fromJson(Map<String, dynamic> json) {
    return ListResultResponse(
      listResult: json['listResult'] != null
          ? (json['listResult'] as List)
          .map((i) => Offermodel.fromJson(i))
          .toList()
          : null,
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      statusMessage: json['statusMessage'],
      validationErrors: json['validationErrors'] != null
          ? List<dynamic>.from(json['validationErrors'])
          : null,
      exception: json['exception'],
      links: json['links'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listResult': listResult != null
          ? listResult!.map((v) => v.toJson()).toList()
          : null,
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'statusMessage': statusMessage,
      'validationErrors': validationErrors,
      'exception': exception,
      'links': links,
    };
  }
}

class Offermodel {
  int? id;
  String? name;
  String? description;
  String? imageName;
  String? fileLocation;
  String? fileName;
  String? fileExtension;
  bool? isActive;
  String? createdBy;
  String? updatedBy;
  DateTime? createdDate;
  DateTime? updatedDate;

  Offermodel({
    this.id,
    this.name,
    this.description,
    this.imageName,
    this.fileLocation,
    this.fileName,
    this.fileExtension,
    this.isActive,
    this.createdBy,
    this.updatedBy,
    this.createdDate,
    this.updatedDate,
  });

  factory Offermodel.fromJson(Map<String, dynamic> json) {
    return Offermodel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageName: json['imageName'],
      fileLocation: json['fileLocation'],
      fileName: json['fileName'],
      fileExtension: json['fileExtension'],
      isActive: json['isActive'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageName': imageName,
      'fileLocation': fileLocation,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'isActive': isActive,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdDate': createdDate?.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }
}
