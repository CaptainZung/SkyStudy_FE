import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class RegisterAPI {
  static const String baseUrl = 'http://10.0.2.2:8000/api/auth';
  final Dio dio = Dio();
  final Logger logger = Logger();

  RegisterAPI() {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 3);
    dio.options.headers = {'Content-Type': 'application/json'};
  }

  Future<bool> register(String username, String email, String password) async {
  try {
    final response = await dio.post(
      '/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
      logger.i('User registered successfully: ${response.data}');
      return true; // Đăng ký thành công
    } else {
      logger.e('Registration failed: ${response.statusCode} - ${response.data}');
      return false; // Lỗi hoặc tài khoản đã tồn tại
    }
  } catch (e) {
    logger.e('Error during registration: $e');
    return false; // Lỗi không kết nối được server
  }
}
}
