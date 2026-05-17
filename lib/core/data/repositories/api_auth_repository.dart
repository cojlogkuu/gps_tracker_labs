import 'package:dio/dio.dart';
import 'package:gps_tracker/core/data/models/user_model.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
import 'package:gps_tracker/core/network/dio_client.dart';

/// Thrown when the device has no internet connection.
class OfflineException implements Exception {
  const OfflineException();
}

/// API-backed auth repository. On connection errors it throws
/// [OfflineException] so that [AuthProvider] can fall back to the local cache.
class ApiAuthRepository {
  final Dio _dio;
  final IAuthRepository _cache;

  ApiAuthRepository({required IAuthRepository cache, Dio? dio})
    : _dio = dio ?? DioClient.instance,
      _cache = cache;

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'fullName': fullName, 'email': email, 'password': password},
      );
      final token = res.data!['access_token'] as String;
      await _cache.saveToken(token);
      // register returns only the token; login to get the full user object
      return login(email: email, password: password);
    } on DioException catch (e) {
      if (_isOffline(e)) throw const OfflineException();
      rethrow;
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final token = res.data!['access_token'] as String;
      final user = UserModel.fromJson(
        res.data!['user'] as Map<String, dynamic>,
      );
      await _cache.saveToken(token);
      await _cache.saveUser(user);
      return user;
    } on DioException catch (e) {
      if (_isOffline(e)) throw const OfflineException();
      rethrow;
    }
  }

  Future<void> updateBaseCoords(double lat, double lng) async {
    try {
      await _dio.put<void>(
        '/users/base-coordinates',
        data: {'baseLatitude': lat, 'baseLongitude': lng},
      );
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
