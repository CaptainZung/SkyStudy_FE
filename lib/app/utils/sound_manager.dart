import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

class SoundManager {
  static final Logger logger = Logger();
  static final just_audio.AudioPlayer _buttonPlayer = just_audio.AudioPlayer();
  static final just_audio.AudioPlayer _musicPlayer = just_audio.AudioPlayer();
  static double _buttonVolume = 1.0;
  static double _musicVolume = 1.0;
  static int _currentMusicIndex = 0;
  static bool _isLooping = false; // Chế độ vòng lặp cho bài nhạc hiện tại
  static bool _isPlaylistLooping = true; // Chế độ vòng lặp cho toàn bộ danh sách (mặc định bật)
  static final List<String> _musicList = ['music1.mp3', 'music2.mp3'];

  static Future<void> init() async {
    logger.i('Bắt đầu khởi tạo SoundManager');
    final prefs = await SharedPreferences.getInstance();

    _buttonVolume = prefs.getDouble('button_volume') ?? 1.0;
    _musicVolume = prefs.getDouble('music_volume') ?? 1.0;
    // Validate _currentMusicIndex when loading from SharedPreferences
    int savedIndex = prefs.getInt('current_music_index') ?? 0;
    _currentMusicIndex = savedIndex.clamp(0, _musicList.length - 1); // Ensure index is within bounds
    _isLooping = prefs.getBool('is_looping') ?? false;
    _isPlaylistLooping = prefs.getBool('is_playlist_looping') ?? true;

    if (_musicVolume == 0.0) {
      _musicVolume = 0.5;
      await prefs.setDouble('music_volume', _musicVolume);
    }

    logger.i('Âm lượng nút: $_buttonVolume');
    logger.i('Âm lượng nhạc: $_musicVolume');
    logger.i('Chế độ vòng lặp bài nhạc: $_isLooping');
    logger.i('Chế độ vòng lặp danh sách: $_isPlaylistLooping');
    logger.i('Chỉ số nhạc hiện tại: $_currentMusicIndex');
    await _buttonPlayer.setVolume(_buttonVolume);
    await _musicPlayer.setVolume(_musicVolume);

    await preloadButtonSound();
    await playMusic();

    _musicPlayer.playerStateStream.listen((state) async {
      if (state.processingState == just_audio.ProcessingState.completed) {
        logger.i('Nhạc hoàn thành: ${_musicList[_currentMusicIndex]}');
        if (_isLooping) {
          // Nếu chế độ vòng lặp bài nhạc được bật, phát lại bài hiện tại
          logger.i('Chế độ vòng lặp bài nhạc bật, phát lại: ${_musicList[_currentMusicIndex]}');
          await Future.delayed(const Duration(milliseconds: 500));
          await playMusic();
        } else if (_isPlaylistLooping) {
          // Nếu chế độ vòng lặp danh sách được bật, chuyển bài tiếp theo hoặc quay lại bài đầu
          _currentMusicIndex = (_currentMusicIndex + 1) % _musicList.length;
          await saveCurrentMusicIndex(_currentMusicIndex);
          await Future.delayed(const Duration(milliseconds: 500));
          logger.i('Chuẩn bị phát nhạc tiếp theo: ${_musicList[_currentMusicIndex]}');
          await playMusic();
        } else {
          // Nếu không bật vòng lặp danh sách, dừng lại sau bài cuối
          logger.i('Không bật vòng lặp danh sách, dừng phát nhạc');
          await stopMusic();
        }
      }
    });
    logger.i('Khởi tạo SoundManager thành công');
  }

  // Phương thức để bật/tắt chế độ vòng lặp bài nhạc
  static Future<void> toggleLooping() async {
    final prefs = await SharedPreferences.getInstance();
    _isLooping = !_isLooping;
    await prefs.setBool('is_looping', _isLooping);
    logger.i('Chế độ vòng lặp bài nhạc: $_isLooping');
  }

  // Phương thức để bật/tắt chế độ vòng lặp danh sách
  static Future<void> togglePlaylistLooping() async {
    final prefs = await SharedPreferences.getInstance();
    _isPlaylistLooping = !_isPlaylistLooping;
    await prefs.setBool('is_playlist_looping', _isPlaylistLooping);
    logger.i('Chế độ vòng lặp danh sách: $_isPlaylistLooping');
  }

  // Getter để kiểm tra trạng thái vòng lặp
  static bool get isLooping => _isLooping;
  static bool get isPlaylistLooping => _isPlaylistLooping;

  static Future<void> preloadButtonSound() async {
    try {
      await _buttonPlayer.setAsset('assets/audio/button.mp3');
      logger.i('Tải trước âm thanh nút thành công');
    } catch (e) {
      logger.e('Lỗi tải trước âm thanh nút: $e');
      Get.snackbar('Lỗi', 'Không thể tải âm thanh nút: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> saveButtonVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    _buttonVolume = volume;
    await _buttonPlayer.setVolume(volume);
    await prefs.setDouble('button_volume', volume);
    logger.i('Lưu âm lượng nút: $volume');
  }

  static Future<void> saveMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
    await prefs.setDouble('music_volume', volume);
    logger.i('Lưu âm lượng nhạc: $volume');
  }

  static Future<void> saveCurrentMusicIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _currentMusicIndex = index.clamp(0, _musicList.length - 1); // Ensure index is within bounds
    await prefs.setInt('current_music_index', _currentMusicIndex);
    logger.i('Lưu chỉ số nhạc hiện tại: $_currentMusicIndex');
  }

  static double get buttonVolume => _buttonVolume;
  static double get musicVolume => _musicVolume;
  static int get currentMusicIndex => _currentMusicIndex;
  static List<String> get musicList => _musicList;

  static Future<void> playButtonSound() async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.setAsset('assets/audio/button.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh nút');
    } catch (e) {
      logger.e('Lỗi phát âm thanh nút: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh nút: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> playCorrectSound() async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.setAsset('assets/audio/correct.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh đúng');
    } catch (e) {
      logger.e('Lỗi phát âm thanh đúng: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh đúng: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> playWrongSound() async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.setAsset('assets/audio/wrong1.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh sai');
    } catch (e) {
      logger.e('Lỗi phát âm thanh sai: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh sai: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> playMusic() async {
    try {
      // Validate _currentMusicIndex before accessing _musicList
      if (_currentMusicIndex < 0 || _currentMusicIndex >= _musicList.length) {
        logger.w('Chỉ số nhạc không hợp lệ: $_currentMusicIndex, đặt lại về 0');
        _currentMusicIndex = 0;
        await saveCurrentMusicIndex(_currentMusicIndex);
      }

      await _musicPlayer.stop();
      logger.i('Đặt nguồn: assets/audio/${_musicList[_currentMusicIndex]}');
      await _musicPlayer.setAsset('assets/audio/${_musicList[_currentMusicIndex]}');
      logger.i('Phát nhạc: ${_musicList[_currentMusicIndex]} với âm lượng: $_musicVolume');
      await _musicPlayer.play();
    } catch (e) {
      logger.e('Lỗi phát nhạc: $e');
      Get.snackbar('Lỗi', 'Không thể phát nhạc nền: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      logger.i('Dừng nhạc');
    } catch (e) {
      logger.e('Lỗi dừng nhạc: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _buttonPlayer.stop();
      await _musicPlayer.stop();
      logger.i('Dừng tất cả âm thanh: buttonPlayer và musicPlayer');
      await _buttonPlayer.dispose();
      await _musicPlayer.dispose();
      logger.i('Giải phóng tất cả audio players');
    } catch (e) {
      logger.e('Lỗi dừng tất cả âm thanh: $e');
    }
  }
}