import 'package:shared_preferences/shared_preferences.dart';

abstract class IAuthRepository {
  Future<void> saveUser({
    required String name,
    required String email,
    required String password,
  });

  Future<bool> verifyCredentials({
    required String email,
    required String password,
  });

  Future<String?> getName();
  Future<String?> getEmail();
  Future<void> updateName(String name);
  Future<void> deleteAccount();
  Future<bool> hasAccount();
}

class SharedPrefsAuthRepository implements IAuthRepository {
  static const _keyName = 'user_name';
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> saveUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  @override
  Future<bool> verifyCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await _prefs;
    final storedEmail = prefs.getString(_keyEmail);
    final storedPass = prefs.getString(_keyPassword);
    return storedEmail == email && storedPass == password;
  }

  @override
  Future<String?> getName() async {
    final prefs = await _prefs;
    return prefs.getString(_keyName);
  }

  @override
  Future<String?> getEmail() async {
    final prefs = await _prefs;
    return prefs.getString(_keyEmail);
  }

  @override
  Future<void> updateName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_keyName, name);
  }

  @override
  Future<void> deleteAccount() async {
    final prefs = await _prefs;
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
  }

  @override
  Future<bool> hasAccount() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyEmail);
  }
}
