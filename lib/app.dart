import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dictionary/dictionary_category_screen.dart';
import 'screens/detection/detection_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'screens/englishbytopic/topic_screen.dart';

class SkyStudyApp extends StatelessWidget {
  const SkyStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyStudy',
      theme: appTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/dictionary': (context) => const DictionaryCategoryScreen(),
        '/detection': (context) => const DetectionScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/topic': (context) => const TopicScreen(),
      },
    );
  }
}