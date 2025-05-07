import 'package:get/get.dart';
import 'package:skystudy/app/modules/auth/login_service.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skystudy/app/modules/home/home_service.dart';

class HomeController extends GetxController {
  final topics = [
    'Family',
    'Animal',
    'Fruits',
    'School',
    'Foods',
    'Sport',
    'Body Part',
    'Career',
  ];

  final AuthAPI authAPI = AuthAPI();
  final Logger logger = Logger();

  RxMap<String, int> topicProgress = <String, int>{}.obs;
  RxString currentTopic = ''.obs;
  RxInt currentNode = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentState(); // Load saved state on initialization
    loadProgressFromAPI(); // Preload all progress data from the API
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

      // Preload progress for all topics
      if (result['progress'] != null) {
        for (var topic in topics) {
          topicProgress[topic] = result['progress'][topic] ?? 1;
        }
      } else {
        logger.w('Progress data is null, initializing with default values');
        for (var topic in topics) {
          topicProgress[topic] = 1; // Default to 1 if no progress data is available
        }
      }

      logger.i('Loaded progress: topic=${result['topic']}, node=${result['node']}');
    } catch (e) {
      logger.e('Error loading progress from API: $e');
      // Fallback: Load progress from SharedPreferences if API fails
      final prefs = await SharedPreferences.getInstance();
      currentTopic.value = prefs.getString('last_topic') ?? topics[0]; // Default to the first topic
      currentNode.value = prefs.getInt('last_node') ?? 1; // Default to node 1

      // Load progress for all topics from local storage
      for (var topic in topics) {
        topicProgress[topic] = prefs.getInt('progress_$topic') ?? 1;
      }

      logger.i('Loaded progress from local: topic=${currentTopic.value}, node=${currentNode.value}');
    }
  }

  // Thêm phương thức saveProgressToLocal
  Future<void> saveProgressToLocal(String topic, int node) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_topic', topic);
    await prefs.setInt('last_node', node);
  }

  Future<void> saveCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_topic', currentTopic.value);
    await prefs.setInt('current_node', currentNode.value);
  }

  Future<void> loadCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    currentTopic.value = prefs.getString('current_topic') ?? topics[0];
    currentNode.value = prefs.getInt('current_node') ?? 1;
  }
}