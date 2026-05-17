import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gps_tracker/core/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clear();
}

/// Local-only implementation: token in secure storage, user in SharedPrefs.
class SharedPrefsAuthRepository implements IAuthRepository {
  static const _kUser = 'cached_user';
  static const _kToken = 'jwt_token';

  final FlutterSecureStorage _secure;
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  SharedPrefsAuthRepository({FlutterSecureStorage? storage})
    : _secure = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) =>
      _secure.write(key: _kToken, value: token);

  @override
  Future<String?> getToken() => _secure.read(key: _kToken);

  @override
  Future<void> deleteToken() => _secure.delete(key: _kToken);

  @override
  Future<void> saveUser(UserModel user) async {
    final p = await _prefs;
    await p.setString(_kUser, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final p = await _prefs;
    final raw = p.getString(_kUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clear() async {
    await _secure.delete(key: _kToken);
    final p = await _prefs;
    await p.remove(_kUser);
  }
}
