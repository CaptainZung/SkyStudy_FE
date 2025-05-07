import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/auth_manager.dart';
import '../../api/api_config.dart';
import 'package:skystudy/app/modules/profile/profile_controller.dart';

class DailyCheckController extends GetxController {
  RxList<bool> checkedDays = List.generate(7, (_) => false).obs;
  var isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchCheckInDays();
  }

  Future<void> fetchCheckInDays() async {
    try {
      final token = await AuthManager.getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/getCheckInDays'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        int dayLogin = data['day login'] ?? 0;
        checkedDays.value = List.generate(7, (i) => i < dayLogin);
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> fetchCheckInStatus() async {
    isLoading.value = true;
    try {
      final token = await AuthManager.getToken();
      if (token == null) throw Exception('Token is null');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/checkIn7Day'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('CheckIn response: ${response.statusCode} - ${response.body}');
      final shortBody = response.body.length > 100 ? response.body.substring(0, 100) + '...' : response.body;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'You have checked in today') {
          Get.snackbar('Thông báo', 'Bạn đã điểm danh hôm nay rồi!');
        } else {
          Get.snackbar('Thành công', 'Điểm danh thành công!');
        }
        await fetchCheckInDays(); // Cập nhật lại trạng thái tick sau khi điểm danh
        try {
          final profileController = Get.find<ProfileController>();
          await profileController.fetchProfileData();
        } catch (e) {}
      } else {
        Get.snackbar('Lỗi', 'Có lỗi xảy ra: ${response.statusCode} - ${shortBody}');
      }
    } catch (e) {
      final errMsg = e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString();
      print('CheckIn error: ${errMsg}');
      Get.snackbar('CheckIn Error', errMsg);
    } finally {
      isLoading.value = false;
    }
  }

  void closePopup() {
    Get.back();
  }
}
