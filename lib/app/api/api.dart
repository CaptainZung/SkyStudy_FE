import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AuthAPI {
  static const String baseUrl = 'http://10.0.2.2:8000/api/auth';
  final Dio dio = Dio();
  final Logger logger = Logger();

  AuthAPI() {
    // Cấu hình Dio
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.headers = {'Content-Type': 'application/json'};
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
        return data['access_token']; // Trả về access token
      } else {
        logger.e('Login failed: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      logger.e('Error during login: $e');
      return null;
    }
  }
}