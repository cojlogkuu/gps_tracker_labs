import 'package:dio/dio.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/network/dio_client.dart';

abstract class ILocationRepository {
  Future<void> postLocation({
    required String deviceId,
    required double latitude,
    required double longitude,
  });
}

/// Persists a location to the NestJS backend.
/// Silently ignores offline errors — MQTT events are best-effort.
class ApiLocationRepository implements ILocationRepository {
  final Dio _dio;

  ApiLocationRepository({Dio? dio}) : _dio = dio ?? DioClient.instance;

  @override
  Future<void> postLocation({
    required String deviceId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _dio.post<void>(
        '/locations',
        data: {
          'deviceId': deviceId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const OfflineException();
      }
      rethrow;
    }
  }
}
