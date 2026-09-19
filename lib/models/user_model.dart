import '../utils/string_extensions.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String mobile;
  final String role;
  final String unitId;
  final String unitName;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.mobile,
    required this.role,
    this.unitId = '',
    this.unitName = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String parsedUnitId = '';
    String parsedUnitName = '';

    if (json['unit'] != null) {
      if (json['unit'] is Map<String, dynamic>) {
        final uMap = json['unit'] as Map<String, dynamic>;
        parsedUnitId = uMap['_id']?.toString() ?? uMap['id']?.toString() ?? '';
        parsedUnitName = uMap['unitName']?.toString() ?? uMap['name']?.toString() ?? '';
      } else {
        parsedUnitId = json['unit'].toString();
      }
    }

    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      unitId: parsedUnitId,
      unitName: parsedUnitName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'mobile': mobile,
      'role': role,
      'unit': unitId,
    };
  }

  bool get isAdmin => role.trim().toLowerCase() == 'admin';

  /// Returns user's name with first letter of each word capitalized
  String get formattedName => name.capitalizeFirstLetter();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
