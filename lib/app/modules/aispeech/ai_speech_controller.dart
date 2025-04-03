import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:skystudy/app/api/ai_api.dart';

class AISpeechController extends GetxController {
  var isPlaying = false.obs;
  var highlightedWordIndex = (-1).obs; // Chỉ số từ đang được highlight
  late List<Map<String, dynamic>> detectedObjects;
  late String sentence;
  late String translatedSentence;
  late List<String> words; // Danh sách các từ trong câu
  AudioPlayer audioPlayer = AudioPlayer();
  String audioBase64 = '';

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments ?? {};
    detectedObjects = args['detectedObjects']?.cast<Map<String, dynamic>>() ?? [];
    sentence = args['sentence']?.toString() ?? '';
    translatedSentence = args['translatedSentence']?.toString() ?? '';
    words = sentence.split(' '); // Tách câu thành danh sách các từ
    print('AISpeechController initialized. Sentence: $sentence, Translated: $translatedSentence');
  }

  Future<void> fetchAudio() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.audioEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'word': sentence, // Gửi toàn bộ câu để tạo audio
          'voice': 'female',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        audioBase64 = data['audio_base64'] ?? '';
        print('Audio fetched successfully. Base64 length: ${audioBase64.length}');
      } else {
        Get.snackbar('Lỗi', 'Không thể lấy audio: ${response.statusCode}');
        print('Failed to fetch audio: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi gọi API audio: $e');
      print('Error fetching audio: $e');
    }
  }

  Future<void> playAudio() async {
    if (audioBase64.isEmpty) {
      await fetchAudio(); // Lấy audio nếu chưa có
    }

    if (audioBase64.isEmpty) {
      Get.snackbar('Lỗi', 'Không có dữ liệu âm thanh để phát.');
      return;
    }

    try {
      isPlaying.value = true;
      highlightedWordIndex.value = -1;

      // Chuyển Base64 thành bytes
      final audioBytes = base64Decode(audioBase64);

      // Phát âm thanh
      await audioPlayer.play(BytesSource(audioBytes));

      // Tạo hiệu ứng highlight từng từ
      for (int i = 0; i < words.length; i++) {
        highlightedWordIndex.value = i;
        await Future.delayed(const Duration(milliseconds: 500)); // Thời gian delay giữa các từ
      }

      isPlaying.value = false;
      highlightedWordIndex.value = -1;
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi phát âm thanh: $e');
      print('Error playing audio: $e');
      isPlaying.value = false;
      highlightedWordIndex.value = -1;
    }
  }

  @override
  void onClose() {
    audioPlayer.stop();
    audioPlayer.dispose();
    super.onClose();
  }
}