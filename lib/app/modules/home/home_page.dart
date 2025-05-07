import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/modules/home/widgets/user_info_widget.dart';
import 'package:skystudy/app/modules/home/widgets/lottie_animation_widget.dart';
import 'package:skystudy/app/modules/home/widgets/action_buttons_widget.dart';
import 'package:skystudy/app/modules/home/widgets/roadmap_widget.dart';
import 'package:skystudy/app/modules/menu/setting_controller.dart';
import 'package:skystudy/app/modules/profile/profile_controller.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:skystudy/app/controllers/lottie_controller.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String currentBackground = 'assets/images/family_bg.png';
  final isIdle = false.obs;
  Timer? _idleTimer;
  final LottieController lottieController = Get.find<LottieController>();

  @override
  void initState() {
    super.initState();
    final homeController = Get.put(HomeController());
    homeController.loadCurrentState(); // Load saved state on initialization
    Get.put(SettingController());
    Get.put(ProfileController());
    SoundManager.playMusic();
    lottieController.initialize(this);
    _startIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    lottieController.stopAnimations();
    lottieController.onClose();
    SoundManager.stopMusic();
    super.dispose();
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 3), () {
      isIdle.value = true;
    });
  }

  void _onUserInteraction() {
    isIdle.value = false;
    lottieController.stopIdleAnimation();
    _startIdleTimer();
  }

  void updateBackground(String newBackground) {
    setState(() {
      currentBackground = newBackground;
    });
  }

  void _handleUserInteraction() {
    SoundManager.playButtonSound();
    _onUserInteraction();
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavHeight = 60.0;

    return GestureDetector(
      onTap: _handleUserInteraction,
      onPanDown: (_) => _handleUserInteraction(),
      onPanUpdate: (_) => _handleUserInteraction(),
      onPanEnd: (_) => _handleUserInteraction(),
      onDoubleTap: _handleUserInteraction,
      onLongPress: _handleUserInteraction,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(currentBackground),
                    fit: BoxFit.cover,
                  ),
                ),
                height: double.infinity,
                width: double.infinity,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                child: const UserInfoWidget(),
              ),
              LottieAnimationWidget(),
              Positioned(
                top: MediaQuery.of(context).padding.top + 120,
                left: 5,
                child: ActionButtonsWidget(),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 70,
                right: 0,
                bottom: bottomNavHeight,
                child: RoadmapWidget(
                  onTopicChanged: (topicIndex) {
                    final List<String> backgrounds = [
                      'assets/images/family_bg.png',
                      'assets/images/animal_bg.png',
                      'assets/images/fruit_bg.png',
                      'assets/images/school_bg.png',
                      'assets/images/food_bg.png',
                      'assets/images/sport_bg.png',
                      'assets/images/bodypark_bg.png',
                      'assets/images/sport_bg.png',
                    ];
                    updateBackground(backgrounds[topicIndex]);
                  },
                ),
              ),
              // Cập nhật vị trí idle animation để nằm bên trái trang HomePage
              Positioned(
                bottom: 100, // Đặt cao hơn ActionButtonsWidget để tránh chồng lấn
                left: 0, // Đặt sát mép trái, tương tự ActionButtonsWidget
                child: Obx(() => isIdle.value
                    ? Lottie.asset(
                        'assets/lottie/swipe2.json',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        controller: lottieController.idleController,
                        onLoaded: (composition) {
                          lottieController.startIdleAnimation(composition);
                        },
                      )
                    : const SizedBox.shrink()),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      ),
    );
  }
}