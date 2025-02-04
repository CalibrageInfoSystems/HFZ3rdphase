import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hairfixingzone/MyAppointment_Model.dart';
import 'package:intl/intl.dart';

class MyAppointmentsProvider extends ChangeNotifier {
  List<MyAppointment_Model> proAppointments = [];
  int selectedCategoryIndex = 0;
  List<MyAppointment_Model> get storeIntoProvider => proAppointments;

// variables
  String displayDate = 'Select Date';
  String? apiFromDate;
  String? apiToDate;
  int? apiBranchId;
  int? apiStatusTypeId;
  bool isFilterApplied = false;

  bool get filterStatus => isFilterApplied;
  set filterStatus(bool newStatus) {
    isFilterApplied = newStatus;
    _notifyListeners();
  }

  String get getDisplayDate => displayDate;
  set getDisplayDate(String newCode) {
    DateTime dateTime = DateTime.parse(newCode);
    displayDate = DateFormat('dd-MM-yyyy').format(dateTime);

    notifyListeners();
  }

  String? get getApiFromDate => apiFromDate;
  set getApiFromDate(String? newCode) {
    print('test: $newCode');
    if (newCode != null) {
      DateTime dateTime = DateTime.parse(newCode);
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      String formattedDateStr = outputFormat.format(dateTime);
      apiFromDate = formattedDateStr;
      apiFromDate = formattedDateStr;
      print('test apiFromDate: $apiFromDate');
    } else {
      apiFromDate = null;
    }

    notifyListeners();
  }

  String? get getApiToDate => apiToDate;
  set getApiToDate(String? newCode) {
    if (newCode != null) {
      DateTime dateTime = DateTime.parse(newCode);
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      String formattedDateStr = outputFormat.format(dateTime);
      apiToDate = formattedDateStr;
      print('test apiToDate: $apiToDate');
    } else {
      apiFromDate = null;
    }
    notifyListeners();

  }

  int? get getApiBranchId => apiBranchId;
  set getApiBranchId(int? newCode) {
    apiBranchId = newCode;
    _notifyListeners();
  }

  int? get getApiStatusTypeId => apiStatusTypeId;
  set getApiStatusTypeId(int? newCode) {
    apiStatusTypeId = newCode;
    _notifyListeners();
  }

  List<Statusmodel> prostatus = [];
  int selectedstatusIndex = 0;
  List<Statusmodel> get storeIntostatusProvider => prostatus;
  int? _selectedStatus;

  List<Statusmodel> probranches = [];
  int selectedbranchesIndex = 0;
  List<Statusmodel> get storeIntobranchProvider => probranches;
  int? _selectedbranch;

  set storeIntoProvider(List<MyAppointment_Model> products) {
    proAppointments.clear();
    proAppointments = products;
    _notifyListeners();
  }

  void filterProviderData(List<MyAppointment_Model> items) {
    proAppointments = List<MyAppointment_Model>.from(items);
    _notifyListeners();
  }

  void clearFilter() {
    // final DateTime currentDate = DateTime.now();
    // final DateTime threeMonthsAgo = DateTime(currentDate.year, currentDate.month - 3, currentDate.day);
    //
    // final String formattedFromDate = DateFormat('yyyy-MM-dd').format(threeMonthsAgo);
    // final String formattedToDate = DateFormat('yyyy-MM-dd').format(currentDate);
    displayDate = 'Select Date';
    selectedStatus = 0;
    selectedBranch = 0;
    getApiFromDate = null;
    getApiToDate = null;
    getApiStatusTypeId = null;
    filterStatus = false;
    _notifyListeners();
  }

  int? get getbranch => _selectedbranch;
  set getbranch(int? newCategory) {
    _selectedbranch = newCategory;
    _notifyListeners();
  }

  int get selectedBranch => selectedbranchesIndex;
  set selectedBranch(int newStatus) {
    selectedbranchesIndex = newStatus;
    _notifyListeners();
  }

  int get selectedstatus => selectedstatusIndex;
  set selectedStatus(int newStatus) {
    selectedstatusIndex = newStatus;
    _notifyListeners();
  }

  int? get getStatus => _selectedStatus;
  set getStatus(int? newCategory) {
    _selectedStatus = newCategory;
    _notifyListeners();
  }

  void _notifyListeners() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}

class Statusmodel {
  final int? typeCdId;
  final String desc;

  Statusmodel({required this.typeCdId, required this.desc});

  factory Statusmodel.fromJson(Map<String, dynamic> json) {
    return Statusmodel(
      typeCdId: json['typeCdId'] ?? 0,
      desc: json['desc'] ?? '',
    );
  }
}
