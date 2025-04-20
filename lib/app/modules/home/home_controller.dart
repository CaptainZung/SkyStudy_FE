import 'package:get/get.dart';
import 'package:skystudy/app/modules/auth/login_service.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skystudy/app/modules/home/home_service.dart';

class HomeController extends GetxController {
  final topics = [
    'Animal',
    'Family',
    'Fruits',
    'Foods',
    'Career',
    'School',
    'Sport',
    'Body Part',
  ];

  final AuthAPI authAPI = AuthAPI();
  final Logger logger = Logger();

  RxMap<String, int> topicProgress = <String, int>{}.obs;
  RxString currentTopic = ''.obs;
  RxInt currentNode = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadProgress();
  }

  final ProgressService progressService = ProgressService();

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (var topic in topics) {
      final progress = prefs.getInt('progress_$topic') ?? 1;
      topicProgress[topic] = progress;
    }
  }

  Future<void> saveProgress(String topic, int node) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress_$topic', node);
    topicProgress[topic] = node;
  }

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

  Future<void> loadProgressFromAPI() async {
  try {
    final result = await progressService.fetchUserProgress();
    currentTopic.value = result['topic'];
    currentNode.value = result['node'];
    logger.i('Loaded progress: topic=${result['topic']}, node=${result['node']}');
  } catch (e) {
    logger.e('Error loading progress from API: $e');
  }
}
}
