import 'package:gps_tracker/core/data/models/coordinate_model.dart';

class DeviceModel {
  final String id;
  final String name;
  final List<CoordinateModel> coordinates;
  final double? latestLatitude;
  final double? latestLongitude;
  final DateTime? latestTimestamp;

  const DeviceModel({
    required this.id,
    required this.name,
    this.coordinates = const [],
    this.latestLatitude,
    this.latestLongitude,
    this.latestTimestamp,
  });

  DeviceModel copyWith({
    String? id,
    String? name,
    List<CoordinateModel>? coordinates,
    double? latestLatitude,
    double? latestLongitude,
    DateTime? latestTimestamp,
  }) => DeviceModel(
    id: id ?? this.id,
    name: name ?? this.name,
    coordinates: coordinates ?? this.coordinates,
    latestLatitude: latestLatitude ?? this.latestLatitude,
    latestLongitude: latestLongitude ?? this.latestLongitude,
    latestTimestamp: latestTimestamp ?? this.latestTimestamp,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coords': coordinates.map((c) => c.toJson()).toList(),
    'latLat': latestLatitude,
    'latLng': latestLongitude,
    'latTs': latestTimestamp?.toIso8601String(),
  };

  factory DeviceModel.fromJson(Map<String, dynamic> j) => DeviceModel(
    id: j['id'] as String,
    name: j['name'] as String,
    coordinates: (j['coords'] as List? ?? [])
        .map((e) => CoordinateModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    latestLatitude: (j['latLat'] as num?)?.toDouble(),
    latestLongitude: (j['latLng'] as num?)?.toDouble(),
    latestTimestamp: j['latTs'] != null
        ? DateTime.parse(j['latTs'] as String)
        : null,
  );

  /// Construct from API device + optional latest-location response.
  factory DeviceModel.fromApiJson(
    Map<String, dynamic> device,
    Map<String, dynamic>? location,
  ) => DeviceModel(
    id: device['id'] as String,
    name: device['name'] as String,
    latestLatitude: (location?['latitude'] as num?)?.toDouble(),
    latestLongitude: (location?['longitude'] as num?)?.toDouble(),
    latestTimestamp: location != null
        ? DateTime.parse(location['createdAt'] as String)
        : null,
  );
}
