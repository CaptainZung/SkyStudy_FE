import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Thêm import này để dùng SystemNavigator
import 'package:get/get.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'register_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  late RegisterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RegisterController());
  }

  @override
  void dispose() {
    Get.delete<RegisterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 43, 42, 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 500,
                      height: 500,
                    ),
                  ),
                ),
                Container(
                  // Bỏ chiều cao cố định để tránh overflow
                  // height: MediaQuery.of(context).size.height * 0.7,
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
                        offset: Offset(0, 5),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Sử dụng min để Column co giãn theo nội dung
                      children: [
                        const SizedBox(height: 10), // Giảm khoảng cách
                        buildInputField('Tên', controller.usernameController, TextInputType.text, 'Tên của bạn'),
                        const SizedBox(height: 10), // Giảm khoảng cách
                        buildInputField('Email', controller.emailController, TextInputType.emailAddress, 'example@gmail.com'),
                        const SizedBox(height: 10), // Giảm khoảng cách
                        Obx(() => buildPasswordField('Mật khẩu', controller.passwordController, controller.obscurePassword, controller.togglePasswordVisibility, '********')),
                        const SizedBox(height: 10), // Giảm khoảng cách
                        Obx(() => buildPasswordField('Nhập lại mật khẩu', controller.confirmPasswordController, controller.obscureConfirmPassword, controller.toggleConfirmPasswordVisibility, '********')),
                        const SizedBox(height: 20), // Giảm khoảng cách
                        Obx(() => controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: controller.handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 13, 24, 244),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('ĐĂNG KÝ', style: TextStyle(color: Colors.white)),
                              )),
                        const SizedBox(height: 10), // Giảm khoảng cách
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.offNamed(Routes.login);
                            },
                            child: const Text(
                              'Đã có tài khoản? Đăng nhập',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
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
          style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          enabled: mounted,
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
          style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText.value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Text(
                obscureText.value ? '🙉' : '🙈',
                style: const TextStyle(fontSize: 25),
              ),
              onPressed: toggleVisibility,
            ),
          ),
          enabled: mounted,
        ),
      ],
    );
  }
}