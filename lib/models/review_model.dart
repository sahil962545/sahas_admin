import '../utils/string_extensions.dart';
import 'unit_model.dart';

class ReviewModel {
  final String id;
  final String name;
  final String mobile;
  final String review;
  final String sentiment;
  final UnitModel? unit;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.review,
    this.sentiment = '',
    this.unit,
    required this.createdAt,
  });

  /// Returns capitalized user name
  String get formattedName => name.capitalizeFirstLetter();

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    UnitModel? parsedUnit;
    if (json['unit'] != null && json['unit'] is Map<String, dynamic>) {
      parsedUnit = UnitModel.fromJson(json['unit'] as Map<String, dynamic>);
    }

    final userObj = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;

    final String parsedName =
        userObj?['name']?.toString() ?? json['name']?.toString() ?? '';

    final String parsedMobile =
        userObj?['mobile']?.toString() ?? json['mobile']?.toString() ?? '';

    final String parsedSentiment = json['sentiment']?.toString() ?? '';

    DateTime parsedDate;
    if (json['createdAt'] != null) {
      parsedDate =
          DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: parsedName,
      mobile: parsedMobile,
      review: json['review']?.toString() ?? '',
      sentiment: parsedSentiment,
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
      'sentiment': sentiment,
      'unit': unit?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedSentiment {
    final s = sentiment.trim().toLowerCase();
    if (s == 'happy') return 'Happy 😊';
    if (s == 'unhappy') return 'Unhappy 🙁';
    if (s == 'emergency') return 'Emergency 🚨';
    if (s.isNotEmpty) return s.toUpperCase();
    return '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
