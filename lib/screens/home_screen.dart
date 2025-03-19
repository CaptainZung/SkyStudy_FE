import 'package:flutter/material.dart';
import 'package:skystudy/widgets/bottom_navbar.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/controllers/lottie_controller.dart'; // Import LottieController

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late LottieController _lottieController;
  LottieComposition? _ufoComposition; // Lưu composition để sử dụng
  LottieComposition? _dinoComposition;

  @override
  void initState() {
    super.initState();
    // Khởi tạo LottieController
    _lottieController = LottieController(vsync: this);
  }

  @override
  void dispose() {
    // Giải phóng LottieController
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home.png'),
                  fit: BoxFit.cover,
                ),
              ),
              height: double.infinity,
              width: double.infinity,
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.60,
              left: MediaQuery.of(context).size.width * 0.45,
              child: Lottie.asset(
                'assets/lottie/ufo1.json',
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                controller: _lottieController.ufoController, // Sử dụng controller từ LottieController
                onLoaded: (composition) {
                  _ufoComposition = composition;
                  // Kiểm tra nếu cả hai composition đã được tải thì chạy animations
                  if (_ufoComposition != null && _dinoComposition != null) {
                    _lottieController.startAnimations(_ufoComposition!, _dinoComposition!);
                  }
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.55,
              left: MediaQuery.of(context).size.width * 0.55,
              child: Lottie.asset(
                'assets/lottie/khunglongdance.json',
                width: 170,
                height: 170,
                fit: BoxFit.contain,
                controller: _lottieController.dinoController, // Sử dụng controller từ LottieController
                onLoaded: (composition) {
                  _dinoComposition = composition;
                  // Kiểm tra nếu cả hai composition đã được tải thì chạy animations
                  if (_ufoComposition != null && _dinoComposition != null) {
                    _lottieController.startAnimations(_ufoComposition!, _dinoComposition!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}