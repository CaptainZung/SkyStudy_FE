import 'dart:convert' ;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:skystudy/app/api/ai_api.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class DetectionResultController extends GetxController {
  var isGenerating = false.obs;
  late List<Map<String, dynamic>> detectedObjects;
  late String processedImageBase64;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments ?? {};
    detectedObjects = args['detectedObjects']?.cast<Map<String, dynamic>>() ?? [];
    processedImageBase64 = args['processedImageBase64']?.toString() ?? '';
  }

  Future<void> generateSentence(Map<String, dynamic> object) async {
    try {
      isGenerating.value = true;
      final response = await http.post(
        Uri.parse(ApiConfig.generateSentenceEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'word': object['label']}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        Get.toNamed(
          Routes.aispeech,
          arguments: {
            'detectedObjects': [object],
            'sentence': data['sentence'],
            'translated_sentence': data['translated_sentence'],
          },
        );
      } else {
        Get.snackbar('Lỗi', 'Không thể sinh câu: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi gọi API: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  void onTtsPressed(Map<String, dynamic> object) {
    Get.toNamed(
      Routes.pronunciationcheck,
      arguments: {
        'sampleSentence': object['label'], // Truyền từ nhận diện (ví dụ: "water bottle")
      },
    );
  }
}