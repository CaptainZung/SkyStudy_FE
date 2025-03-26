import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/api/login_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

class LoginController extends GetxController {
  final AuthAPI authAPI = AuthAPI();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final obscurePassword = true.obs;
  final Logger logger = Logger();
  var isLoading = false.obs;
  var _isMounted = true; // Biến để kiểm tra trạng thái controller

  @override
  void onInit() {
    super.onInit();
    logger.i('LoginController initialized');
  }

  void togglePasswordVisibility() {
    if (!_isMounted) return;
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> _showLottiePopup(ValueNotifier<String> animationPathNotifier, String message) async {
    if (!_isMounted) return;
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

  Future<void> handleLogin() async {
    if (!_isMounted) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      _showLottiePopup(animationPathNotifier, 'Vui lòng nhập đầy đủ thông tin!');
      await Future.delayed(const Duration(seconds: 1));
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      _showLottiePopup(animationPathNotifier, 'Email không hợp lệ');
      await Future.delayed(const Duration(seconds: 1));
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      return;
    }

    if (password.length < 8) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      _showLottiePopup(animationPathNotifier, 'Mật khẩu phải dài ít nhất 8 ký tự');
      await Future.delayed(const Duration(seconds: 1));
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      return;
    }

    isLoading.value = true;
    ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/loading.json');
    _showLottiePopup(animationPathNotifier, 'Đang đăng nhập...');

    try {
      final result = await authAPI.login(email, password);
      if (result['success'] == true) {
        animationPathNotifier.value = 'assets/lottie/success_loading.json';
        await Future.delayed(const Duration(seconds: 1));
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        if (_isMounted && Get.currentRoute != Routes.home) {
          Get.offAllNamed(Routes.home);
        }
      } else {
        animationPathNotifier.value = 'assets/lottie/fail_loading.json';
        await Future.delayed(const Duration(seconds: 1));
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        await Future.delayed(const Duration(milliseconds: 200));
        if (_isMounted) {
          _showLottiePopup(ValueNotifier('assets/lottie/fail_loading.json'), result['message']);
          await Future.delayed(const Duration(seconds: 2));
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        }
      }
    } catch (e) {
      animationPathNotifier.value = 'assets/lottie/fail_loading.json';
      await Future.delayed(const Duration(seconds: 1));
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      await Future.delayed(const Duration(milliseconds: 200));
      if (_isMounted) {
        _showLottiePopup(ValueNotifier('assets/lottie/fail_loading.json'), 'Đã có lỗi xảy ra: ${e.toString()}');
        await Future.delayed(const Duration(seconds: 2));
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }
    } finally {
      if (_isMounted) {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    _isMounted = false;
    logger.i('LoginController closed');
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}