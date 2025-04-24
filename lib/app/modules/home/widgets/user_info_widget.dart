import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/menu/setting_controller.dart';
import 'dart:io';

class UserInfoWidget extends StatelessWidget {
  final int points;
  final String username;

  const UserInfoWidget({super.key, required this.points, required this.username});

  @override
  Widget build(BuildContext context) {
    final SettingController settingController = Get.find<SettingController>();

    return Obx(
      () => Row(
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
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
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$points p',
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
      ),
    );
  }
}