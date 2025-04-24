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
  static bool _isLooping = true; // Luôn bật chế độ vòng lặp cho bài nhạc
  static final String _musicTrack = 'music1.mp3'; // Chỉ dùng 1 bài nhạc
  static bool _isMusicPlaying = false; // Trạng thái nhạc nền
  static bool _isButtonPlaying = false; // Trạng thái kiểm tra âm thanh nút

  static Future<void> init() async {
    logger.i('Bắt đầu khởi tạo SoundManager');
    final prefs = await SharedPreferences.getInstance();

    _buttonVolume = prefs.getDouble('button_volume') ?? 1.0;
    _musicVolume = prefs.getDouble('music_volume') ?? 1.0;
    _isLooping = prefs.getBool('is_looping') ?? true;

    if (_musicVolume == 0.0) {
      _musicVolume = 0.5;
      await prefs.setDouble('music_volume', _musicVolume);
    }

    logger.i('Âm lượng nút: $_buttonVolume');
    logger.i('Âm lượng nhạc: $_musicVolume');
    logger.i('Chế độ vòng lặp bài nhạc: $_isLooping');
    await _buttonPlayer.setVolume(_buttonVolume);
    await _musicPlayer.setVolume(_musicVolume);

    // Thiết lập chế độ vòng lặp cho bài nhạc
    await _musicPlayer.setLoopMode(
        _isLooping ? just_audio.LoopMode.one : just_audio.LoopMode.off);

    await preloadButtonSound();
    await playMusic();

    logger.i('Khởi tạo SoundManager thành công');
  }

  // Phương thức để bật/tắt chế độ vòng lặp bài nhạc
  static Future<void> toggleLooping() async {
    final prefs = await SharedPreferences.getInstance();
    _isLooping = !_isLooping;
    await prefs.setBool('is_looping', _isLooping);
    await _musicPlayer.setLoopMode(
        _isLooping ? just_audio.LoopMode.one : just_audio.LoopMode.off);
    logger.i('Chế độ vòng lặp bài nhạc: $_isLooping');
  }

  // Getter để kiểm tra trạng thái vòng lặp
  static bool get isLooping => _isLooping;

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

  static double get buttonVolume => _buttonVolume;
  static double get musicVolume => _musicVolume;

  static Future<void> playButtonSound() async {
    if (_isButtonPlaying) return; // Nếu đang phát, không cho phép phát thêm

    try {
      _isButtonPlaying = true; // Đặt trạng thái đang phát
      await _buttonPlayer.stop();
      await _buttonPlayer.setAsset('assets/audio/button.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh nút');
    } catch (e) {
      logger.e('Lỗi phát âm thanh nút: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh nút: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      _isButtonPlaying = false; // Đặt lại trạng thái sau khi phát xong
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
      await _buttonPlayer.setAsset('assets/audio/wrong.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh sai');
    } catch (e) {
      logger.e('Lỗi phát âm thanh sai: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh sai: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
  static Future<void> playCorrectSound1() async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.setAsset('assets/audio/correct1.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh đúng');
    } catch (e) {
      logger.e('Lỗi phát âm thanh đúng: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh đúng: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> playWrongSound1() async {
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
      if (_isMusicPlaying) return; // Nếu nhạc đã phát, không phát lại
      await _musicPlayer.stop();
      logger.i('Đặt nguồn: assets/audio/$_musicTrack');
      await _musicPlayer.setAsset('assets/audio/$_musicTrack');
      logger.i('Phát nhạc: $_musicTrack với âm lượng: $_musicVolume');
      await _musicPlayer.play();
      _isMusicPlaying = true;
    } catch (e) {
      logger.e('Lỗi phát nhạc: $e');
      // Retry if error indicates "Connection aborted" or "Loading interrupted"
      if (e.toString().contains("Connection aborted") || e.toString().contains("Loading interrupted")) {
        logger.i('Retrying playing music after error...');
        await Future.delayed(Duration(seconds: 1));
        return playMusic();
      }
      Get.snackbar('Lỗi', 'Không thể phát nhạc nền: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> stopMusic() async {
    try {
      if (!_isMusicPlaying) return; // Nếu nhạc chưa phát, không làm gì
      await _musicPlayer.stop();
      _isMusicPlaying = false; // Cập nhật trạng thái nhạc nền
      logger.i('Dừng nhạc');
    } catch (e) {
      logger.e('Lỗi dừng nhạc: $e');
    }
  }

  static Future<void> pauseMusic() async {
    try {
      if (!_isMusicPlaying) return; // Nếu nhạc chưa phát, không làm gì
      await _musicPlayer.pause();
      _isMusicPlaying = false; // Cập nhật trạng thái nhạc nền
      logger.i('Tạm dừng nhạc');
    } catch (e) {
      logger.e('Lỗi tạm dừng nhạc: $e');
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

  static Future<void> preloadShotSound() async {
    try {
      await _buttonPlayer.setAsset('assets/audio/shot.mp3');
      logger.i('Tải trước âm thanh chụp ảnh thành công');
    } catch (e) {
      logger.e('Lỗi tải trước âm thanh chụp ảnh: $e');
      Get.snackbar('Lỗi', 'Không thể tải âm thanh chụp ảnh: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> playShotSound() async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.setAsset('assets/audio/shot.mp3');
      await _buttonPlayer.play();
      logger.i('Phát âm thanh chụp ảnh');
    } catch (e) {
      logger.e('Lỗi phát âm thanh chụp ảnh: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh chụp ảnh: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}