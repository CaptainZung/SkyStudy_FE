import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/auth/login_binding.dart';
import '../modules/auth/login_page.dart';
import '../modules/home/home_page.dart';
import '../modules/dictionary/dictionary_category_page.dart';
import '../modules/detection/detection_page.dart';
import '../modules/achievements/achievements_page.dart';
import '../modules/englishbytopic/topic_page.dart';
import '../modules/onboarding/onboarding_page.dart';
part 'app_routes.dart';

class AppPages {
  static const initial = Routes.onboard;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.dictionary,
      page: () => const DictionaryCategoryPage(),
    ),
    GetPage(
      name: Routes.detection,
      page: () => const DetectionPage(),
    ),
    GetPage(
      name: Routes.achievements,
      page: () => const AchievementsPage(),
    ),
    GetPage(
      name: Routes.topic,
      page: () => const TopicPage(),
    ),
    GetPage(
      name: Routes.onboard,
      page: () => const OnboardingPage(),
    ),
  ];
}