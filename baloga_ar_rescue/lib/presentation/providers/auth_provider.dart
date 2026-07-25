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
      state = state.copyWith(isLoading: false, error: 'Email atau password salah');
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
      state = state.copyWith(isLoading: false, error: 'Registrasi gagal. Coba lagi.');
      return false;
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

