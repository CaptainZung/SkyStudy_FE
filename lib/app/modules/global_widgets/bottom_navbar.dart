import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import '../../routes/app_pages.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(int index) {
    final Logger logger = Logger();
    if (index == currentIndex) return;
    logger.i('Navigating to index $index from $currentIndex');
    // Không truyền transition ở đây, chỉ gọi Get.toNamed như cũ
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (index) {
        case 0:
          Get.toNamed(Routes.home);
          break;
        case 1:
          Get.toNamed(Routes.dictionary);
          break;
        case 2:
          Get.toNamed(Routes.detection);
          break;
        case 3:
          Get.toNamed(Routes.achievements);
          break;
        case 4:
          Get.toNamed(Routes.topic);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F8FF), Colors.white],
        ),
        border: const Border(
          top: BorderSide(color: Color.fromARGB(255, 0, 187, 255), width: 1.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 9, 99, 245),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: _CustomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          SoundManager.playButtonSound();
          _onItemTapped(index);
        },
      ),
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color selectedBlue = Color.fromRGBO(33, 150, 243, 0.2);

    final List<String> icons = [
      'assets/icons/bottom_navbar_1.png',
      'assets/icons/bottom_navbar_2.png',
      'assets/icons/bottom_navbar_3.png',
      'assets/icons/bottom_navbar_4.png',
      'assets/icons/bottom_navbar_5.png',
    ];

    return Container(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(icons.length, (index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                SoundManager.playButtonSound();
                onTap(index);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: currentIndex == index ? selectedBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  icons[index],
                  width: 60,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red, size: 50);
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}