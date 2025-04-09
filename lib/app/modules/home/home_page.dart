import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../global_widgets/bottom_navbar.dart';
import '../../controllers/lottie_controller.dart';
import 'home_controller.dart';
// import 'package:skystudy/app/routes/app_pages.dart';
// import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import '../menu/setting_popup.dart';
import '../menu/setting_controller.dart';
import 'dart:io';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final LottieController lottieController = Get.find<LottieController>();
    return _HomePageView(controller: lottieController);
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

  // Biến để điều khiển hiệu ứng scale cho các nút hiện có
  double settingScale = 1.0;
  double dailyCheckScale = 1.0;
  double leaderboardScale = 1.0;

  // Biến để điều khiển hiệu ứng scale cho các nút roadmap
  double star1Scale = 1.0;
  double star2Scale = 1.0;
  double star3Scale = 1.0;
  double star4Scale = 1.0;
  double chestScale = 1.0;

  final int _points = 1000; // Điểm ảo (tạm thời)

  @override
  void initState() {
    super.initState();
    widget.controller.initialize(this);
    Get.find<HomeController>().fetchProfile();
  }

  @override
  void dispose() {
    widget.controller.stopAnimations();
    widget.controller.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final SettingController settingController = Get.put(SettingController()); // Đảm bảo controller được khởi tạo

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
            // Thông tin người dùng (Avatar, Tên, Điểm)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: Obx(() => Row(
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: settingController.avatarPath.value.isNotEmpty
                              ? Image.file(
                                  File(settingController.avatarPath.value),
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/icons/default_avatar.png',
                                      fit: BoxFit.cover,
                                      width: 60,
                                      height: 60,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/icons/default_avatar.png',
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tên và Điểm
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90E2),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              settingController.userName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '$_points p',
                                    style: const TextStyle(
                                      color: Color(0xFF4A90E2),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFF4A90E2),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
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
                  _ufoComposition = composition;
                  if (_dinoComposition != null) {
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
                  if (_ufoComposition != null) {
                    widget.controller.startAnimations(_ufoComposition!, _dinoComposition!);
                  }
                },
              ),
            ),
            // Nút Setting, Daily Check, Leaderboard
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nút 1: Setting
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          settingScale = 0.9;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          settingScale = 1.0;
                        });
                        SoundManager.playButtonSound();
                        showDialog(
                          context: context,
                          builder: (context) => const SettingPopup(),
                        );
                      },
                      child: AnimatedScale(
                        scale: settingScale,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/icons/setting.png',
                          width: 52,
                          height: 52,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nút 2: Daily Check
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          dailyCheckScale = 0.9;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          dailyCheckScale = 1.0;
                        });
                        SoundManager.playButtonSound();
                      },
                      child: AnimatedScale(
                        scale: dailyCheckScale,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/icons/dailycheck.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nút 3: Leaderboard
                    GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          leaderboardScale = 0.9;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          leaderboardScale = 1.0;
                        });
                        SoundManager.playButtonSound();
                      },
                      child: AnimatedScale(
                        scale: leaderboardScale,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/icons/leadboard.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Roadmap: Nút 1 (Star 0)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15,
              left: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    star1Scale = 0.9;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    star1Scale = 1.0;
                  });
                  SoundManager.playButtonSound();
                },
                child: AnimatedScale(
                  scale: star1Scale,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/icons/star1.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            // Roadmap: Nút 2 (Star 0)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.35,
              left: MediaQuery.of(context).size.width * 0.30,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    star2Scale = 0.9;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    star2Scale = 1.0;
                  });
                  SoundManager.playButtonSound();
                },
                child: AnimatedScale(
                  scale: star2Scale,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/icons/star0.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            // Roadmap: Nút 3 (Star 0)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.45,
              right: MediaQuery.of(context).size.width * 0.15,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    star3Scale = 0.9;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    star3Scale = 1.0;
                  });
                  SoundManager.playButtonSound();
                },
                child: AnimatedScale(
                  scale: star3Scale,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/icons/star0.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            // Roadmap: Nút 4
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.2,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    star4Scale = 0.9;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    star4Scale = 1.0;
                  });
                  SoundManager.playButtonSound();
                },
                child: AnimatedScale(
                  scale: star4Scale,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/icons/star0.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            // Roadmap: Nút 5 (Chest)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.12,
              right: MediaQuery.of(context).size.width * 0.1,
              child: GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    chestScale = 0.9;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    chestScale = 1.0;
                  });
                  SoundManager.playButtonSound();
                },
                child: AnimatedScale(
                  scale: chestScale,
                  duration: const Duration(milliseconds: 200),
                  child: Image.asset(
                    'assets/icons/chest.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}