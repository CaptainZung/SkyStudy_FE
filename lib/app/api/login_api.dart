import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'api_config.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class AuthAPI {
  final Dio dio = Dio();
  final Logger logger = Logger();
  String? _accessToken;

  AuthAPI() {
    dio.options.baseUrl = ApiConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 30); // Tăng timeout lên 30 giây
    dio.options.headers = {'Content-Type': 'application/json'};

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _accessToken ??= await AuthManager.getToken();
          if (_accessToken != null && await AuthManager.isTokenValid()) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
            logger.i('Added Authorization header with token: $_accessToken');
          } else if (_accessToken != null) {
            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              options.headers['Authorization'] = 'Bearer $newToken';
              logger.i('Refreshed token added to headers: $newToken');
            } else {
              await AuthManager.clearToken();
              _accessToken = null;
              logger.w('Failed to refresh token, redirecting to login');
              Get.offAllNamed(Routes.login);
            }
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final newToken = await _refreshAccessToken();
            if (newToken != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              return handler.resolve(await dio.fetch(e.requestOptions));
            } else {
              await AuthManager.clearToken();
              _accessToken = null;
              logger.w('Failed to refresh token on 401 error, redirecting to login');
              Get.offAllNamed(Routes.login);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post('/login', data: {'email': email, 'password': password});
      logger.i('Response: ${response.statusCode} - ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data']; // Truy cập vào "data" trong response
        if (data == null) {
          logger.e('Response data is null');
          return {'success': false, 'message': 'Response data is missing'};
        }
        final accessToken = data['access_token']?.toString();
        if (accessToken == null) {
          logger.e('Access token is null');
          return {'success': false, 'message': 'Access token is missing'};
        }
        await AuthManager.saveToken(accessToken, 3600);
        if (data['refresh_token'] != null) {
          await AuthManager.saveRefreshToken(data['refresh_token']);
        }
        _accessToken = accessToken;
        logger.i('User logged in successfully: ${response.data}');
        return {'success': true, 'data': data};
      } else {
        logger.e('Login failed: ${response.statusCode} - ${response.data}');
        return {'success': false, 'message': 'Login failed: ${response.data}'};
      }
    } on DioException catch (e) {
      logger.e('DioException: ${e.message}, Response: ${e.response?.data}');
      if (e.response != null) {
        return {
          'success': false,
          'message': e.response?.data['message']?.toString() ?? 'Error: ${e.response?.statusCode}'
        };
      } else {
        return {'success': false, 'message': 'Error: Could not connect to server'};
      }
    } catch (e) {
      logger.e('Unexpected error during login: $e');
      return {'success': false, 'message': 'Unexpected error: ${e.toString()}'};
    }
  }

  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await AuthManager.getRefreshToken();
      if (refreshToken == null) {
        logger.w('No refresh token available');
        return null;
      }

      final response = await dio.post('/refresh', data: {'refresh_token': refreshToken});
      if (response.statusCode == 200) {
        final data = response.data['data']; // Truy cập vào "data" trong response
        if (data == null) {
          logger.e('Response data is null');
          return null;
        }
        final accessToken = data['access_token']?.toString();
        if (accessToken == null) {
          logger.e('Refreshed access token is null');
          return null;
        }
        await AuthManager.saveToken(accessToken, 3600);
        if (data['refresh_token'] != null) {
          await AuthManager.saveRefreshToken(data['refresh_token']);
        }
        _accessToken = accessToken;
        logger.i('Token refreshed successfully');
        return accessToken;
      } else {
        logger.e('Failed to refresh token: ${response.statusCode} - ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      logger.e('Error refreshing token: ${e.response?.statusCode} - ${e.response?.data}');
      return null;
    } catch (e) {
      logger.e('Unexpected error refreshing token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await AuthManager.clearToken();
    _accessToken = null;
    logger.i('User logged out successfully');
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await dio.get('/profile');
      if (response.statusCode == 200) {
        logger.i('User profile fetched successfully: ${response.data}');
        return response.data;
      } else {
        logger.e('Failed to fetch user profile: ${response.statusCode} - ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      logger.e('Error fetching user profile: ${e.response?.statusCode} - ${e.response?.data}');
      return null;
    } catch (e) {
      logger.e('Unexpected error fetching user profile: $e');
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return await AuthManager.isTokenValid();
  }
}