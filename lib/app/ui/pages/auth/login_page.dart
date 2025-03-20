import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromARGB(255, 132, 126, 117),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo chính giữa
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 300,
                      height: 300,
                    ),
                  ),
                ),

                // Form đăng nhập
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
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
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Mật khẩu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => TextField(
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword.value,
                            decoration: InputDecoration(
                              hintText: '********',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Text(
                                  controller.obscurePassword.value
                                      ? '🙉'
                                      : '🙈',
                                  style: const TextStyle(fontSize: 25),
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Nút tạo tài khoản và quên mật khẩu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Tạo tài khoản',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 44, 44, 44),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Nút đăng nhập
                        ElevatedButton(
                          onPressed: controller.handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Hoặc dùng thử
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            '---------------  HOẶC  ---------------',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 193, 37, 231),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'DÙNG THỬ',
                            style: TextStyle(color: Colors.white),
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
}
