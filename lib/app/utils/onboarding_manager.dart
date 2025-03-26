import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // Lưu trạng thái đã xem onboarding
  static Future<void> setHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // Kiểm tra xem đã xem onboarding chưa
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }
}