import 'package:flutter/foundation.dart';
import 'package:gps_tracker/core/data/models/user_model.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _cache;
  final ApiAuthRepository _api;

  bool _isAuthenticated = false;
  UserModel? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  AuthProvider({required IAuthRepository cache, required ApiAuthRepository api})
    : _cache = cache,
      _api = api;

  /// Auto-login: reads token + user from local cache — no network needed.
  Future<void> tryAutoLogin() async {
    final token = await _cache.getToken();
    if (token == null) return;
    _currentUser = await _cache.getUser();
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Throws DioException (API error) or OfflineException (no net).
    final user = await _api.login(email: email, password: password);
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await _api.register(
      fullName: fullName,
      email: email,
      password: password,
    );
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> updateBaseCoords(double lat, double lng) async {
    await _api.updateBaseCoords(lat, lng);
    if (_currentUser != null) {
      _currentUser = UserModel(
        id: _currentUser!.id,
        fullName: _currentUser!.fullName,
        email: _currentUser!.email,
        baseLatitude: lat,
        baseLongitude: lng,
      );
      await _cache.saveUser(_currentUser!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _cache.clear();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
