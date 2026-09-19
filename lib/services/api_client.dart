import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controllers/auth_controller.dart';

class ApiClient {
  static final http.Client _client = http.Client();

  /// Perform GET request and intercept 401 Unauthorized responses.
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(url, headers: headers);
    _check401(response);
    return response;
  }

  /// Perform POST request and intercept 401 Unauthorized responses.
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await _client.post(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    _check401(response);
    return response;
  }

  /// Perform PATCH request and intercept 401 Unauthorized responses.
  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await _client.patch(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    _check401(response);
    return response;
  }

  /// Perform DELETE request and intercept 401 Unauthorized responses.
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await _client.delete(
      url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
    _check401(response);
    return response;
  }

  /// Checks if the API response status code is 401 Unauthorized.
  /// Ignores 401 on authentication login endpoints to prevent invalid login attempt loops.
  static void _check401(http.Response response) {
    if (response.statusCode == 401) {
      final path = response.request?.url.path ?? '';
      if (path.contains('/login')) {
        return;
      }

      debugPrint(
          'HTTP 401 Unauthorized detected on ${response.request?.url}. Triggering auto-logout...');
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().handleUnauthorized();
      }
    }
  }
}
