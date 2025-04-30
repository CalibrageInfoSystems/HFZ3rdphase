// To parse this JSON data, do
//
//     final slot = slotFromJson(jsonString);

import 'dart:convert';

List<Slot> slotFromJson(String str) =>
    List<Slot>.from(json.decode(str).map((x) => Slot.fromJson(x)));

String slotToJson(List<Slot> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Slot {
  final int branchId;
  final String name;
  final DateTime date;
  final int room;
  final String slot;
  final int availableSlots;
  final String slotTimeSpan;

  Slot({
    required this.branchId,
    required this.name,
    required this.date,
    required this.room,
    required this.slot,
    required this.availableSlots,
    required this.slotTimeSpan,
  });

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        branchId: json["branchId"],
        name: json["name"],
        date: DateTime.parse(json['dates']),
        room: json["room"],
        slot: json["slot"],
        availableSlots: json["availableSlots"],
        slotTimeSpan: json["slotTimeSpan"],
      );

  Map<String, dynamic> toJson() => {
        "branchId": branchId,
        "name": name,
        "dates": date.toIso8601String(),
        "room": room,
        "slot": slot,
        "availableSlots": availableSlots,
        "slotTimeSpan": slotTimeSpan,
      };
}
