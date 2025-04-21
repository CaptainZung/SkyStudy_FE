import 'package:get/get.dart';
import 'package:skystudy/app/modules/aispeech/ai_speech_binding.dart';
import 'package:skystudy/app/modules/auth/register_binding.dart';
import 'package:skystudy/app/modules/auth/register_page.dart';
import 'package:skystudy/app/modules/detection/detection_resullt_page.dart';
import 'package:skystudy/app/modules/pronunciation_check/pronunciation_check_binding.dart';
import 'package:skystudy/app/modules/pronunciation_check/pronunciation_check_page.dart';
import '../modules/home/home_binding.dart';
import 'package:skystudy/app/modules/detection/detection_result_binding.dart';
import '../modules/auth/login_binding.dart';
import '../modules/auth/login_page.dart';
import '../modules/home/home_page.dart';
import '../modules/dictionary/dictionary_page.dart';
import '../modules/dictionary/dictionary_binding.dart';
import '../modules/detection/detection_page.dart';
import '../modules/achievements/achievements_page.dart';
import '../modules/achievements/achievements_binding.dart';
import '../modules/topic/topic_page.dart';
import '../modules/topic/topic_binding.dart';
import '../modules/onboarding/onboarding_page.dart';
import '../modules/realtime/realtime_page.dart';
import '../modules/aispeech/ai_speech_page.dart';
import '../modules/exercises/exercise_1/exercise_1_page.dart';
import '../modules/exercises/exercise_1/exercise_1_binding.dart';
import '../modules/exercises/exercise_2/exercise_2_page.dart';
import '../modules/exercises/exercise_2/exercise_2_binding.dart';
import '../modules/exercises/exercise_3/exercise_3_page.dart';
import '../modules/exercises/exercise_3/exercise_3_binding.dart';
import '../modules/exercises/exercise_4/exercise_4_page.dart';
import '../modules/exercises/exercise_4/exercise_4_binding.dart';
import '../modules/leaderboard/leaderboard_page.dart';
import '../modules/leaderboard/leaderboard_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.onboard;

  static final routes = [
    GetPage(name: Routes.login, page: () => const LoginPage(), binding: LoginBinding()),
    GetPage(name: Routes.register, page: () => const RegisterPage(), binding: RegisterBinding()),
    GetPage(name: Routes.home, page: () => const HomePage(), binding: HomeBinding()),
    GetPage(name: Routes.dictionary, page: () => const DictionaryPage(), binding: DictionaryBinding()),
    GetPage(name: Routes.detection, page: () => const DetectionPage()),
    GetPage(name: Routes.detectionresult, page: () => const DetectionResultPage(), binding: DetectionResultBinding()),
    GetPage(name: Routes.achievements, page: () => const AchievementsPage(), binding: AchievementsBinding()),
    GetPage(name: Routes.topic, page: () => const TopicPage(), binding: TopicBinding()),
    GetPage(name: Routes.onboard, page: () => const OnboardingPage()),
    GetPage(name: Routes.realtime, page: () => const RealtimePage()),
    GetPage(name: Routes.aispeech, page: () => const AISpeechPage(), binding: AISpeechBinding()),
    GetPage(name: Routes.pronunciationcheck, page: () => const PronunciationCheckPage(), binding: PronunciationCheckBinding()),
    GetPage(name: Routes.exercise1, page: () => const Exercise1Page(), binding: Exercise1Binding()),
    GetPage(name: Routes.exercise2, page: () => const Exercise2Page(), binding: Exercise2Binding()),
    GetPage(name: Routes.exercise3, page: () => const Exercise3Page(), binding: Exercise3Binding()),
    GetPage(name: Routes.exercise4, page: () => const Exercise4Page(), binding: Exercise4Binding()),
    GetPage(name: Routes.leaderboard, page: () => const LeaderboardPage(), binding: LeaderboardBinding()),
  ];
}
