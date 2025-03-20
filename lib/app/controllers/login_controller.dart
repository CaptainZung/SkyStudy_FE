import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../api/api.dart';
import '../routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final AuthAPI _authAPI = AuthAPI();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _preloadAnimations();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _preloadAnimations() async {
    List<String> animations = [
      'assets/lottie/loading.json',
      'assets/lottie/success_loading.json',
      'assets/lottie/fail_loading.json',
    ];
    for (String path in animations) {
      await rootBundle.loadString(path);
    }
  }

  Future<void> _showLottiePopup(ValueNotifier<String> animationPathNotifier, String message) async {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: animationPathNotifier,
              builder: (context, animationPath, _) => Lottie.asset(
                animationPath,
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void handleLogin() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập email và mật khẩu!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    ValueNotifier<String> animationPathNotifier =
        ValueNotifier('assets/lottie/loading.json');

    _showLottiePopup(animationPathNotifier, 'Đang đăng nhập...');

    String? token = await _authAPI.login(email, password);

    if (token != null) {
      // Lưu token vào GetStorage (nếu bạn đã thêm get_storage)
      await GetStorage().write('token', token);
      animationPathNotifier.value = 'assets/lottie/success_loading.json';
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
      Get.offNamed(Routes.home); // Đổi từ Routes.HOME thành Routes.home
    } else {
      animationPathNotifier.value = 'assets/lottie/fail_loading.json';
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}