import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'app/routes/app_pages.dart'; 
import 'app/api/login_api.dart';

class SkyStudyApp extends StatelessWidget {
  const SkyStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthAPI().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        final initialRoute = snapshot.data == true ? Routes.home : AppPages.initial;

        return GetMaterialApp(
          showPerformanceOverlay: false,
          title: 'SkyStudy',
          theme: appTheme(),
          initialRoute: Routes.register,
          getPages: AppPages.routes,
          enableLog: true,
        );
      },
    );
  }
}
