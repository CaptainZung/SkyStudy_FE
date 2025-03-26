import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent], // Đồng bộ với HomePage
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        buildInputField('Tên', controller.usernameController, TextInputType.name, 'Nhập tên của bạn'),
                        const SizedBox(height: 20),
                        buildInputField('Email', controller.emailController, TextInputType.emailAddress, 'example@gmail.com'),
                        const SizedBox(height: 20),
                        Obx(() => buildPasswordField('Mật khẩu', controller.passwordController, controller.obscurePassword, controller.togglePasswordVisibility, '********')),
                        const SizedBox(height: 20),
                        Obx(() => buildPasswordField('Nhập lại mật khẩu', controller.confirmPasswordController, controller.obscureConfirmPassword, controller.toggleConfirmPasswordVisibility, '********')),
                        const SizedBox(height: 30),
                        Obx(() => controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                            : ElevatedButton(
                                onPressed: controller.handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  minimumSize: const Size(double.infinity, 60),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text('ĐĂNG KÝ', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              )),
                        const SizedBox(height: 15),
                        Center(
                          child: TextButton(
                            onPressed: () => Get.offNamed(Routes.login),
                            child: const Text(
                              'Đã có tài khoản? Đăng nhập',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller, TextInputType inputType, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(String label, TextEditingController controller, RxBool obscureText, VoidCallback toggleVisibility, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(obscureText.value ? Icons.visibility_off : Icons.visibility, color: Colors.blueAccent),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}