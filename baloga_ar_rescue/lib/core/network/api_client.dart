import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static late final Dio _dio;
  static final _storage = const FlutterSecureStorage();

  static const String primaryUrl = 'https://balago.rozitech.co.id/api';
  static const String fallbackUrl = 'http://127.0.0.1:8000/api';

  static Dio get instance => _dio;

  static Future<void> init() async {
    final envUrl = dotenv.env['API_BASE_URL'] ?? primaryUrl;

    _dio = Dio(BaseOptions(
      baseUrl: envUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Automatic Server Fallback handling
        if (_isNetworkOrServerError(e)) {
          final currentBase = _dio.options.baseUrl;
          final newBase = (currentBase == primaryUrl) ? fallbackUrl : primaryUrl;

          if (currentBase != newBase) {
            _dio.options.baseUrl = newBase;
            final reqOptions = e.requestOptions;
            reqOptions.path = reqOptions.path.replaceFirst(currentBase, newBase);

            try {
              final response = await _dio.fetch(reqOptions);
              return handler.resolve(response);
            } catch (err) {
              return handler.next(e);
            }
          }
        }
        return handler.next(e);
      },
    ));
  }

  static bool _isNetworkOrServerError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response != null && e.response!.statusCode! >= 500);
  }
}
