import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/controllers/lottie_controller.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'config/theme.dart';
import 'app/routes/app_pages.dart';
import 'app/modules/auth/login_service.dart';
import 'app/utils/onboarding_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundManager.init(); // Khởi tạo SoundManager để preload và phát nhạc nền
  Get.put(HomeController());
  Get.put(() => LottieController());
  runApp(const SkyStudyApp());
}

class SkyStudyApp extends StatefulWidget {
  const SkyStudyApp({super.key});

  @override
  SkyStudyAppState createState() => SkyStudyAppState();
}

class SkyStudyAppState extends State<SkyStudyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Register lifecycle observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Unregister lifecycle observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // App is being closed
      SoundManager.stop();
    } else if (state == AppLifecycleState.paused) {
      // App is in background
      SoundManager.stopMusic();
    }
  }

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
          initialRoute: initialRoute, // Use dynamic initial route
          getPages: AppPages.routes,
        );
      },
    );
  }
}