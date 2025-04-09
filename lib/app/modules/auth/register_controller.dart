import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/api/register_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';
// import 'package:skystudy/app/modules/global_widgets/lottie_popup.dart';
import 'package:logger/logger.dart';
import 'package:skystudy/app/utils/auth_manager.dart';

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
    Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin', duration: const Duration(seconds: 1));
    return;
  }

  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
    Get.snackbar('Lỗi', 'Email không hợp lệ', duration: const Duration(seconds: 1));
    return;
  }

  if (password.length < 8) {
    Get.snackbar('Lỗi', 'Mật khẩu phải dài ít nhất 8 ký tự', duration: const Duration(seconds: 1));
    return;
  }

  if (password != confirmPassword) {
    Get.snackbar('Lỗi', 'Mật khẩu nhập lại không khớp', duration: const Duration(seconds: 1));
    return;
  }

  isLoading.value = true;
  Get.snackbar('Thông báo', 'Đang đăng ký...', duration: null);

  try {
    final result = await registerAPI.register(username, email, password).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        logger.e('Register API timed out after 15 seconds');
        throw Exception('Hết thời gian chờ, vui lòng kiểm tra kết nối mạng');
      },
    );
    logger.i('Register API response: $result');

    if (result['success']) {
      Get.back(); // Đóng snackbar
      final isGuest = await AuthManager.isGuest();
      Get.snackbar(
        'Thành công',
        isGuest ? 'Tài khoản khách đã được liên kết thành công!' : 'Đăng ký thành công',
        duration: const Duration(seconds: 2),
      );
      if (_isMounted && Get.currentRoute != Routes.login) {
        Get.offAllNamed(Routes.login);
        logger.i('Navigated to login page');
      }
    } else {
      Get.back(); // Đóng snackbar
      Get.snackbar('Lỗi', result['message'] ?? 'Đăng ký thất bại', duration: const Duration(seconds: 2));
    }
  } catch (e) {
    logger.e('Error during registration: $e');
    Get.back(); // Đóng snackbar
    Get.snackbar('Lỗi', 'Đã có lỗi xảy ra: ${e.toString()}', duration: const Duration(seconds: 2));
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