import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/dashboard_model.dart';
import '../models/review_model.dart';
import '../models/unit_model.dart';
import 'auth_service.dart';

class ReviewService {
  final AuthService _authService = Get.find<AuthService>();

  static const String _reviewListUrl = 'https://uapi.ureka.dev/review/v1/review/list';
  static const String _unitUrl = 'https://uapi.ureka.dev/review//v1/unit';
  static const String _dashboardUrl = 'https://uapi.ureka.dev/review/v1/review/dashboard';
  static const String _reviewReportUrl = 'https://uapi.ureka.dev/review/v1/review/report';
  static const String _fallbackReviewReportUrl = 'http://localhost:6002/v1/review/report';

  /// Fetch reviews from API using POST https://uapi.ureka.dev/review/v1/review/list
  Future<List<ReviewModel>> fetchReviews({
    int page = 1,
    String? unitId,
    List<String>? unitIds,
    String? sentiment,
    List<String>? sentiments,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final token = await _authService.getToken();

      final Map<String, dynamic> bodyData = {
        'page': page,
      };

      // 1. Units filter (id array) - omit if empty
      final List<String> targetIds = [];
      if (unitIds != null && unitIds.isNotEmpty) {
        targetIds.addAll(unitIds.where((id) => id.trim().isNotEmpty));
      } else if (unitId != null && unitId.trim().isNotEmpty) {
        targetIds.add(unitId.trim());
      }
      if (targetIds.isNotEmpty) {
        bodyData['id'] = targetIds;
      }

      // 2. Sentiments filter (sentiment array) - omit if empty
      final List<String> targetSentiments = [];
      if (sentiments != null && sentiments.isNotEmpty) {
        targetSentiments.addAll(sentiments.where((s) => s.trim().isNotEmpty));
      } else if (sentiment != null && sentiment.trim().isNotEmpty) {
        targetSentiments.add(sentiment.trim());
      }
      if (targetSentiments.isNotEmpty) {
        bodyData['sentiment'] = targetSentiments;
      }

      // 3. fromDate filter - omit if empty
      if (fromDate != null && fromDate.trim().isNotEmpty) {
        bodyData['fromDate'] = fromDate.trim();
      }

      // 4. toDate filter - omit if empty
      if (toDate != null && toDate.trim().isNotEmpty) {
        bodyData['toDate'] = toDate.trim();
      }

      final uri = Uri.parse(_reviewListUrl);

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      debugPrint('--> POST $uri');
      debugPrint('Headers: $headers');
      debugPrint('Body Payload: ${jsonEncode(bodyData)}');

      final response = await ApiClient.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyData),
      );

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

      final response = await ApiClient.get(uri, headers: headers);

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

  /// Fetch dashboard metrics from API with optional filters (unit, sentiment, fromDate, toDate).
  Future<DashboardModel> fetchDashboard({
    String? unitId,
    List<String>? unitIds,
    String? sentiment,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final token = await _authService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final Map<String, String> queryParams = {};

      if (unitIds != null && unitIds.isNotEmpty) {
        queryParams['unit'] = jsonEncode(unitIds);
      } else if (unitId != null && unitId.trim().isNotEmpty) {
        queryParams['unit'] = unitId.trim();
      }

      if (sentiment != null && sentiment.trim().isNotEmpty) {
        queryParams['sentiment'] = sentiment.trim();
      }

      if (fromDate != null && fromDate.trim().isNotEmpty) {
        queryParams['fromDate'] = fromDate.trim();
      }

      if (toDate != null && toDate.trim().isNotEmpty) {
        queryParams['toDate'] = toDate.trim();
      }

      final uri = queryParams.isNotEmpty
          ? Uri.parse(_dashboardUrl).replace(queryParameters: queryParams)
          : Uri.parse(_dashboardUrl);

      debugPrint('--> GET $uri');
      debugPrint('Headers: $headers');

      final response = await ApiClient.get(uri, headers: headers);

      debugPrint('<-- ${response.statusCode} $uri');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return DashboardModel.fromJson(
              Map<String, dynamic>.from(responseData['data'] as Map));
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to fetch dashboard metrics');
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
            responseData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
      rethrow;
    }
  }

  /// Delete review by ID using PATCH https://uapi.ureka.dev/review/v1/review/$reviewId/delete
  Future<Map<String, dynamic>> deleteReview({
    required String reviewId,
  }) async {
    try {
      final token = await _authService.getToken();
      final url = 'https://uapi.ureka.dev/review/v1/review/$reviewId/delete';
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
          throw Exception(responseData['message'] ?? 'Failed to delete review');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting review: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Fetch Review Report PDF bytes from API using POST /v1/review/report
  Future<Uint8List> fetchReviewReport({
    String? unitId,
    List<String>? unitIds,
    String? sentiment,
    List<String>? sentiments,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final token = await _authService.getToken();

      // 1. Units filter (id array)
      final List<String> targetIds = [];
      if (unitIds != null && unitIds.isNotEmpty) {
        targetIds.addAll(unitIds.where((id) => id.trim().isNotEmpty));
      } else if (unitId != null && unitId.trim().isNotEmpty) {
        targetIds.add(unitId.trim());
      }

      // 2. Sentiments filter (sentiment array)
      final List<String> targetSentiments = [];
      if (sentiments != null && sentiments.isNotEmpty) {
        targetSentiments.addAll(sentiments.where((s) => s.trim().isNotEmpty));
      } else if (sentiment != null && sentiment.trim().isNotEmpty) {
        targetSentiments.add(sentiment.trim());
      }

      final Map<String, dynamic> bodyData = {
        'id': targetIds.isNotEmpty ? targetIds : [""],
        'fromDate': fromDate ?? "",
        'toDate': toDate ?? "",
        'sentiment': targetSentiments.isNotEmpty ? targetSentiments : [],
      };

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      http.Response? response;
      final Uri primaryUri = Uri.parse(_reviewReportUrl);

      debugPrint('--> POST $primaryUri');
      debugPrint('Headers: $headers');
      debugPrint('Body Payload: ${jsonEncode(bodyData)}');

      try {
        response = await ApiClient.post(
          primaryUri,
          headers: headers,
          body: jsonEncode(bodyData),
        );
      } catch (e) {
        debugPrint('Primary endpoint $_reviewReportUrl failed: $e. Trying fallback...');
        try {
          final Uri fallbackUri = Uri.parse(_fallbackReviewReportUrl);
          response = await ApiClient.post(
            fallbackUri,
            headers: headers,
            body: jsonEncode(bodyData),
          );
        } catch (fallbackErr) {
          rethrow;
        }
      }

      debugPrint('<-- ${response.statusCode} ${response.request?.url}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bytes = response.bodyBytes;

        // 1. Check for PDF header signature %PDF-
        if (bytes.length >= 4 &&
            bytes[0] == 0x25 && // %
            bytes[1] == 0x50 && // P
            bytes[2] == 0x44 && // D
            bytes[3] == 0x46) { // F
          return bytes;
        }

        // 2. Check content-type header
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.toLowerCase().contains('application/pdf') ||
            contentType.toLowerCase().contains('application/octet-stream')) {
          return bytes;
        }

        // 3. Otherwise try parsing as JSON (for base64 or URL)
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map<String, dynamic>) {
            final dataObj = responseData['data'] ?? responseData;
            if (dataObj is Map<String, dynamic>) {
              final pdfBase64 = dataObj['pdf'] ?? dataObj['base64'] ?? dataObj['file'] ?? dataObj['content'];
              if (pdfBase64 is String && pdfBase64.isNotEmpty) {
                final cleanBase64 = pdfBase64.contains(',')
                    ? pdfBase64.split(',').last
                    : pdfBase64;
                return base64Decode(cleanBase64.trim());
              }

              final pdfUrl = dataObj['url'] ?? dataObj['pdfUrl'] ?? dataObj['link'] ?? dataObj['downloadUrl'];
              if (pdfUrl is String && pdfUrl.isNotEmpty) {
                final pdfUri = Uri.parse(pdfUrl);
                final pdfResp = await ApiClient.get(pdfUri, headers: headers);
                if (pdfResp.statusCode == 200) {
                  return pdfResp.bodyBytes;
                }
              }
            }

            if (responseData['success'] == false) {
              throw Exception(responseData['message'] ?? 'Failed to generate report');
            }
          }
        } catch (jsonErr) {
          debugPrint('JSON parsing check failed/skipped: $jsonErr');
        }

        if (bytes.isNotEmpty) {
          return bytes;
        }

        throw Exception('Empty report response received from server');
      } else {
        String errorMsg = 'Server status: ${response.statusCode}';
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map && responseData.containsKey('message')) {
            errorMsg = responseData['message'];
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error in fetchReviewReport: $e');
      throw Exception(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}

