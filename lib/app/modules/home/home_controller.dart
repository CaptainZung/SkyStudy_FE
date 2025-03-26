import 'package:get/get.dart';
import 'package:skystudy/app/api/login_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:logger/logger.dart';

class HomeController extends GetxController {
  final AuthAPI authAPI = AuthAPI();
  final Logger logger = Logger();

  Future<void> logout() async {
    try {
      logger.i('Starting logout process');
      await authAPI.logout();
      Get.offAllNamed(Routes.login);
      logger.i('Logout successful, navigated to login');
    } catch (e) {
      logger.e('Error during logout: $e');
    }
  }

  Future<void> fetchProfile() async {
    try {
      logger.i('Fetching user profile');
      final profile = await authAPI.fetchUserProfile();
      if (profile != null) {
        logger.i('Profile fetched: $profile');
        // Cập nhật UI với thông tin profile
      } else {
        logger.w('No profile data returned');
      }
    } catch (e) {
      logger.e('Error fetching profile: $e');
    }
  }
}