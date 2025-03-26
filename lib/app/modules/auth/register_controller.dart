import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/api/register_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:skystudy/app/modules/global_widgets/lottie_popup.dart';
import 'package:logger/logger.dart';

class RegisterController extends GetxController {
  final RegisterAPI registerAPI = RegisterAPI();
  final Logger logger = Logger();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var isLoading = false.obs;
  var _isMounted = true;

  @override
  void onInit() {
    super.onInit();
    _preloadAnimations();
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

  void togglePasswordVisibility() {
    if (!_isMounted) return;
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    if (!_isMounted) return;
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> handleRegister() async {
    if (!_isMounted) return;

    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    logger.i('Starting registration process: username=$username, email=$email');

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      await showLottiePopup(
        context: Get.context!,
        initialAnimationPath: 'assets/lottie/fail_loading.json',
        message: 'Vui lòng điền đầy đủ thông tin',
        animationPathNotifier: animationPathNotifier,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      await showLottiePopup(
        context: Get.context!,
        initialAnimationPath: 'assets/lottie/fail_loading.json',
        message: 'Email không hợp lệ',
        animationPathNotifier: animationPathNotifier,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    if (password.length < 8) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      await showLottiePopup(
        context: Get.context!,
        initialAnimationPath: 'assets/lottie/fail_loading.json',
        message: 'Mật khẩu phải dài ít nhất 8 ký tự',
        animationPathNotifier: animationPathNotifier,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    if (password != confirmPassword) {
      ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/fail_loading.json');
      await showLottiePopup(
        context: Get.context!,
        initialAnimationPath: 'assets/lottie/fail_loading.json',
        message: 'Mật khẩu nhập lại không khớp',
        animationPathNotifier: animationPathNotifier,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    isLoading.value = true;
    ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/loading.json');
    await showLottiePopup(
      context: Get.context!,
      initialAnimationPath: 'assets/lottie/loading.json',
      message: 'Đang đăng ký...',
      animationPathNotifier: animationPathNotifier,
    );

    try {
      logger.i('Calling registerAPI.register...');
      // Thêm timeout 10 giây cho API call
      final result = await registerAPI.register(username, email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          logger.e('Register API timed out after 10 seconds');
          throw Exception('Hết thời gian chờ, vui lòng kiểm tra kết nối mạng');
        },
      );
      logger.i('Register API response: $result');

      if (result['success']) {
        animationPathNotifier.value = 'assets/lottie/success_loading.json';
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(Get.context!)) {
          Navigator.of(Get.context!).pop();
          logger.i('Closed success dialog');
        }
        if (_isMounted && Get.currentRoute != Routes.login) {
          Get.offAllNamed(Routes.login);
          logger.i('Navigated to login page');
        }
      } else {
        animationPathNotifier.value = 'assets/lottie/fail_loading.json';
        await Future.delayed(const Duration(seconds: 1));
        if (Navigator.canPop(Get.context!)) {
          Navigator.of(Get.context!).pop();
          logger.i('Closed fail dialog');
        }
        await Future.delayed(const Duration(milliseconds: 200));
        if (_isMounted) {
          await showLottiePopup(
            context: Get.context!,
            initialAnimationPath: 'assets/lottie/fail_loading.json',
            message: result['message'] ?? 'Đăng ký thất bại',
            animationPathNotifier: ValueNotifier('assets/lottie/fail_loading.json'),
            duration: const Duration(seconds: 2),
          );
          logger.i('Showed failure message: ${result['message']}');
        }
      }
    } catch (e) {
      logger.e('Error during registration: $e');
      animationPathNotifier.value = 'assets/lottie/fail_loading.json';
      await Future.delayed(const Duration(seconds: 1));
      if (Navigator.canPop(Get.context!)) {
        Navigator.of(Get.context!).pop();
        logger.i('Closed error dialog');
      }
      await Future.delayed(const Duration(milliseconds: 200));
      if (_isMounted) {
        await showLottiePopup(
          context: Get.context!,
          initialAnimationPath: 'assets/lottie/fail_loading.json',
          message: 'Đã có lỗi xảy ra: ${e.toString()}',
          animationPathNotifier: ValueNotifier('assets/lottie/fail_loading.json'),
          duration: const Duration(seconds: 2),
        );
        logger.i('Showed error message: ${e.toString()}');
      }
    } finally {
      if (_isMounted) {
        isLoading.value = false;
        logger.i('Registration process completed, isLoading set to false');
      }
    }
  }

  @override
  void onClose() {
    _isMounted = false;
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    logger.i('RegisterController closed');
    super.onClose();
  }
}