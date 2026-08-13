import 'unit_model.dart';

class ReviewModel {
  final String id;
  final String name;
  final String mobile;
  final String review;
  final UnitModel? unit;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.review,
    this.unit,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    UnitModel? parsedUnit;
    if (json['unit'] != null && json['unit'] is Map<String, dynamic>) {
      parsedUnit = UnitModel.fromJson(json['unit'] as Map<String, dynamic>);
    }

    DateTime parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      review: json['review']?.toString() ?? '',
      unit: parsedUnit,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'mobile': mobile,
      'review': review,
      'unit': unit?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
