import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gps_tracker/core/data/models/coordinate_model.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/api_device_repository.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/core/data/repositories/location_repository.dart';
import 'package:gps_tracker/core/providers/mqtt_setup.dart';
import 'package:gps_tracker/core/utils/haversine.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';

class MqttProvider extends ChangeNotifier {
  final IDeviceRepository _localRepo;
  final ApiDeviceRepository _apiRepo;
  final ILocationRepository _locationRepo;
  MqttClient? _client;

  List<DeviceModel> _devices = [];
  double? _baseLat;
  double? _baseLng;

  List<DeviceModel> get devices => _devices;
  double? get baseLat => _baseLat;
  double? get baseLng => _baseLng;

  MqttProvider({
    required IDeviceRepository localRepo,
    required ApiDeviceRepository apiRepo,
    required ILocationRepository locationRepo,
  }) : _localRepo = localRepo,
       _apiRepo = apiRepo,
       _locationRepo = locationRepo {
    _load();
  }

  Future<void> _load() async {
    final coords = await _localRepo.loadBaseCoords();
    _devices = await _localRepo.loadDevices();
    if (coords != null) {
      _baseLat = coords.$1;
      _baseLng = coords.$2;
    }
    notifyListeners();
    _connect();
  }

  Future<void> _connect() async {
    _client = setupMqttClient();
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT connect error: $e');
      _client!.disconnect();
      return;
    }
    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.subscribe('tracker/devices/location', MqttQos.atLeastOnce);
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final msg = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          msg.payload.message,
        );
        _handleMessage(payload);
      });
    }
  }

  /// CRITICAL: silently drop messages if base coords are not set.
  void _handleMessage(String payload) {
    if (_baseLat == null || _baseLng == null) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final lat = (data['lat'] as num).toDouble();
      final lng = (data['lng'] as num).toDouble();
      final deviceId = data['device_id'] as String;
      _addCoordinate(deviceId, lat, lng);
    } catch (e) {
      debugPrint('MQTT parse error: $e');
    }
  }

  Future<void> setBase(double lat, double lng) async {
    await _localRepo.saveBaseCoords(lat, lng);
    _baseLat = lat;
    _baseLng = lng;
    notifyListeners();
  }

  Future<void> _addCoordinate(String deviceId, double lat, double lng) async {
    final dist = haversineDistance(_baseLat!, _baseLng!, lat, lng);
    final coord = CoordinateModel(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      distance: dist,
    );
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index >= 0) {
      final ex = _devices[index];
      _devices[index] = ex.copyWith(
        coordinates: [...ex.coordinates, coord],
        latestLatitude: lat,
        latestLongitude: lng,
        latestTimestamp: coord.timestamp,
      );
    } else {
      _devices.add(
        DeviceModel(
          id: deviceId,
          name: 'Device ${_devices.length + 1}',
          coordinates: [coord],
          latestLatitude: lat,
          latestLongitude: lng,
          latestTimestamp: coord.timestamp,
        ),
      );
    }
    await _localRepo.saveDevices(_devices);
    notifyListeners();
    // Fire-and-forget: POST to backend; offline errors are silently ignored.
    _locationRepo
        .postLocation(deviceId: deviceId, latitude: lat, longitude: lng)
        .catchError((_) {});
  }

  void publishCoordinate(String deviceId, double lat, double lng) {
    _addCoordinate(deviceId, lat, lng);
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final b = MqttClientPayloadBuilder()
        ..addString(
          jsonEncode({
            'device_id': deviceId,
            'lat': lat,
            'lng': lng,
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      _client!.publishMessage(
        'tracker/devices/location',
        MqttQos.atLeastOnce,
        b.payload!,
      );
    }
  }

  Future<void> createDevice(String name) async {
    try {
      final device = await _apiRepo.createDevice(
        name.isEmpty ? 'Device ${_devices.length + 1}' : name,
      );
      _devices.add(device);
    } on OfflineException {
      // Offline fallback: create locally with a temporary UUID.
      _devices.add(
        DeviceModel(
          id: const Uuid().v4(),
          name: name.isEmpty ? 'Device ${_devices.length + 1}' : name,
        ),
      );
    }
    await _localRepo.saveDevices(_devices);
    notifyListeners();
  }

  Future<void> deleteDevice(String deviceId) async {
    _devices.removeWhere((d) => d.id == deviceId);
    await _localRepo.saveDevices(_devices);
    notifyListeners();
  }

  @override
  void dispose() {
    _client?.disconnect();
    super.dispose();
  }
}
