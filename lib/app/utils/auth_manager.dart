import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthManager {
  static const String _tokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isGuestKey = 'is_guest'; // Thêm key để lưu trạng thái khách
  static final Logger logger = Logger();

  static Future<void> saveToken(String? token, int expiryInSeconds, {bool isGuest = false}) async {
    if (token == null) {
      logger.e('Cannot save null token');
      throw Exception('Cannot save null token');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      final expiryTime = DateTime.now().add(Duration(seconds: expiryInSeconds));
      await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
      await prefs.setBool(_isGuestKey, isGuest); // Lưu trạng thái isGuest
      logger.i('Token saved, expiry: ${expiryTime.toIso8601String()}, isGuest: $isGuest');
    } catch (e) {
      logger.e('Error saving token: $e');
      rethrow;
    }
  }

  static Future<void> saveRefreshToken(String? refreshToken) async {
    if (refreshToken == null) {
      logger.w('No refresh token to save');
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
      logger.i('Refresh token saved: $refreshToken');
    } catch (e) {
      logger.e('Error saving refresh token: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    logger.i('Retrieved token: $token');
    return token;
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    logger.i('Retrieved refresh token: $refreshToken');
    return refreshToken;
  }

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isGuestKey) ?? false; // Mặc định là false nếu không có giá trị
  }

  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryString = prefs.getString(_tokenExpiryKey);

    if (token == null || expiryString == null) {
      logger.w('Token or expiry not found - token: $token, expiry: $expiryString');
      if (token != null && expiryString == null) {
        logger.w('Expiry missing but token exists, clearing token');
        await prefs.remove(_tokenKey);
      }
      return false;
    }

    try {
      final expiryTime = DateTime.parse(expiryString);
      final isValid = DateTime.now().isBefore(expiryTime);
      logger.i('Token validity check: $isValid, expiry: $expiryString');
      return isValid;
    } catch (e) {
      logger.e('Error parsing expiry time: $e');
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpiryKey);
      return false;
    }
  }

  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_isGuestKey); // Xóa trạng thái isGuest
      logger.i('Token cleared');
    } catch (e) {
      logger.e('Error clearing token: $e');
      rethrow;
    }
  }

  static getUserId() {}
}