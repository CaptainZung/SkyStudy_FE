import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthAPI {
  static const String baseUrl = 'http://10.0.2.2:8000/api/auth';
  final Dio dio = Dio();
  final Logger logger = Logger();
  String? _accessToken;

  AuthAPI() {
    // Cấu hình Dio
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.headers = {'Content-Type': 'application/json'};

    // Thêm interceptor để xử lý token tự động
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken == null) await _loadTokens();
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: ( e, handler) async {
          if (e.response?.statusCode == 401) {
            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              return handler.resolve(await dio.fetch(e.requestOptions));
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['access_token'], data['refresh_token']);
        _accessToken = data['access_token'];
        return data['access_token'];
      } else {
        logger.e('Login failed: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      logger.e('Error during login: $e');
      return null;
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken == null) return null;

      final response = await dio.post('/refresh', data: {'refresh_token': refreshToken});
      if (response.statusCode == 200) {
        final data = response.data;
        await _saveTokens(data['access_token'], data['refresh_token']);
        _accessToken = data['access_token'];
        return data['access_token'];
      }
    } catch (e) {
      logger.e('Error refreshing token: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await dio.get('/profile');
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      logger.e('Failed to fetch user profile: $e');
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }
}
