import 'package:get/get.dart';
import 'package:skystudy/app/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skystudy/app/utils/auth_manager.dart';
import 'dart:math'; // Thêm import để sử dụng Random

class ProfileController extends GetxController {
  var username = ''.obs;
  var email = ''.obs;
  var points = 0.obs;
  var rank = 0.obs;
  var isLoading = true.obs;
  var avatarName = ''.obs; // Thêm thuộc tính để lưu tên avatar

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      isLoading.value = true;
      final token = await AuthManager.getToken();

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Token is missing. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['user']; // Dữ liệu nằm trong key "user"
        username.value = data['username'] ?? '';
        email.value = data['email'] ?? '';
        points.value = data['point'] ?? 0;
        rank.value = data['rank'] ?? 0;

        // Nếu không có avatar, gán avatar ngẫu nhiên
        if (data['avatar'] == null || data['avatar'].isEmpty) {
          final randomIndex = Random().nextInt(30); // Random từ 0 đến 29
          avatarName.value = 'avatar_$randomIndex';
        } else {
          avatarName.value = data['avatar'] ?? 'default_avatar'; // Lấy avatar từ API hoặc gán giá trị mặc định
        }
      } else if (response.statusCode == 401) {
        Get.snackbar('Unauthorized', 'Your session has expired. Please log in again.');
      } else {
        Get.snackbar('Error', 'Failed to fetch profile data: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAvatar(String avatarName) async {
    try {
      final token = await AuthManager.getToken();

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Token is missing. Please log in again.');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/updateAvatar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'avatar': avatarName}), // Gửi body với key "avatar"
      );

      if (response.statusCode == 200) {
        this.avatarName.value = avatarName; // Cập nhật avatarName sau khi thành công
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update avatar: ${response.statusCode} - ${response.reasonPhrase}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }
}