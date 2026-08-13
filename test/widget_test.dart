import 'package:flutter_test/flutter_test.dart';
import 'package:sahas_admin/models/sahas_report.dart';

void main() {
  group('SahasReport Parser Unit Tests', () {
    test('Successfully parses valid legacy pipe format', () {
      const String payload =
          'SAHAS|Sahil Lohiya|Happy|I am feeling good today|2026-08-05T10:30:25';
      const String sender = '+919999999999';
      const int smsTimestamp = 1722853825000;

      final report = SahasReport.fromSms(payload, sender, smsTimestamp);

      expect(report.employeeName, 'Sahil Lohiya');
      expect(report.mood, 'Happy');
      expect(report.remarks, 'I am feeling good today');
      expect(report.phoneNumber, sender);
      expect(report.receivedTime, DateTime.parse('2026-08-05T10:30:25'));
    });

    test('Successfully parses new hyphen format', () {
      const String payload = 'Sahas-Sahil Lohiya -happy-i am ok.';
      const String sender = '+919999999999';
      const int smsTimestamp = 1722853825000;

      final report = SahasReport.fromSms(payload, sender, smsTimestamp);

      expect(report.employeeName, 'Sahil Lohiya');
      expect(report.mood, 'Happy');
      expect(report.remarks, 'i am ok.');
      expect(report.phoneNumber, sender);
      expect(
        report.receivedTime,
        DateTime.fromMillisecondsSinceEpoch(smsTimestamp),
      );
    });

    test('Throws FormatException on invalid header', () {
      const String payload =
          'OTHER|Sahil Lohiya|Happy|Remarks|2026-08-05T10:30:25';
      expect(
        () => SahasReport.fromSms(payload, '+919999999999', 1722853825000),
        throwsFormatException,
      );
    });

    test('Throws FormatException on missing fields', () {
      const String payload = 'SAHAS|Sahil Lohiya|Happy';
      expect(
        () => SahasReport.fromSms(payload, '+919999999999', 1722853825000),
        throwsFormatException,
      );
    });
  });
}
