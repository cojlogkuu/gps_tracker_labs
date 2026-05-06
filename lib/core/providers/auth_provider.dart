import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _repo;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'session_token';

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider(this._repo);

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: _tokenKey);
    _isAuthenticated = token != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final valid = await _repo.verifyCredentials(
      email: email,
      password: password,
    );
    if (valid) {
      await _storage.write(
        key: _tokenKey,
        value: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      _isAuthenticated = true;
      notifyListeners();
    }
    return valid;
  }

  Future<void> register(String name, String email, String password) async {
    await _repo.saveUser(name: name, email: email, password: password);
    await _storage.write(
      key: _tokenKey,
      value: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _isAuthenticated = false;
    notifyListeners();
  }
}
