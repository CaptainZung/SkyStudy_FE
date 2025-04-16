import 'dart:convert';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:skystudy/app/modules/exercises/exercise_utils.dart';
import 'lesson_model.dart';
import 'lesson_service.dart';
import 'package:skystudy/app/api/ai_api.dart';
import 'package:logger/logger.dart';

class Exercise3Controller extends GetxController {
  final logger = Logger();
  FlutterSoundRecorder? _recorder;
  audioplayers.AudioPlayer _audioPlayer = audioplayers.AudioPlayer();

  Rxn<LessonModel> lesson = Rxn<LessonModel>();
  var isRecording = false.obs;
  var isProcessing = false.obs;
  var recognizedText = ''.obs;
  var accuracy = 0.0.obs;
  var pronunciationFeedback = ''.obs;
  var enableContinueButton = true.obs;

  String? recordedFilePath;

  late String topic;
  late int node;
  late int exercise;

  @override
  void onInit() {
    super.onInit();

    logger.i('📥 Get.arguments: ${Get.arguments}');

    try {
      topic = Get.arguments['topic'] ?? 'Animal';
      node = Get.arguments['node'] ?? 1;
      exercise = Get.arguments['exercise'] ?? 3;

      logger.i('✅ onInit - topic: $topic, node: $node, exercise: $exercise');
      loadLesson(topic, node); // Luôn luôn tải bài học đầu tiên trong node
    } catch (e) {
      logger.e('⛔ Error in onInit: $e');
    }
  }

  Future<void> initRecorder() async {
    await _recorder!.openRecorder();
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> loadLesson(String topic, int node) async {
    try {
      final data = await LessonService.fetchLesson(topic, node);
      lesson.value = data;
      logger.i('📥 Lesson loaded: ${data.word}');
    } catch (e) {
      logger.e('❌ Failed to load lesson: $e');
      Get.snackbar('Lỗi', 'Không thể tải bài học');
    }
  }

  Future<void> playSampleAudio() async {
    try {
      await _audioPlayer.play(
        audioplayers.UrlSource(lesson.value!.sound),
      );
    } catch (e) {
      logger.e('🎧 Không thể phát audio: $e');
    }
  }

  Future<void> startRecording() async {
    if (!await Permission.microphone.isGranted) return;

    isRecording.value = true;

    final tempDir = await getTemporaryDirectory();
    recordedFilePath = '${tempDir.path}/recorded.wav';

    logger.i('🎙️ Bắt đầu ghi vào: $recordedFilePath');

    await _recorder!.startRecorder(
      codec: Codec.pcm16WAV,
      toFile: recordedFilePath,
      sampleRate: 44100,
      numChannels: 1,
    );
  }

  Future<void> stopRecording() async {
    if (!isRecording.value) return;

    await _recorder!.stopRecorder();
    isRecording.value = false;

    final file = File(recordedFilePath!);
    if (!file.existsSync()) {
      logger.e('❌ Không tìm thấy file ghi âm');
      Get.snackbar('Lỗi', 'Không tìm thấy file ghi âm');
      return;
    }

    final fileSize = await file.length();
    logger.i('📁 File audio size: $fileSize bytes');

    if (fileSize < 5000) {
      logger.w('⚠️ Ghi âm quá ngắn, không gửi lên server');
      Get.snackbar('Ghi âm quá ngắn', 'Hãy giữ mic lâu hơn và phát âm rõ ràng.');
      return;
    }

    await sendToServer(file.path);
  }

  Future<void> sendToServer(String filePath) async {
    isProcessing.value = true;
    try {
      final sampleSentence = (lesson.value?.word ?? '')
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .toLowerCase();

      logger.i('📤 Gửi phát âm đến server...');
      logger.i('📤 sample_sentence: $sampleSentence');
      logger.i('📤 file: $filePath');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.pronunciationCheckEndpoint),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('audio', 'wav'),
      ));

      request.fields['sample_sentence'] = sampleSentence;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        recognizedText.value = data['recognized_text'] ?? '';
        accuracy.value = (data['accuracy'] ?? 0.0).toDouble();
        pronunciationFeedback.value = data['pronunciation_feedback'] ?? '';

        logger.i('✅ Kết quả từ server:');
        logger.i('🔤 Text: ${recognizedText.value}');
        logger.i('🎯 Accuracy: ${accuracy.value}');
      } else {
        logger.e('❌ Server error ${response.statusCode}');
        logger.e('📥 Response: $responseData');
        Get.snackbar('Lỗi', 'Không thể kiểm tra phát âm');
      }
    } catch (e) {
      logger.e('💥 Lỗi khi gửi phát âm: $e');
      Get.snackbar('Lỗi', 'Không thể gửi file âm thanh');
    } finally {
      isProcessing.value = false;

      // Tự xoá file sau khi dùng
      try {
        if (recordedFilePath != null && File(recordedFilePath!).existsSync()) {
          File(recordedFilePath!).deleteSync();
          logger.i('🗑️ Đã xoá file tạm');
        }
      } catch (_) {}
    }
  }

  @override
  void onClose() {
    _recorder?.closeRecorder();
    _audioPlayer.dispose();
    super.onClose();
  }

  void goToNextExercise() {
    if (exercise < 4) { // Kiểm tra xem còn bài tập nào trong node không
      final nextExercise = exercise + 1; // Tăng số bài tập lên 1
      final nextRoute = getRouteByExercise(nextExercise);  // Lấy route của bài tập tiếp theo

      if (nextRoute != null) {
        Get.toNamed(
          nextRoute,
          arguments: {'topic': topic, 'node': node, 'exercise': nextExercise}, // Truyền topic, node, exercise vào page mới
        );
      }
    } else {
      // Nếu là bài tập cuối (exercise == 4), thông báo hoàn tất bài học
      Get.snackbar('Hoàn thành', 'Bạn đã hoàn tất bài học này 🎉');
    }
  }
}
