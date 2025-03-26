import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'app/routes/app_pages.dart';
import 'app/api/login_api.dart';
import 'app/utils/onboarding_manager.dart';

class SkyStudyApp extends StatelessWidget {
  const SkyStudyApp({super.key});

  Future<String> _determineInitialRoute() async {
    final bool hasSeenOnboarding = await OnboardingManager.hasSeenOnboarding();
    final bool isLoggedIn = await AuthAPI().isLoggedIn();

    if (!hasSeenOnboarding) {
      return Routes.onboard;
    } else if (isLoggedIn) {
      return Routes.home;
    } else {
      return Routes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _determineInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error occurred while initializing app')),
            ),
          );
        }

        final initialRoute = snapshot.data!;

        return GetMaterialApp(
          showPerformanceOverlay: false,
          title: 'SkyStudy',
          theme: appTheme(),
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          enableLog: true,
        );
      },
    );
  }
}