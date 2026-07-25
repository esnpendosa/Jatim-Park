import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:baloga_ar_rescue/core/network/api_client.dart';
import 'package:baloga_ar_rescue/data/models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await ApiClient.instance.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    await _storage.write(key: 'auth_token', value: res.data['token']);
    return res.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiClient.instance.post('/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.write(key: 'auth_token', value: res.data['token']);
    return res.data;
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/logout');
    } catch (_) {}
    await _storage.delete(key: 'auth_token');
  }

  Future<UserModel?> getMe() async {
    try {
      final res = await ApiClient.instance.get('/me');
      return UserModel.fromJson(res.data['user']);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}

