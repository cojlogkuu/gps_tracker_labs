import 'package:dio/dio.dart';
import 'package:gps_tracker/core/data/models/device_model.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/device_repository.dart';
import 'package:gps_tracker/core/network/dio_client.dart';

/// API-backed device repository.
/// Fetches devices and their latest locations, then caches the result locally.
/// Throws [OfflineException] on connection errors so callers can fall back.
class ApiDeviceRepository {
  final Dio _dio;
  final IDeviceRepository _cache;

  ApiDeviceRepository({required IDeviceRepository cache, Dio? dio})
    : _dio = dio ?? DioClient.instance,
      _cache = cache;

  Future<List<DeviceModel>> fetchDevices() async {
    try {
      final res = await _dio.get<List<dynamic>>('/devices');
      final devices = await Future.wait(
        (res.data ?? []).map((raw) async {
          final device = raw as Map<String, dynamic>;
          final id = device['id'] as String;
          Map<String, dynamic>? location;
          try {
            final loc = await _dio.get<Map<String, dynamic>>(
              '/devices/$id/latest-location',
            );
            location = loc.data;
          } on DioException {
            location = null; // no location yet — not an error
          }
          return DeviceModel.fromApiJson(device, location);
        }),
      );
      await _cache.saveDevices(devices);
      return devices;
    } on DioException catch (e) {
      if (_isOffline(e)) throw const OfflineException();
      rethrow;
    }
  }

  Future<DeviceModel> createDevice(String name) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/devices',
        data: {'name': name},
      );
      return DeviceModel.fromApiJson(res.data!, null);
    } on DioException catch (e) {
      if (_isOffline(e)) throw const OfflineException();
      rethrow;
    }
  }

  bool _isOffline(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout;
}
