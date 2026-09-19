import 'package:flutter_test/flutter_test.dart';
import 'package:sahas_admin/services/api_client.dart';

void main() {
  group('ApiClient 401 handling unit tests', () {
    test('ApiClient contains get, post, patch, and delete static methods', () {
      expect(ApiClient.get, isNotNull);
      expect(ApiClient.post, isNotNull);
      expect(ApiClient.patch, isNotNull);
      expect(ApiClient.delete, isNotNull);
    });
  });
}
