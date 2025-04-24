import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:skystudy/app/modules/home/widgets/user_info_widget.dart';
import 'package:skystudy/app/modules/home/widgets/lottie_animation_widget.dart';
import 'package:skystudy/app/modules/home/widgets/action_buttons_widget.dart';
import 'package:skystudy/app/modules/home/widgets/roadmap_widget.dart';
import 'package:skystudy/app/modules/menu/setting_controller.dart';
import 'package:skystudy/app/modules/leaderboard/profile/profile_controller.dart';
import 'package:skystudy/app/utils/sound_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentBackground = 'assets/images/family_bg.png';

  @override
  void initState() {
    super.initState();
    Get.put(SettingController());
    Get.put(ProfileController()); // Initialize ProfileController
    SoundManager.playMusic(); // Phát nhạc nền khi vào trang Home
  }

  @override
  void dispose() {
    SoundManager.stopMusic(); // Dừng nhạc khi thoát khỏi trang Home
    super.dispose();
  }

  void updateBackground(String newBackground) {
    setState(() {
      currentBackground = newBackground;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều cao của bottom navigation bar
    final bottomNavHeight =
        60.0; // Giả định chiều cao của CustomBottomNavBar là 60

    return Scaffold(
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
              child: Obx(() {
                final profileController = Get.find<ProfileController>();
                return UserInfoWidget(
                  points: profileController.points.value,
                  username: profileController.username.value,
                );
              }),
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
              bottom:
                  bottomNavHeight, // Để lại không gian cho CustomBottomNavBar
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
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
