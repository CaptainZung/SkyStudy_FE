import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skystudy/app/api/api_config.dart';
import '../home/home_controller.dart';

class SettingController extends GetxController {
  final RxBool isGuest = false.obs;
  final RxDouble musicVolume = SoundManager.musicVolume.obs;
  final RxDouble buttonVolume = SoundManager.buttonVolume.obs;

  // Biến để quản lý tên và ảnh
  final RxString userName = ''.obs; // Tên lấy từ API
  final RxString avatarPath = ''.obs; // Đường dẫn ảnh
  final RxBool isEditingName = false.obs; // Trạng thái chỉnh sửa tên
  final TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkGuestStatus();
    loadUserData();
    fetchUserNameFromApi(); // Lấy tên từ API
    nameController.text = userName.value;
  }

  // Kiểm tra trạng thái khách
  void checkGuestStatus() async {
    isGuest.value = await AuthManager.isGuest();
  }

  // Tải tên và ảnh từ SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? '';
    avatarPath.value = prefs.getString('avatar_path') ?? '';
  }

  // Lấy tên người dùng từ API /profile
  Future<void> fetchUserNameFromApi() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Lỗi', 'Thiếu token. Vui lòng đăng nhập lại.');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['user'];
        userName.value = data['username'] ?? '';
        // Lưu vào SharedPreferences để đồng bộ
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', userName.value);
        nameController.text = userName.value;
      } else {
        Get.snackbar('Lỗi', 'Không thể lấy thông tin người dùng: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi lấy thông tin người dùng: $e');
    }
  }

  // Lưu tên vào SharedPreferences
  Future<void> saveUserName() async {
    if (nameController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', nameController.text);
      userName.value = nameController.text;
    }
  }

  // Chọn ảnh từ thư viện
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_path', pickedFile.path);
        avatarPath.value = pickedFile.path;
      } else {
        Get.snackbar('Thông báo', 'Không có ảnh nào được chọn');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn ảnh: $e');
    }
  }

  // Cập nhật âm lượng nhạc
  void updateMusicVolume(double newVolume) {
    musicVolume.value = newVolume;
    SoundManager.saveMusicVolume(newVolume);
  }

  // Cập nhật âm lượng hiệu ứng
  void updateButtonVolume(double newVolume) {
    buttonVolume.value = newVolume;
    SoundManager.saveButtonVolume(newVolume);
  }

  // Đăng xuất
  void logout() async {
    final homeController = Get.find<HomeController>();
    await homeController.logout();
    Get.back();
  }
}