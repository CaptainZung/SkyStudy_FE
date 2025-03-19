import 'package:flutter/material.dart';
import 'package:skystudy/screens/home_screen.dart';
import 'package:skystudy/api/api.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthAPI _authAPI = AuthAPI();

  // Load trước các Lottie để tránh giật lag
  @override
  void initState() {
    super.initState();
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

  // Hàm hiển thị popup Lottie với khả năng đổi animation
  Future<void> _showLottiePopup(ValueNotifier<String> animationPathNotifier, String message) async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: animationPathNotifier,
              builder: (context, animationPath, _) => Lottie.asset(animationPath, width: 150, height: 150),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Xử lý đăng nhập
  void _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu!')),
      );
      return;
    }

    // Tạo ValueNotifier để đổi animation
    ValueNotifier<String> animationPathNotifier = ValueNotifier('assets/lottie/loading.json');

    // Hiện popup loading
    _showLottiePopup(animationPathNotifier, 'Đang đăng nhập...');

    String? token = await _authAPI.login(email, password);

    if (token != null) {
      animationPathNotifier.value = 'assets/lottie/success_loading.json';
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      animationPathNotifier.value = 'assets/lottie/fail_loading.json';
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color.fromRGBO(255, 157, 0, 1),
          child: Stack(
            children: [
              // Logo chính giữa
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 300, height: 300),
                    const SizedBox(height: 600),
                  ],
                ),
              ),

              // Form đăng nhập
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
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
                        const Text('Email', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                        TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'example@gmail.com', hintStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder())),
                        const SizedBox(height: 20),
                        const Text('Mật khẩu', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: '********',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Text(_obscurePassword ? '🙉' : '🙈', style: const TextStyle(fontSize: 25)),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
