import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';
  static const String _nameKey = 'auth_name';
  static const String _unitKey = 'auth_unit';

  // Login API Endpoint - note the double slash as requested
  static const String _loginUrl =
      'https://uapi.ureka.dev/review//v1/user/login';
  static const String _changePasswordUrl =
      'https://uapi.ureka.dev/review/v1/user/change-password';

  /// Performs the login API request and saves the token securely if successful.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('--> POST $_loginUrl');
      debugPrint('Headers: {"Content-Type": "application/json"}');
      debugPrint('Body: {"email": "$email", "password": "$password"}');

      final response = await ApiClient.post(
        Uri.parse(_loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('<-- ${response.statusCode} $_loginUrl');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final token = data['token'];
          final role = data['role'];
          final name = data['name'];
          final unit = data['unit'];

          String unitStr = '';
          if (unit != null) {
            if (unit is Map) {
              unitStr = unit['_id']?.toString() ?? unit['id']?.toString() ?? '';
            } else {
              unitStr = unit.toString();
            }
          }

          if (token != null) {
            await _secureStorage.write(key: _tokenKey, value: token);
            await _secureStorage.write(key: _roleKey, value: role ?? '');
            await _secureStorage.write(key: _nameKey, value: name ?? '');
            await _secureStorage.write(key: _unitKey, value: unitStr);
            return responseData;
          } else {
            throw Exception('Token was not provided in the response.');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Authentication failed.');
        }
      } else {
        throw Exception(responseData['message'] ??
            'Server error status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login API error: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Retrieve the saved token from secure storage.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Retrieve the saved user role from secure storage.
  Future<String?> getRole() async {
    return await _secureStorage.read(key: _roleKey);
  }

  /// Retrieve the saved user name from secure storage.
  Future<String?> getName() async {
    return await _secureStorage.read(key: _nameKey);
  }

  /// Retrieve the saved unit from secure storage.
  Future<String?> getUnit() async {
    return await _secureStorage.read(key: _unitKey);
  }

  /// Checks if the user is currently logged in.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored credentials.
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _nameKey);
    await _secureStorage.delete(key: _unitKey);
  }

  /// Performs Change Password request.
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });

      debugPrint('--> POST $_changePasswordUrl');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await ApiClient.post(
        Uri.parse(_changePasswordUrl),
        headers: headers,
        body: body,
      );

      debugPrint('<-- ${response.statusCode} $_changePasswordUrl');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Password change failed.');
        }
      } else {
        throw Exception(responseData['message'] ??
            'Server error status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Change password API error: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}
