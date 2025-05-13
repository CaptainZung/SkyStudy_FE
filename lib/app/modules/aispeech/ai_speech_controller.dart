import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:skystudy/app/api/ai_api.dart';
import 'package:logger/logger.dart';

class AISpeechController extends GetxController {
  var isPlaying = false.obs;
  var highlightedWordIndex = (-1).obs; // Chỉ số từ đang được highlight
  var selectedVoice = 'female'.obs; // Trạng thái giọng nói (male/female)
  var isPaused = false.obs; // Trạng thái tạm dừng
  late List<Map<String, dynamic>> detectedObjects;
  late String sentence;
  late String translatedSentence;
  late List<String> words; // Danh sách các từ trong câu
  final Logger logger = Logger();
  AudioPlayer audioPlayer = AudioPlayer();
  String audioBase64 = '';

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments ?? {};
    detectedObjects = args['detectedObjects']?.cast<Map<String, dynamic>>() ?? [];
    sentence = args['sentence']?.toString() ?? '';
    translatedSentence = args['translated_sentence']?.toString() ?? '';
    // Tách câu thành danh sách từ, loại bỏ ký tự đặc biệt và đảm bảo khoảng trắng
    words = sentence
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Thay ký tự đặc biệt bằng khoảng trắng
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    logger.i('AISpeechController initialized. Sentence: $sentence, Translated: $translatedSentence');
  }

  // Hàm để chuyển đổi giọng nói
  void toggleVoice() {
    selectedVoice.value = (selectedVoice.value == 'female') ? 'male' : 'female';
    audioBase64 = ''; // Xóa audio cũ để fetch lại với giọng mới
    isPlaying.value = false;
    isPaused.value = false;
    highlightedWordIndex.value = -1;
    audioPlayer.stop(); // Dừng audio khi chuyển giọng
  }

  Future<void> fetchAudio() async {
    try {
      // Làm sạch chuỗi sentence trước khi gửi
      String cleanSentence = sentence
          .replaceAll(RegExp(r'[^\w\s]'), '') // Loại bỏ ký tự đặc biệt
          .trim(); // Loại bỏ khoảng trắng thừa

      final response = await http.post(
        Uri.parse(ApiConfig.audioEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'word': cleanSentence, // Gửi chuỗi đã làm sạch
          'voice': selectedVoice.value, // Sử dụng giọng nói đã chọn
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        audioBase64 = data['audio_base64']?.toString() ?? '';
        logger.i('Audio fetched successfully. Base64 length: ${audioBase64.length}');
      } else {
        logger.e('Error response: ${response.body}'); // In chi tiết lỗi từ backend
        Get.snackbar('Lỗi', 'Không thể lấy audio: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi gọi API audio: $e');
      logger.e('Error fetching audio: $e');
    }
  }

  Future<void> playAudio() async {
    // Nếu đang tạm dừng, tiếp tục phát
    if (isPaused.value) {
      isPaused.value = false;
      isPlaying.value = true;
      await audioPlayer.resume();
      _continueHighlighting();
      return;
    }

    // Nếu không có audio, fetch audio mới
    if (audioBase64.isEmpty) {
      await fetchAudio();
    }

    if (audioBase64.isEmpty) {
      Get.snackbar('Lỗi', 'Không có dữ liệu âm thanh để phát.');
      return;
    }

    try {
      isPlaying.value = true;
      highlightedWordIndex.value = -1;

      final audioBytes = base64Decode(audioBase64);
      await audioPlayer.play(BytesSource(audioBytes));

      _startHighlighting();
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi phát âm thanh: $e');
      logger.e('Error playing audio: $e');
      isPlaying.value = false;
      isPaused.value = false;
      highlightedWordIndex.value = -1;
    }
  }

  Future<void> pauseAudio() async {
    if (isPlaying.value && !isPaused.value) {
      isPaused.value = true;
      isPlaying.value = false;
      await audioPlayer.pause();
    }
  }

  Future<void> _startHighlighting() async {
    audioPlayer.onPositionChanged.listen((Duration position) async {
      if (!isPlaying.value) return;

      // Await the duration and calculate the word index
      Duration? totalDuration = await audioPlayer.getDuration();
      if (totalDuration != null) {
        int wordIndex = (position.inMilliseconds / totalDuration.inMilliseconds * words.length).floor();
        if (wordIndex < words.length) {
          highlightedWordIndex.value = wordIndex;
        }
      }
    });

    audioPlayer.onPlayerComplete.listen((event) {
      isPlaying.value = false;
      isPaused.value = false;
      highlightedWordIndex.value = -1;
    });
  }

  Future<void> _continueHighlighting() async {
    for (int i = highlightedWordIndex.value + 1; i < words.length; i++) {
      if (!isPlaying.value) break;
      highlightedWordIndex.value = i;
      await Future.delayed(const Duration(milliseconds: 350));
    }
    if (isPlaying.value) {
      isPlaying.value = false;
      isPaused.value = false;
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