import 'package:gps_tracker/core/data/models/coordinate_model.dart';

class DeviceModel {
  final String id;
  final String name;
  final List<CoordinateModel> coordinates;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.coordinates,
  });

  DeviceModel copyWith({
    String? id,
    String? name,
    List<CoordinateModel>? coordinates,
  }) =>
      DeviceModel(
        id: id ?? this.id,
        name: name ?? this.name,
        coordinates: coordinates ?? this.coordinates,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coords': coordinates.map((c) => c.toJson()).toList(),
      };

  factory DeviceModel.fromJson(Map<String, dynamic> j) => DeviceModel(
        id: j['id'] as String,
        name: j['name'] as String,
        coordinates: (j['coords'] as List)
            .map((e) => CoordinateModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
