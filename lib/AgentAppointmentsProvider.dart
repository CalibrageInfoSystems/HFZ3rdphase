import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Appointment.dart';

class AgentAppointmentsProvider extends ChangeNotifier {
  List<Appointment> proAppointments = [];

  int selectedCategoryIndex = 0;
  int? _selectedCategory;
  String displayDate = 'Select Date';
  String? apiFromDate;
  String? apiToDate;
  int? apiBranchId;
  int? apiStatusTypeId;
  bool isFilterApplied = false;
  List<Appointment> filteredAppointments = [];

  List<Appointment> get storeIntoProvider => proAppointments;

  // Method to update filtered data
  void updateFilteredData(List<Appointment> data) {
    filteredAppointments = data;
    notifyListeners();
  }

  set storeIntoProvider(List<Appointment> products) {
    proAppointments = products;
    notifyListeners();
  }

  void filterProviderData(List<Appointment> items) {
    proAppointments = List<Appointment>.from(items);
    notifyListeners();
  }

  bool get filterStatus => isFilterApplied;
  set filterStatus(bool newStatus) {
    isFilterApplied = newStatus;
    notifyListeners();
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
    notifyListeners();
  }

  int? get getApiStatusTypeId => apiStatusTypeId;
  set getApiStatusTypeId(int? newCode) {
    apiStatusTypeId = newCode;
    notifyListeners();
  }

  List<Statusmodel> prostatus = [];
  int selectedstatusIndex = 0;
  List<Statusmodel> get storeIntostatusProvider => prostatus;
  int? _selectedStatus;

  List<Statusmodel> probranches = [];
  int selectedbranchesIndex = 0;
  List<Statusmodel> get storeIntobranchProvider => probranches;
  int? _selectedbranch;

  void clearFilter() {
    displayDate = 'Select Date';
    selectedStatus = 0;
    selectedBranch = 0;
    apiFromDate = null;
    apiToDate = null;
    filterStatus = false;
    apiStatusTypeId = null;
    notifyListeners();
  }

  int? get getbranch => _selectedbranch;
  set getbranch(int? newCategory) {
    _selectedbranch = newCategory;
    notifyListeners();
  }

  int get selectedBranch => selectedbranchesIndex;
  set selectedBranch(int newStatus) {
    selectedbranchesIndex = newStatus;
    notifyListeners();
  }

  int get selectedstatus => selectedstatusIndex;
  set selectedStatus(int newStatus) {
    selectedstatusIndex = newStatus;
    notifyListeners();
  }

  int? get getStatus => _selectedStatus;
  set getStatus(int? newCategory) {
    _selectedStatus = newCategory;
    notifyListeners();
  }

  // Future<void> fetchAppointments() async {
  //   // Fetch data from API
  //   List<Appointment> fetchedAppointments = await apiData; // Replace with actual API call
  //   proAppointments = fetchedAppointments;
  //   notifyListeners();
  // }
}

class Statusmodel {
  final int? typeCdId;
  final String desc;

  Statusmodel.StatusModel({required this.typeCdId, required this.desc});

  factory Statusmodel.fromJson(Map<String, dynamic> json) {
    return Statusmodel.StatusModel(
      typeCdId: json['typeCdId'] ?? 0,
      desc: json['desc'] ?? '',
    );
  }
}
