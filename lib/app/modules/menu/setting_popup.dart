import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'setting_controller.dart';
import 'about_us_page.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'dart:io';

class SettingPopup extends GetView<SettingController> {
  const SettingPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Setting',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        Get.back();
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Avatar và Tên
              Obx(() => Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () {
                          SoundManager.playButtonSound();
                          controller.pickImage();
                        },
                        child: Container(
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
                            child: controller.avatarPath.value.isNotEmpty
                                ? Image.file(
                                    File(controller.avatarPath.value),
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
                      ),
                      const SizedBox(width: 10),
                      // Tên và nút chỉnh sửa
                      Expanded(
                        child: controller.isEditingName.value
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: controller.nameController,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập tên mới',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      SoundManager.playButtonSound();
                                      controller.saveUserName();
                                    },
                                    icon: const Icon(Icons.check, color: Colors.green),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      SoundManager.playButtonSound();
                                      controller.cancelEditName();
                                    },
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    controller.userName.value,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      SoundManager.playButtonSound();
                                      controller.startEditName();
                                    },
                                    icon: const Icon(Icons.edit, size: 20),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  )),
              const SizedBox(height: 20),
              _buildVolumeSlider('Âm Lượng', controller.musicVolume, (newVolume) {
                controller.updateMusicVolume(newVolume);
              }),
              _buildVolumeSlider('Hiệu Ứng', controller.buttonVolume, (newVolume) {
                controller.updateButtonVolume(newVolume);
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        Get.to(() => const AboutUsPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Về chúng tôi', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        controller.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Đăng xuất', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() => controller.isGuest.value
                  ? ElevatedButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        Get.toNamed(Routes.register);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 13, 24, 244),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text('TẠO TÀI KHOẢN', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(String label, RxDouble volume, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    double newVolume = (volume.value - 0.2).clamp(0.0, 1.0);
                    onChanged(newVolume);
                    SoundManager.playButtonSound();
                  },
                  icon: const Icon(Icons.remove_circle_outline, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Obx(() => Row(
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index < (volume.value / 0.2).round()
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        );
                      }),
                    )),
                IconButton(
                  onPressed: () {
                    double newVolume = (volume.value + 0.20).clamp(0.0, 1.0);
                    onChanged(newVolume);
                    SoundManager.playButtonSound();
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}