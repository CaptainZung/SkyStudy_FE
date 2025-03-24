import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/api/register_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final RegisterAPI registerAPI = RegisterAPI();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;


  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> handleRegister() async {
  final username = usernameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    Get.snackbar('Lỗi', 'Vui lòng điền đầy đủ thông tin');
    return;
  }

  if (password != confirmPassword) {
    Get.snackbar('Lỗi', 'Mật khẩu nhập lại không khớp');
    return;
  }

  bool isSuccess = await registerAPI.register(username, email, password);

  if (isSuccess) {
    Get.snackbar('Thành công', 'Đăng ký thành công. Hãy đăng nhập!');
    Get.offAllNamed(Routes.login);
  } else {
    Get.snackbar('Đăng ký thất bại', 'Đã có lỗi xảy ra hoặc tài khoản đã tồn tại');
  }
}


  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
