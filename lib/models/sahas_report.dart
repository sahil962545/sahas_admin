class SahasReport {
  final String id;
  final String employeeName;
  final String mood;
  final String remarks;
  final DateTime receivedTime;
  final String phoneNumber;
  final String originalSms;

  SahasReport({
    required this.id,
    required this.employeeName,
    required this.mood,
    required this.remarks,
    required this.receivedTime,
    required this.phoneNumber,
    required this.originalSms,
  });

  /// Factory constructor to parse a raw SMS message
  /// Supports both legacy format ("SAHAS|Name|Mood|Remarks|Timestamp")
  /// and new format ("Sahas-Name -mood-remarks").
  factory SahasReport.fromSms(String body, String sender, int smsTimestamp) {
    final cleanBody = body.trim();

    // 1. Try to parse new hyphen-separated format: Sahas-EmployeeName -mood-remarks
    if (cleanBody.toLowerCase().startsWith('sahas-')) {
      final regex = RegExp(
        r'^Sahas-(.+?)\s+-([^-]+)-([\s\S]*)$',
        caseSensitive: false,
      );
      final match = regex.firstMatch(cleanBody);
      if (match == null) {
        throw const FormatException('Malformed Sahas hyphen message format');
      }

      final employeeName = match.group(1)!.trim();
      final moodRaw = match.group(2)!.trim();
      final remarks = match.group(3)!.trim();

      if (employeeName.isEmpty) {
        throw const FormatException('Employee name is empty');
      }
      if (moodRaw.isEmpty) {
        throw const FormatException('Mood is empty');
      }

      // Capitalize first letter of mood (e.g. happy -> Happy, unhappy -> Unhappy)
      final mood =
          moodRaw[0].toUpperCase() + moodRaw.substring(1).toLowerCase();
      final id = '${smsTimestamp}_${sender}_$cleanBody';

      return SahasReport(
        id: id,
        employeeName: employeeName,
        mood: mood,
        remarks: remarks,
        receivedTime: DateTime.fromMillisecondsSinceEpoch(smsTimestamp),
        phoneNumber: sender,
        originalSms: cleanBody,
      );
    }

    // 2. Try to parse legacy pipe-separated format: SAHAS|Employee Name|Mood|Remarks|Timestamp
    if (cleanBody.toUpperCase().startsWith('SAHAS|')) {
      final parts = cleanBody.split('|');
      if (parts.length < 5) {
        throw FormatException(
          'Malformed SAHAS message: expected at least 5 segments, got ${parts.length}',
        );
      }

      final header = parts[0].trim();
      if (header.toUpperCase() != 'SAHAS') {
        throw FormatException(
          'Malformed SAHAS message: invalid header "$header"',
        );
      }

      final employeeName = parts[1].trim();
      if (employeeName.isEmpty) {
        throw const FormatException(
          'Malformed SAHAS message: employee name is empty',
        );
      }

      final moodRaw = parts[2].trim();
      if (moodRaw.isEmpty) {
        throw const FormatException('Malformed SAHAS message: mood is empty');
      }
      final mood =
          moodRaw[0].toUpperCase() + moodRaw.substring(1).toLowerCase();

      // Extract timestamp from the last segment
      final timestampStr = parts.last.trim();
      DateTime? parsedTime = DateTime.tryParse(timestampStr);

      // Everything between mood and the last segment (timestamp) constitutes the remarks
      final remarks = parts.sublist(3, parts.length - 1).join('|').trim();
      final id = '${smsTimestamp}_${sender}_$cleanBody';

      return SahasReport(
        id: id,
        employeeName: employeeName,
        mood: mood,
        remarks: remarks,
        receivedTime:
            parsedTime ?? DateTime.fromMillisecondsSinceEpoch(smsTimestamp),
        phoneNumber: sender,
        originalSms: cleanBody,
      );
    }

    throw const FormatException('Unknown SAHAS message format');
  }

  /// Create a SahasReport from a JSON Map
  factory SahasReport.fromJson(Map<String, dynamic> json) {
    return SahasReport(
      id: json['id'] as String,
      employeeName: json['employeeName'] as String,
      mood: json['mood'] as String,
      remarks: json['remarks'] as String,
      receivedTime: DateTime.parse(json['receivedTime'] as String),
      phoneNumber: json['phoneNumber'] as String,
      originalSms: json['originalSms'] as String,
    );
  }

  /// Convert SahasReport to JSON Map for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeName': employeeName,
      'mood': mood,
      'remarks': remarks,
      'receivedTime': receivedTime.toIso8601String(),
      'phoneNumber': phoneNumber,
      'originalSms': originalSms,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SahasReport &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
