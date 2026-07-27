import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baloga_ar_rescue/data/models/user_model.dart';
import 'package:baloga_ar_rescue/data/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) => AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthNotifier(this._service) : super(const AuthState());

  Future<bool> loadUser() async {
    state = state.copyWith(isLoading: true);
    final user = await _service.getMe();
    state = state.copyWith(user: user, isLoading: false);
    return user != null;
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.login(email, password);
      final user = UserModel.fromJson(data['user']);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      String errorMessage = 'Email atau password salah';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final resData = e.response!.data as Map;
          if (resData['message'] != null) {
            errorMessage = resData['message'].toString();
          } else if (resData['errors'] != null && resData['errors'] is Map) {
            final errors = resData['errors'] as Map;
            errorMessage = errors.values.first.first.toString();
          }
        } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Tidak dapat terhubung ke server API. Periksa koneksi internet.';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.register(name, email, password);
      final user = UserModel.fromJson(data['user']);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      String errorMessage = 'Registrasi gagal. Periksa data kembali.';
      if (e is DioException) {
        if (e.response?.data != null && e.response?.data is Map) {
          final resData = e.response!.data as Map;
          if (resData['errors'] != null && resData['errors'] is Map) {
            final errors = resData['errors'] as Map;
            errorMessage = errors.values.first[0].toString();
          } else if (resData['message'] != null) {
            errorMessage = resData['message'].toString();
          }
        } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Tidak dapat terhubung ke server API. Periksa koneksi internet.';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  void updateProfile({String? name, String? avatarUrl}) {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        name: name ?? state.user!.name,
        avatarUrl: avatarUrl ?? state.user!.avatarUrl,
      );
      state = state.copyWith(user: updated);
    }
  }

  void addPointsAndXp(int points, int xp) {
    if (state.user != null) {
      final current = state.user!;
      final newXp = current.xp + xp;
      final newPoints = current.points + points;
      final newLevel = (newXp / 250).floor() + 1;
      final updatedUser = current.copyWith(
        xp: newXp,
        points: newPoints,
        level: newLevel,
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authServiceProvider)),
);
