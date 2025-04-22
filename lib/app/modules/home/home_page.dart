import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:skystudy/app/modules/home/home_controller.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
import 'package:skystudy/app/modules/home/widgets/user_info_widget.dart';
import 'package:skystudy/app/modules/home/widgets/lottie_animation_widget.dart';
import 'package:skystudy/app/modules/home/widgets/action_buttons_widget.dart';
import 'package:skystudy/app/modules/home/widgets/roadmap_widget.dart';
//import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:skystudy/app/modules/menu/setting_controller.dart';

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
              child: UserInfoWidget(points: 1000),
            ),
            LottieAnimationWidget(),
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 5,
              child: ActionButtonsWidget(),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
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
                    'assets/images/sport_bg.png',
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
