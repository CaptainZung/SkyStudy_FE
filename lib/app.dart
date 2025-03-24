import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/theme.dart';
import 'app/routes/app_pages.dart';

class SkyStudyApp extends StatelessWidget {
  const SkyStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      showPerformanceOverlay: false,
      title: 'SkyStudy',
      theme: appTheme(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}