import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/menu/setting_controller.dart';
import 'package:skystudy/app/modules/profile/profile_controller.dart';

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key}); // Loại bỏ tham số points và username

  @override
  Widget build(BuildContext context) {
    final SettingController settingController = Get.find<SettingController>();
    final ProfileController profileController = Get.find<ProfileController>();

    void _showAvatarSelectionPopup(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    final avatarPath = 'assets/avatar/avatar_$index.png';
                    return GestureDetector(
                      onTap: () {
                        settingController.avatarPath.value = avatarPath;
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        avatarPath,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    return Obx(() {
      // Nếu đang tải, hiển thị vòng tròn loading
      if (profileController.isLoading.value) {
        return const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 10),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }

      // Nếu không có username (có thể do lỗi API), hiển thị thông báo lỗi
      if (profileController.username.value.isEmpty) {
        return const Row(
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 10),
            Text(
              'Error loading user info',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }

      // Hiển thị thông tin người dùng khi dữ liệu đã tải xong
      return Row(
        children: [
          GestureDetector(
            onTap: () => _showAvatarSelectionPopup(context),
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
                child: settingController.avatarPath.value.isNotEmpty
                    ? Image.asset(
                        settingController.avatarPath.value,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
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
                  profileController.username.value, // Lấy từ ProfileController
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
                        '${profileController.points.value} p', // Lấy từ ProfileController
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
      );
    });
  }
}