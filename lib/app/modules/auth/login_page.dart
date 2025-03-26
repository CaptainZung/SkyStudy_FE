import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController());
  }

  @override
  void dispose() {
    Get.delete<LoginController>();
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
                  height: MediaQuery.of(context).size.height * 0.7,
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
                      children: [
                        const SizedBox(height: 20),
                        buildInputField('Email', controller.emailController, TextInputType.emailAddress, 'example@gmail.com'),
                        const SizedBox(height: 20),
                        Obx(() => buildPasswordField('Mật khẩu', controller.passwordController, controller.obscurePassword, controller.togglePasswordVisibility, '********')),
                        const SizedBox(height: 30),
                        Obx(() => controller.isLoading.value
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: controller.handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 13, 24, 244),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white)),
                              )),
                        const SizedBox(height: 15),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Get.offNamed(Routes.register);
                            },
                            child: const Text(
                              'Chưa có tài khoản? Đăng ký',
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