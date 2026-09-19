import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'api_client.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserFetchResult {
  final List<UserModel> users;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  const UserFetchResult({
    required this.users,
    this.totalCount = 0,
    this.totalPages = 1,
    this.currentPage = 1,
  });
}

class UserService {
  final AuthService _authService = Get.find<AuthService>();
  static const String _allUsersUrl = 'https://uapi.ureka.dev/review/v1/user/all-user';

  /// Fetch users list from API with pagination (page, limit) and search parameters.
  Future<UserFetchResult> fetchUsers({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final token = await _authService.getToken();

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final uri = Uri.parse(_allUsersUrl).replace(queryParameters: queryParams);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('--> GET $uri');
      debugPrint('Headers: $headers');

      final response = await ApiClient.get(uri, headers: headers);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          List<dynamic> rawList = [];
          int totalCount = 0;
          int totalPages = 1;
          int currentPage = page;

          if (data is List) {
            rawList = data;
            totalCount = rawList.length;
          } else if (data is Map<String, dynamic>) {
            if (data['items'] != null && data['items'] is List) {
              rawList = data['items'] as List;
            } else if (data['users'] != null && data['users'] is List) {
              rawList = data['users'] as List;
            }
            if (data['pagination'] != null && data['pagination'] is Map) {
              final pag = data['pagination'] as Map;
              totalCount = pag['totalCount'] ?? rawList.length;
              totalPages = pag['totalPages'] ?? 1;
              currentPage = pag['currentPage'] ?? page;
            } else {
              totalCount = data['totalCount'] ?? rawList.length;
              totalPages = data['totalPages'] ?? 1;
            }
          }

          final parsedUsers = rawList.map((item) {
            return UserModel.fromJson(Map<String, dynamic>.from(item as Map));
          }).toList();

          return UserFetchResult(
            users: parsedUsers,
            totalCount: totalCount,
            totalPages: totalPages,
            currentPage: currentPage,
          );
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch users');
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Reset password for a specific user ID
  Future<Map<String, dynamic>> resetUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      final token = await _authService.getToken();
      final url = 'https://uapi.ureka.dev/review/v1/user/$userId/reset-password';
      final uri = Uri.parse(url);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode({
        'newPassword': newPassword,
      });

      debugPrint('--> POST $uri');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await ApiClient.post(uri, headers: headers, body: body);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true || responseData['data'] != null) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to reset password');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error resetting user password: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Update user details by ID using PATCH https://uapi.ureka.dev/review/v1/user/$userId
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final token = await _authService.getToken();
      final url = 'https://uapi.ureka.dev/review/v1/user/$userId';
      final uri = Uri.parse(url);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = jsonEncode(updateData);

      debugPrint('--> PATCH $uri');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await ApiClient.patch(uri, headers: headers, body: body);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true || responseData['data'] != null) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update user');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Delete user by ID using PATCH https://uapi.ureka.dev/review/v1/user/$userId/delete
  Future<Map<String, dynamic>> deleteUser({
    required String userId,
  }) async {
    try {
      final token = await _authService.getToken();
      final url = 'https://uapi.ureka.dev/review/v1/user/$userId/delete';
      final uri = Uri.parse(url);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('--> PATCH $uri');
      debugPrint('Headers: $headers');

      final response = await ApiClient.patch(uri, headers: headers);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true || responseData['data'] != null) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to delete user');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}

