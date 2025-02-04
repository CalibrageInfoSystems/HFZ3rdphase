class CityItem {
  int? typecdid;
  String? desc;

  CityItem({
    required this.typecdid,
    required this.desc,
  });

  factory CityItem.fromJson(Map<String, dynamic> json) {
    return CityItem(
      typecdid: json['typecdid'] ?? 0,
      desc: json['desc'] ?? '',
    );
  }
}
