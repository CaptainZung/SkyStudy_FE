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
      child: _AnimatedSettingDialog(controller: controller),
    );
  }
}

class _AnimatedSettingDialog extends StatefulWidget {
  final SettingController controller;

  const _AnimatedSettingDialog({required this.controller});

  @override
  _AnimatedSettingDialogState createState() => _AnimatedSettingDialogState();
}

class _AnimatedSettingDialogState extends State<_AnimatedSettingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  const Center(
                    child: Text(
                      'Setting',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10, // Added spacing from right edge
                    top: 10, // Added spacing from top edge
                    child: IconButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        Get.back();
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      padding: const EdgeInsets.all(8), // Internal padding for larger tap area
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
                          widget.controller.pickImage();
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
                            child: widget.controller.avatarPath.value.isNotEmpty
                                ? Image.file(
                                    File(widget.controller.avatarPath.value),
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
                        child: widget.controller.isEditingName.value
                            ? Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: widget.controller.nameController,
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
                                      widget.controller.saveUserName();
                                    },
                                    icon: const Icon(Icons.check, color: Colors.green),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      SoundManager.playButtonSound();
                                      widget.controller.cancelEditName();
                                    },
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    widget.controller.userName.value,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      SoundManager.playButtonSound();
                                      widget.controller.startEditName();
                                    },
                                    icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  )),
              const SizedBox(height: 20),
              _buildVolumeSlider('Âm Lượng', widget.controller.musicVolume, (newVolume) {
                widget.controller.updateMusicVolume(newVolume);
              }),
              _buildVolumeSlider('Hiệu Ứng', widget.controller.buttonVolume, (newVolume) {
                widget.controller.updateButtonVolume(newVolume);
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
                        backgroundColor: const Color(0xFF2277B4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Về chúng tôi',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        widget.controller.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Đăng xuất',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(() => widget.controller.isGuest.value
                  ? ElevatedButton(
                      onPressed: () {
                        SoundManager.playButtonSound();
                        Get.toNamed(Routes.register);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2277B4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'TẠO TÀI KHOẢN',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
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
                  icon: const Icon(Icons.remove_circle_outline, size: 24, color: Color(0xFF2277B4)),
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
                                ? const Color(0xFF2277B4)
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
                  icon: const Icon(Icons.add_circle_outline, size: 24, color: Color(0xFF2277B4)),
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