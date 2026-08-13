import 'package:hive_flutter/hive_flutter.dart';
import '../models/sahas_report.dart';

class StorageService {
  static const String _boxName = 'sahas_reports_box';

  /// Initialize Hive and open the box
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  Box get _box => Hive.box(_boxName);

  /// Fetch all cached reports
  List<SahasReport> getReports() {
    try {
      final List<dynamic> rawList = _box.values.toList();
      return rawList.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return SahasReport.fromJson(map);
      }).toList();
    } catch (e) {
      // In case of parsing errors or corrupt box data, return empty list
      return [];
    }
  }

  /// Cache a single report
  Future<void> saveReport(SahasReport report) async {
    await _box.put(report.id, report.toJson());
  }

  /// Cache a list of reports in bulk
  Future<void> saveReports(List<SahasReport> reports) async {
    final Map<String, Map<String, dynamic>> data = {};
    for (final report in reports) {
      data[report.id] = report.toJson();
    }
    if (data.isNotEmpty) {
      await _box.putAll(data);
    }
  }

  /// Clear all cached reports
  Future<void> clearAll() async {
    await _box.clear();
  }
}
