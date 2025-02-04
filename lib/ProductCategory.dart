class ProductCategory {
  final int ? typecdid;
  final String desc;

  ProductCategory({required this.typecdid, required this.desc});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      typecdid: json['typecdid'],
      desc: json['desc'],
    );
  }
}