import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import 'routes/app_pages.dart';

class SkyStudyApp extends StatelessWidget {
  const SkyStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkyStudy',
      theme: appTheme(),
      initialRoute: AppPages.initial, // Đổi từ INITIAL thành initial
      getPages: AppPages.routes,
    );
  }
}