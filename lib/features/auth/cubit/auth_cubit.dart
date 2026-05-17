import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gps_tracker/core/data/models/user_model.dart';
import 'package:gps_tracker/core/data/repositories/api_auth_repository.dart';
import 'package:gps_tracker/core/data/repositories/auth_repository.dart';
import 'package:gps_tracker/features/auth/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiAuthRepository _api;
  final IAuthRepository _cache;

  AuthCubit({required ApiAuthRepository api, required IAuthRepository cache})
    : _api = api,
      _cache = cache,
      super(const AuthInitial());

  Future<void> tryAutoLogin() async {
    try {
      final token = await _cache.getToken();
      if (token == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      final user = await _cache.getUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _api.login(email: email, password: password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _api.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateBaseCoords(double lat, double lng) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    try {
      await _api.updateBaseCoords(lat, lng);

      final updatedUser = UserModel(
        id: currentState.user.id,
        fullName: currentState.user.fullName,
        email: currentState.user.email,
        baseLatitude: lat,
        baseLongitude: lng,
      );

      await _cache.saveUser(updatedUser);
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError('Failed to update coordinates: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    await _cache.clear();
    emit(const AuthUnauthenticated());
  }
}
