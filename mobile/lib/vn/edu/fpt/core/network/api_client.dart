import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../storage/local_storage.dart';

class ApiClient {
  static const String _baseUrl = 'http://10.0.2.2:5088'; // Android emulator → localhost:5088

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublic = options.path.contains('/api/auth/login') ||
              options.path.contains('/api/auth/forgot-password') ||
              options.path.contains('/api/auth/refresh');

          if (!isPublic) {
            final token = await LocalStorage.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry request với token mới
              final token = await LocalStorage.getAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              final retried = await _dio.fetch(e.requestOptions);
              return handler.resolve(retried);
            } else {
              await LocalStorage.clearAll();
              Get.offAllNamed('/login');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<bool> _tryRefreshToken() async {
    final refreshToken = await LocalStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (res.statusCode == 200) {
        await LocalStorage.saveTokens(
          accessToken: res.data['accessToken'],
          refreshToken: res.data['refreshToken'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Dio get instance => _dio;
}