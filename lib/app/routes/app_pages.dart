import 'package:get/get.dart';
import '../bindings/home_binding.dart';
import '../bindings/login_binding.dart';
import '../ui/pages/auth/login_page.dart';
import '../ui/pages/home/home_page.dart';
import '../ui/pages/dictionary/dictionary_category_page.dart';
import '../ui/pages/detection/detection_page.dart';
import '../ui/pages/achievements/achievements_page.dart';
import '../ui/pages/englishbytopic/topic_page.dart';
import '../ui/pages/onboarding/onboarding_page.dart';
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