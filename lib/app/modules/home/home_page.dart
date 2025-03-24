import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../global_widgets/bottom_navbar.dart';
import '../../controllers/lottie_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject LottieController nếu chưa inject
    final LottieController controller = Get.put(LottieController());
    return _HomePageView(controller: controller);
  }
}

class _HomePageView extends StatefulWidget {
  final LottieController controller;
  const _HomePageView({required this.controller});
  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> with TickerProviderStateMixin {
  LottieComposition? _ufoComposition;
  LottieComposition? _dinoComposition;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(this);
  }

  @override
  void dispose() {
    widget.controller.stopAnimations(); // Dừng animations
    widget.controller.onClose(); // Dispose controllers
    Get.delete<LottieController>(); // Xóa instance
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
                controller: widget.controller.ufoController,
                onLoaded: (composition) {
                    _ufoComposition = composition; // Bỏ if (composition != null)
                    if (_dinoComposition != null) { // Chỉ cần kiểm tra _dinoComposition
                      widget.controller.startAnimations(_ufoComposition!, _dinoComposition!);
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
                controller: widget.controller.dinoController,
                onLoaded: (composition) {
                    _dinoComposition = composition;
                    if (_ufoComposition != null && _dinoComposition != null) {
                      widget.controller.startAnimations(_ufoComposition!, _dinoComposition!);
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