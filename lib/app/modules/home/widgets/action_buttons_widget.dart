import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:skystudy/app/modules/daily_check/daily_check_controller.dart';
import 'package:skystudy/app/modules/daily_check/daily_check_popup.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:skystudy/app/modules/menu/setting_popup.dart';
import 'package:skystudy/app/modules/leaderboard/leaderboard_page.dart';

class ActionButtonsWidget extends StatefulWidget {
  const ActionButtonsWidget({super.key});

  @override
  ActionButtonsWidgetState createState() => ActionButtonsWidgetState();
}

class ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  double settingScale = 1.0;
  double dailyCheckScale = 1.0;
  double leaderboardScale = 1.0;
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                settingScale = 0.9;
              });
              logger.i('Setting button pressed down');
            },
            onTapUp: (_) {
              setState(() {
                settingScale = 1.0;
              });
              logger.i('Setting button pressed up');
              SoundManager.playButtonSound();
              showDialog(
                context: context,
                builder: (dialogContext) {
                  logger.i('Showing SettingPopup');
                  return const SettingPopup();
                },
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
          GestureDetector(
  onTapDown: (_) {
    setState(() {
      dailyCheckScale = 0.9;
    });
    logger.i('Daily Check button pressed down');
  },
  onTapUp: (_) {
  setState(() {
    dailyCheckScale = 1.0;
  });
  logger.i('Daily Check button pressed up');
  SoundManager.playButtonSound();

  // 👉 Đảm bảo khởi tạo controller trước khi gọi popup
  if (!Get.isRegistered<DailyCheckController>()) {
    Get.put(DailyCheckController());
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      return const DailyCheckPopup();
    },
  );
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
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                leaderboardScale = 0.9;
              });
              logger.i('Leaderboard button pressed down');
            },
            onTapUp: (_) {
              setState(() {
                leaderboardScale = 1.0;
              });
              logger.i('Leaderboard button pressed up');
              SoundManager.playButtonSound();
              Get.to(
                const LeaderboardPage(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
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
    );
  }
}