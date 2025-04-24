import 'package:get/get.dart';
import 'package:skystudy/app/api/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skystudy/app/utils/auth_manager.dart';

class ProfileController extends GetxController {
  var username = ''.obs;
  var email = ''.obs;
  var points = 0.obs;
  var isLoading = true.obs;

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
        final data = json.decode(response.body)['data'];
        username.value = data['username'];
        email.value = data['email'];
        points.value = data['point'];
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

  Future<String?> getToken() async {
    // Implement token retrieval logic here
    return null;
  }
}