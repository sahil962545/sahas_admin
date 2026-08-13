import '../models/sahas_report.dart';
import '../services/sms_service.dart';
import '../services/storage_service.dart';

class ReportRepository {
  final SmsService _smsService;
  final StorageService _storageService;

  ReportRepository({
    required SmsService smsService,
    required StorageService storageService,
  }) : _smsService = smsService,
       _storageService = storageService;

  /// Fetches reports from local storage cache
  List<SahasReport> getCachedReports() {
    final reports = _storageService.getReports();
    // Sort newest reports first
    reports.sort((a, b) => b.receivedTime.compareTo(a.receivedTime));
    return reports;
  }

  /// Syncs inbox SMS messages:
  /// Reads inbox, filters for SAHAS reports, parses only new/uncached messages,
  /// saves them to local cache, and returns the merged list (newest first).
  Future<List<SahasReport>> syncInboxReports() async {
    try {
      // 1. Get already cached reports
      final cachedReports = _storageService.getReports();
      final Map<String, SahasReport> cachedMap = {
        for (var r in cachedReports) r.id: r,
      };

      // 2. Fetch SMS messages from the device
      final inboxSmsList = await _smsService.fetchInboxSms();

      final List<SahasReport> newlyParsedReports = [];
      int parsingErrorsCount = 0;

      // 3. Process inbox messages
      for (final sms in inboxSmsList) {
        final body = sms.body ?? '';
        final sender = sms.address ?? 'Unknown';
        final timestamp = sms.date ?? DateTime.now().millisecondsSinceEpoch;

        // Only look at messages starting with "SAHAS|" or "Sahas-" case-insensitively
        final cleanBody = body.trim().toLowerCase();
        if (!cleanBody.startsWith('sahas|') &&
            !cleanBody.startsWith('sahas-')) {
          continue;
        }

        // Unique ID representation
        final uniqueId = '${timestamp}_${sender}_${body.trim()}';

        // Check if report has already been cached / processed
        if (cachedMap.containsKey(uniqueId)) {
          continue; // Already processed, ignore to avoid reparsing
        }

        try {
          // Parse report
          final report = SahasReport.fromSms(body, sender, timestamp);
          newlyParsedReports.add(report);
          cachedMap[uniqueId] =
              report; // Add to map to prevent duplicate in batch
        } catch (e) {
          parsingErrorsCount++;
          print('Skipping malformed SMS from $sender. Error: $e');
        }
      }

      // 4. Save newly parsed reports to Hive cache
      if (newlyParsedReports.isNotEmpty) {
        await _storageService.saveReports(newlyParsedReports);
        print(
          'Successfully cached ${newlyParsedReports.isNotEmpty} new reports. Parsing errors skipped: $parsingErrorsCount',
        );
      }

      // 5. Return all reports sorted by received time (newest first)
      final allReports = cachedMap.values.toList();
      allReports.sort((a, b) => b.receivedTime.compareTo(a.receivedTime));
      return allReports;
    } catch (e) {
      print('Error syncing inbox reports: $e');
      rethrow;
    }
  }

  /// Save an incoming live report to Hive cache
  Future<void> saveReport(SahasReport report) async {
    await _storageService.saveReport(report);
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _storageService.clearAll();
  }
}
