import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../models/unit_model.dart';
import 'auth_service.dart';

class ReviewService {
  final AuthService _authService = Get.find<AuthService>();

  static const String _reviewUrl = 'https://uapi.ureka.dev/review//v1/review';
  static const String _unitUrl = 'https://uapi.ureka.dev/review//v1/unit';

  /// Fetch reviews from API with optional filtering parameters (page, unit, fromDate, toDate).
  Future<List<ReviewModel>> fetchReviews({
    int page = 1,
    String? unitId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final token = await _authService.getToken();

      final Map<String, String> queryParams = {
        'page': page.toString(),
      };

      if (unitId != null && unitId.trim().isNotEmpty) {
        queryParams['unit'] = unitId.trim();
      }

      if (fromDate != null && fromDate.trim().isNotEmpty) {
        queryParams['fromDate'] = fromDate.trim();
      }

      if (toDate != null && toDate.trim().isNotEmpty) {
        queryParams['toDate'] = toDate.trim();
      }

      final uri = Uri.parse(_reviewUrl).replace(queryParameters: queryParams);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('--> GET $uri');
      debugPrint('Headers: $headers');

      final response = await http.get(uri, headers: headers);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final itemsRaw = responseData['data']['items'] as List<dynamic>? ?? [];
          return itemsRaw.map((item) {
            return ReviewModel.fromJson(Map<String, dynamic>.from(item as Map));
          }).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch reviews');
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Fetch available units list from API.
  Future<List<UnitModel>> fetchUnits() async {
    try {
      final token = await _authService.getToken();

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final uri = Uri.parse(_unitUrl);

      debugPrint('--> GET $uri');
      debugPrint('Headers: $headers');

      final response = await http.get(uri, headers: headers);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataRaw = responseData['data'] as List<dynamic>? ?? [];
          return dataRaw.map((item) {
            return UnitModel.fromJson(Map<String, dynamic>.from(item as Map));
          }).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch units');
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching units: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}
