import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import './api_config.dart';

class RegisterAPI {
  static const String baseUrl = ApiConfig.baseUrl;
  final Dio dio = Dio();
  final Logger logger = Logger();

  RegisterAPI() {
    logger.i('Initializing RegisterAPI with baseUrl: $baseUrl');
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.i('Sending request: ${options.method} ${options.uri}');
        logger.i('Request data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.i('Received response: ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        logger.e('Request error: ${e.message}');
        if (e.response != null) {
          logger.e('Error response: ${e.response?.statusCode} ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      logger.i('Registering user - Username: $username, Email: $email');
      logger.i('Sending request to $baseUrl/register');
      final response = await dio.post(
        '/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      logger.i('Register API response: statusCode=${response.statusCode}, data=${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('User registered successfully: ${response.data}');
        return {'success': true, 'data': response.data};
      } else {
        logger.e('Registration failed: ${response.statusCode} - ${response.data}');
        return {'success': false, 'message': 'Registration failed: ${response.data}'};
      }
    } on DioException catch (e) {
      if (e.response != null) {
        logger.e('Error during registration: ${e.response?.statusCode} - ${e.response?.data}');
        String errorMessage = 'Error: ${e.response?.statusCode}';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message']?.toString() ?? 'Error: ${e.response?.statusCode} - ${e.response?.data}';
        } else {
          errorMessage = e.response?.data?.toString() ?? 'Error: ${e.response?.statusCode}';
        }
        return {'success': false, 'message': errorMessage};
      } else {
        logger.e('Error during registration: ${e.message}');
        return {'success': false, 'message': 'Error: Could not connect to server - ${e.message}'};
      }
    } catch (e) {
      logger.e('Unexpected error during registration: $e');
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }
}