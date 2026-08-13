class UnitModel {
  final String id;
  final String name;

  const UnitModel({
    required this.id,
    required this.name,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
