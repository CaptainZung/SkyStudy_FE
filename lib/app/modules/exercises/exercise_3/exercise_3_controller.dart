import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart' as flutter_sound;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:skystudy/app/modules/exercises/exercise_utils.dart';
import 'lesson_model.dart';
import 'lesson_service.dart';
import 'package:skystudy/app/api/ai_api.dart';
import 'package:skystudy/app/utils/sound_manager.dart';
import 'package:skystudy/app/routes/app_pages.dart';
import 'package:logger/logger.dart';

class Exercise3Controller extends GetxController {
  final logger = Logger();
  flutter_sound.FlutterSoundRecorder? _recorder;
  audioplayers.AudioPlayer audioPlayer = audioplayers.AudioPlayer();

  Rxn<LessonModel> lesson = Rxn<LessonModel>();
  var isRecording = false.obs;
  var isProcessing = false.obs;
  var recognizedText = ''.obs;
  var accuracy = 0.0.obs;
  var pronunciationFeedback = ''.obs;
  var ttsAudioBase64 = ''.obs;
  var sampleSentenceAudioBase64 = ''.obs;
  var isPlayingTts = false.obs;
  var isPlayingSampleSentence = false.obs;
  var lottieAnimationPath = ''.obs;
  var feedbackMessage = ''.obs;
  var enableContinueButton = true.obs;

  List<int>? _recordedAudioBytes;
  StreamController<Uint8List>? _streamController;

  late String topic;
  late int node;
  late int exercise;

  @override
  void onInit() {
    super.onInit();
    _recorder = flutter_sound.FlutterSoundRecorder();
    _initRecorder();

    try {
      topic = Get.arguments['topic'] ?? 'Animal';
      node = Get.arguments['node'] ?? 1;
      exercise = Get.arguments['exercise'] ?? 3;

      logger.i('✅ onInit - topic: $topic, node: $node, exercise: $exercise');
      loadLesson(topic, node);
    } catch (e) {
      logger.e('⛔ Error in onInit: $e');
    }
  }

  Future<void> _initRecorder() async {
    await _recorder!.openRecorder();
    if (!await Permission.microphone.isGranted) {
      await Permission.microphone.request();
    }
    await _recorder!.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  Future<void> loadLesson(String topic, int node) async {
    try {
      final data = await LessonService.fetchLesson(topic, node);
      lesson.value = data;
      logger.i('📥 Lesson loaded: ${data.word}');
      fetchAudio();
    } catch (e) {
      logger.e('❌ Failed to load lesson: $e');
      Get.snackbar('Lỗi', 'Không thể tải bài học');
    }
  }

  Future<void> fetchAudio() async {
    try {
      String cleanSentence = (lesson.value?.word ?? '').replaceAll(RegExp(r'[^\w\s]'), '').trim();
      final response = await http.post(
        Uri.parse(ApiConfig.audioEndpoint),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'word': cleanSentence,
          'voice': 'female',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sampleSentenceAudioBase64.value = data['audio_base64']?.toString() ?? '';
      } else {
        Get.snackbar('Lỗi', 'Không thể lấy audio: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi gọi API audio: $e');
    }
  }

  Future<void> startRecording() async {
    if (!await Permission.microphone.isGranted) return;

    isRecording.value = true;
    _recordedAudioBytes = [];
    _streamController = StreamController<Uint8List>();

    await _recorder!.startRecorder(
      codec: flutter_sound.Codec.pcm16WAV,
      sampleRate: 44100,
      numChannels: 1,
      toStream: _streamController!.sink,
    );

    _streamController!.stream.listen((data) => _recordedAudioBytes!.addAll(data));
  }

  Future<void> stopRecording() async {
    if (isRecording.value) {
      await _recorder!.stopRecorder();
      await _streamController?.close();
      isRecording.value = false;

      if (_recordedAudioBytes != null && _recordedAudioBytes!.isNotEmpty) {
        await _sendPronunciationCheck();
      }
    }
  }

  Future<void> _sendPronunciationCheck() async {
    isProcessing.value = true;
    try {
      final audioWithHeader = addWavHeader(_recordedAudioBytes!, 44100, 1, 16);
      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.pronunciationCheckEndpoint));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        audioWithHeader,
        filename: 'pronunciation_check.wav',
        contentType: MediaType('audio', 'wav'),
      ));
      request.fields['sample_sentence'] = lesson.value?.word ?? '';

      logger.i("Gửi sample_sentence: ${lesson.value?.word}");

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        recognizedText.value = data['recognized_text'] ?? '';
        accuracy.value = (data['accuracy'] ?? 0.0).toDouble();
        pronunciationFeedback.value = data['pronunciation_feedback'] ?? '';
        ttsAudioBase64.value = data['tts_audio_base64'] ?? '';

        lottieAnimationPath.value = accuracy.value >= 0.8 ? 'assets/lottie/dung.json' : 'assets/lottie/sai.json';
        feedbackMessage.value = accuracy.value >= 0.8 ? 'Phát âm rất tốt!' : 'Hãy thử lại nhé!';

        // Update UI state before playing sound
        enableContinueButton.value = accuracy.value >= 0.8;

        // Hide loading animation immediately after processing
        isProcessing.value = false;

        // Play sound after UI is updated
        if (accuracy.value >= 0.8) {
          await SoundManager.playCorrectSound1();
        } else {
          await SoundManager.playWrongSound1();
        }

        logger.i('✅ Kết quả từ server:');
        logger.i('🔤 Text: ${recognizedText.value}');
        logger.i('🎯 Accuracy: ${accuracy.value}');
      } else {
        logger.e('❌ Server error ${response.statusCode}');
        logger.e('📥 Response: $responseData');
        Get.snackbar('Lỗi', 'Kiểm tra phát âm thất bại: $responseData');
      }
    } catch (e) {
      logger.e('💥 Lỗi khi kiểm tra phát âm: $e');
      Get.snackbar('Lỗi', 'Lỗi khi kiểm tra phát âm: $e');
    } finally {
      // Ensure isProcessing is false, though this should already be handled above
      if (isProcessing.value) {
        isProcessing.value = false;
      }
    }
  }

  Future<void> playSampleSentenceAudio() async {
    if (sampleSentenceAudioBase64.value.isEmpty) {
      await fetchAudio();
    }
    if (sampleSentenceAudioBase64.value.isNotEmpty) {
      try {
        isPlayingSampleSentence.value = true;
        final audioBytes = base64Decode(sampleSentenceAudioBase64.value);
        await audioPlayer.play(audioplayers.BytesSource(audioBytes));
        audioPlayer.onPlayerStateChanged.listen((state) {
          if (state == audioplayers.PlayerState.completed) {
            isPlayingSampleSentence.value = false;
          }
        });
      } catch (e) {
        Get.snackbar('Lỗi', 'Lỗi khi phát âm thanh: $e');
        isPlayingSampleSentence.value = false;
      }
    }
  }

  Future<void> playTtsAudio() async {
    if (ttsAudioBase64.value.isNotEmpty) {
      try {
        isPlayingTts.value = true;
        final audioBytes = base64Decode(ttsAudioBase64.value);
        await audioPlayer.play(audioplayers.BytesSource(audioBytes));
        audioPlayer.onPlayerStateChanged.listen((state) {
          if (state == audioplayers.PlayerState.completed) {
            isPlayingTts.value = false;
          }
        });
      } catch (e) {
        Get.snackbar('Lỗi', 'Lỗi khi phát âm thanh: $e');
        isPlayingTts.value = false;
      }
    }
  }

  void resetState() {
    recognizedText.value = '';
    accuracy.value = 0.0;
    pronunciationFeedback.value = '';
    ttsAudioBase64.value = '';
    isPlayingTts.value = false;
    lottieAnimationPath.value = '';
    feedbackMessage.value = '';
    enableContinueButton.value = true;
  }

  void goToNextExercise() {
    if (exercise < 4) {
      final nextExercise = exercise + 1;
      final nextRoute = getRouteByExercise(nextExercise);

      if (nextRoute != null) {
        Get.offNamed(
          nextRoute,
          arguments: {'topic': topic, 'node': node, 'exercise': nextExercise},
        );
      }
    } else {
      Get.snackbar('Hoàn thành', 'Bạn đã hoàn tất bài học này 🎉');
      Get.offNamed(Routes.home);
    }
  }

  @override
  void onClose() {
    _recorder?.closeRecorder();
    audioPlayer.dispose();
    _streamController?.close();
    super.onClose();
  }

  Uint8List addWavHeader(List<int> pcmData, int sampleRate, int numChannels, int bitsPerSample) {
    final byteLength = pcmData.length;
    final totalLength = byteLength + 44 - 8;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final blockAlign = numChannels * bitsPerSample ~/ 8;

    final header = BytesBuilder();
    header.add('RIFF'.codeUnits);
    header.add([totalLength & 0xFF, (totalLength >> 8) & 0xFF, (totalLength >> 16) & 0xFF, (totalLength >> 24) & 0xFF]);
    header.add('WAVE'.codeUnits);
    header.add('fmt '.codeUnits);
    header.add([16, 0, 0, 0]);
    header.add([1, 0]);
    header.add([numChannels & 0xFF, 0]);
    header.add([sampleRate & 0xFF, (sampleRate >> 8) & 0xFF, (sampleRate >> 16) & 0xFF, (sampleRate >> 24) & 0xFF]);
    header.add([byteRate & 0xFF, (byteRate >> 8) & 0xFF, (byteRate >> 16) & 0xFF, (byteRate >> 24) & 0xFF]);
    header.add([blockAlign & 0xFF, 0]);
    header.add([bitsPerSample & 0xFF, 0]);
    header.add('data'.codeUnits);
    header.add([byteLength & 0xFF, (byteLength >> 8) & 0xFF, (byteLength >> 16) & 0xFF, (byteLength >> 24) & 0xFF]);
    header.add(pcmData);

    return header.toBytes();
  }
}