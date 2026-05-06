import 'dart:convert';

import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IDeviceRepository {
  Future<void> saveBaseCoords(double lat, double lng);
  Future<(double, double)?> loadBaseCoords();
  Future<void> saveDevices(List<DeviceModel> devices);
  Future<List<DeviceModel>> loadDevices();
  Future<void> clearAll();
}

class SharedPrefsDeviceRepository implements IDeviceRepository {
  static const _kLat = 'base_lat';
  static const _kLng = 'base_lng';
  static const _kDevices = 'devices_json';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> saveBaseCoords(double lat, double lng) async {
    final p = await _prefs;
    await p.setDouble(_kLat, lat);
    await p.setDouble(_kLng, lng);
  }

  @override
  Future<(double, double)?> loadBaseCoords() async {
    final p = await _prefs;
    final lat = p.getDouble(_kLat);
    final lng = p.getDouble(_kLng);
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  @override
  Future<void> saveDevices(List<DeviceModel> devices) async {
    final p = await _prefs;
    await p.setString(
      _kDevices,
      jsonEncode(devices.map((d) => d.toJson()).toList()),
    );
  }

  @override
  Future<List<DeviceModel>> loadDevices() async {
    final p = await _prefs;
    final raw = p.getString(_kDevices);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => DeviceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearAll() async {
    final p = await _prefs;
    await p.remove(_kLat);
    await p.remove(_kLng);
    await p.remove(_kDevices);
  }
}
