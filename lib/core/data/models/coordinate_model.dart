class CoordinateModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double distance;

  const CoordinateModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.distance,
  });

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
        'ts': timestamp.toIso8601String(),
        'dist': distance,
      };

  factory CoordinateModel.fromJson(Map<String, dynamic> j) => CoordinateModel(
        latitude: (j['lat'] as num).toDouble(),
        longitude: (j['lng'] as num).toDouble(),
        timestamp: DateTime.parse(j['ts'] as String),
        distance: (j['dist'] as num).toDouble(),
      );
}
