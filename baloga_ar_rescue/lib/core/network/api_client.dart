import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static late final Dio _dio;
  static final _storage = const FlutterSecureStorage();

  static const String defaultHttpsUrl = 'https://balago.rozitech.co.id/api';
  static const String defaultHttpUrl = 'http://balago.rozitech.co.id/api';

  static Dio get instance => _dio;
  static String currentUrl = defaultHttpsUrl;

  static Future<void> init() async {
    final savedUrl = await _storage.read(key: 'custom_api_url');
    currentUrl = savedUrl ?? dotenv.env['API_BASE_URL'] ?? defaultHttpsUrl;

    _dio = Dio(BaseOptions(
      baseUrl: currentUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // Support HTTPS self-signed / unverified certificates on mobile
    if (!kIsWeb) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // If primary connection fails, attempt automatic fallback if local server is active
        if (_isNetworkOrServerError(e)) {
          final currentBase = _dio.options.baseUrl;
          final fallbackUrl = _getAutoFallback(currentBase);

          if (fallbackUrl != null && currentBase != fallbackUrl) {
            _dio.options.baseUrl = fallbackUrl;
            final reqOptions = e.requestOptions;
            reqOptions.path = reqOptions.path.replaceFirst(currentBase, fallbackUrl);

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

  static Future<void> updateBaseUrl(String newUrl) async {
    String formattedUrl = newUrl.trim();
    if (!formattedUrl.endsWith('/api')) {
      if (formattedUrl.endsWith('/')) {
        formattedUrl = '${formattedUrl}api';
      } else {
        formattedUrl = '$formattedUrl/api';
      }
    }
    currentUrl = formattedUrl;
    _dio.options.baseUrl = currentUrl;
    await _storage.write(key: 'custom_api_url', value: currentUrl);
  }

  static String? _getAutoFallback(String current) {
    if (current == defaultHttpsUrl) {
      return defaultHttpUrl;
    } else if (current == defaultHttpUrl) {
      if (!kIsWeb && Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
      return 'http://127.0.0.1:8000/api';
    }
    return null;
  }

  static bool _isNetworkOrServerError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.badResponse && (e.response?.statusCode == 404 || e.response!.statusCode! >= 500) ||
        e.error is HandshakeException ||
        e.error is SocketException;
  }
}
