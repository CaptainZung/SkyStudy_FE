import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_controller.dart';
class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Ký')),
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 43, 42, 40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Thông điệp động viên
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Text(
                    'Hãy nhờ sự giúp đỡ của người lớn nếu gặp khó khăn bạn nha 🥰',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Form đăng ký
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
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
                        buildInputField('Tên', controller.usernameController, TextInputType.name, 'Nhập tên của bạn'),
                        const SizedBox(height: 20),
                        buildInputField('Email', controller.emailController, TextInputType.emailAddress, 'example@gmail.com'),
                        const SizedBox(height: 20),
                        Obx(() => buildPasswordField('Mật khẩu', controller.passwordController, controller.obscurePassword, controller.togglePasswordVisibility, '********')),
                        const SizedBox(height: 20),
                        Obx(() => buildPasswordField('Nhập lại mật khẩu', controller.confirmPasswordController, controller.obscureConfirmPassword, controller.toggleConfirmPasswordVisibility, '********')),
                        const SizedBox(height: 30),

                        // Nút Đăng ký với hiệu ứng loading
                        Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 13, 24, 244),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ĐĂNG KÝ', style: TextStyle(color: Colors.white)),
                        )),
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
        ),
      ],
    );
  }
}
