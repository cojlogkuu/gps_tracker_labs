// ignore_for_file: lines_longer_than_80_chars
// dart format off
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gps_tracker/core/data/models/coordinate_model.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/core/providers/mqtt_setup.dart';
import 'package:gps_tracker/core/utils/haversine.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum BrokerEnvironment { local, hiveMQ }

class MqttProvider extends ChangeNotifier {
  final IDeviceRepository _repo;
  MqttClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updatesSubscription;
  List<DeviceModel> _devices = [];
  double? _baseLat, _baseLng;
  BrokerEnvironment _environment = BrokerEnvironment.local;

  List<DeviceModel> get devices => _devices;
  double? get baseLat => _baseLat;
  double? get baseLng => _baseLng;
  BrokerEnvironment get environment => _environment;
  static const _topic = 'tracker/cojlogkuu_lab/location';

  MqttProvider(this._repo) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _environment = prefs.getString('env') == 'hiveMQ' ? BrokerEnvironment.hiveMQ : BrokerEnvironment.local;
    final coords = await _repo.loadBaseCoords();
    _devices = await _repo.loadDevices();
    if (coords != null) { _baseLat = coords.$1; _baseLng = coords.$2; }
    notifyListeners();
    _connect();
  }

  String _getBrokerUrl() {
    if (_environment == BrokerEnvironment.hiveMQ) return kIsWeb ? 'ws://broker.hivemq.com/mqtt' : 'broker.hivemq.com';
    return kIsWeb ? '127.0.0.1' : (defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1');
  }

  int _getBrokerPort() => kIsWeb ? (_environment == BrokerEnvironment.hiveMQ ? 8000 : 9001) : 1883;

  Future<void> _connect() async {
    final clientId = 'flutter_${const Uuid().v4()}';
    _client = setupMqttClient(_getBrokerUrl())
      ..port = _getBrokerPort()
      ..logging(on: true)
      ..keepAlivePeriod = 60
      ..onDisconnected = () => debugPrint('MQTT: onDisconnected callback triggered');

    _client!.connectionMessage = MqttConnectMessage().withClientIdentifier(clientId).startClean();
    try {
      debugPrint('MQTT: Connecting to ${_getBrokerUrl()} (ID: $clientId)');
      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT Exception during connect: $e');
      _client!.disconnect();
      return;
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT: Connected successfully!');
      _client!.subscribe(_topic, MqttQos.atLeastOnce);
      _updatesSubscription = _client!.updates!.listen((c) {
        final payload = MqttPublishPayload.bytesToStringAsString((c[0].payload as MqttPublishMessage).payload.message);
        try {
          final data = jsonDecode(payload);
          _addCoordinate(data['device_id'] as String, (data['lat'] as num).toDouble(), (data['lng'] as num).toDouble());
        } catch (_) {}
      });
    } else {
      debugPrint('MQTT: Failed. Status: ${_client!.connectionStatus!.state}');
      _client!.disconnect();
    }
  }

  Future<void> switchEnvironment(BrokerEnvironment newEnv) async {
    if (_environment == newEnv) return;
    _environment = newEnv;
    await (await SharedPreferences.getInstance()).setString('env', newEnv.name);
    notifyListeners();

    await _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    _client = null;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await _connect();
  }

  Future<void> setBase(double lat, double lng) async {
    await _repo.saveBaseCoords(lat, lng);
    _baseLat = lat; _baseLng = lng;
    notifyListeners();
  }

  Future<void> _addCoordinate(String deviceId, double lat, double lng) async {
    final coord = CoordinateModel(
      latitude: lat, longitude: lng, timestamp: DateTime.now(),
      distance: haversineDistance(_baseLat ?? 0, _baseLng ?? 0, lat, lng),
    );
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx >= 0) {
      _devices[idx] = _devices[idx].copyWith(coordinates: [..._devices[idx].coordinates, coord]);
    } else {
      _devices.add(DeviceModel(id: deviceId, name: 'Device ${_devices.length + 1}', coordinates: [coord]));
    }
    await _repo.saveDevices(_devices);
    notifyListeners();
  }

  void publishCoordinate(String deviceId, double lat, double lng) {
    _addCoordinate(deviceId, lat, lng);
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final b = MqttClientPayloadBuilder()..addString(jsonEncode({'device_id': deviceId, 'lat': lat, 'lng': lng, 'timestamp': DateTime.now().toIso8601String()}));
      _client!.publishMessage(_topic, MqttQos.atLeastOnce, b.payload!);
    }
  }

  Future<void> createDevice(String name) async {
    _devices.add(DeviceModel(id: const Uuid().v4(), name: name.isEmpty ? 'Device ${_devices.length + 1}' : name, coordinates: []));
    await _repo.saveDevices(_devices);
    notifyListeners();
  }

  Future<void> deleteDevice(String deviceId) async {
    _devices.removeWhere((d) => d.id == deviceId);
    await _repo.saveDevices(_devices);
    notifyListeners();
  }

  @override
  void dispose() {
    _updatesSubscription?.cancel();
    _client?.disconnect();
    super.dispose();
  }
}
// dart format on
