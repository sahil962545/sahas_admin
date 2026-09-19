class UnitSentimentModel {
  final String id;
  final String unitName;
  final int happy;
  final int unhappy;
  final int emergency;

  const UnitSentimentModel({
    required this.id,
    required this.unitName,
    required this.happy,
    required this.unhappy,
    required this.emergency,
  });

  factory UnitSentimentModel.fromJson(Map<String, dynamic> json) {
    final sentiment = json['sentiment'] as Map<String, dynamic>? ?? {};
    return UnitSentimentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      unitName: (json['unitName'] ?? json['name'] ?? '').toString(),
      happy: (sentiment['happy'] as num?)?.toInt() ?? 0,
      unhappy: (sentiment['unhappy'] as num?)?.toInt() ?? 0,
      emergency: (sentiment['emergency'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'unitName': unitName,
      'sentiment': {
        'happy': happy,
        'unhappy': unhappy,
        'emergency': emergency,
      },
    };
  }
}

class DashboardModel {
  final int happy;
  final int unhappy;
  final int emergency;
  final int total;
  final List<UnitSentimentModel> units;

  const DashboardModel({
    required this.happy,
    required this.unhappy,
    required this.emergency,
    required this.total,
    this.units = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final unitRawList = json['unit'] as List<dynamic>? ?? [];
    final parsedUnits = unitRawList.map((item) {
      return UnitSentimentModel.fromJson(
          Map<String, dynamic>.from(item as Map));
    }).toList();

    return DashboardModel(
      happy: (json['happy'] as num?)?.toInt() ?? 0,
      unhappy: (json['unhappy'] as num?)?.toInt() ?? 0,
      emergency: (json['emergency'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      units: parsedUnits,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'happy': happy,
      'unhappy': unhappy,
      'emergency': emergency,
      'total': total,
      'unit': units.map((u) => u.toJson()).toList(),
    };
  }
}
