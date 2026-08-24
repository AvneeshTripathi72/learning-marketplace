class CategoryModel {
  final String id;
  final String name;
  final bool isEnabled;

  CategoryModel({
    required this.id,
    required this.name,
    required this.isEnabled,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isEnabled': isEnabled,
    };
  }
}
