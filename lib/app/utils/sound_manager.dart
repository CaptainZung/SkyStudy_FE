import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart';

class SoundManager {
  static final Logger logger = Logger();
  static final AudioPlayer _buttonPlayer = AudioPlayer();
  static final AudioPlayer _musicPlayer = AudioPlayer();
  static double _buttonVolume = 1.0;
  static double _musicVolume = 1.0;
  static int _currentMusicIndex = 0;
  static final List<String> _musicList = ['music1.mp3', 'music2.mp3'];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    _buttonVolume = prefs.getDouble('button_volume') ?? 1.0;
    _musicVolume = prefs.getDouble('music_volume') ?? 1.0;
    _currentMusicIndex = prefs.getInt('current_music_index') ?? 0;

    // Đảm bảo âm lượng nhạc không bị tắt hoàn toàn khi khởi tạo
    if (_musicVolume == 0.0) {
      _musicVolume = 0.5; // Đặt mức mặc định nếu bị tắt
      await prefs.setDouble('music_volume', _musicVolume);
    }

    // Thiết lập âm lượng ban đầu
    logger.i('Button volume: $_buttonVolume');
    logger.i('Music volume: $_musicVolume');
    await _buttonPlayer.setVolume(_buttonVolume);
    await _musicPlayer.setVolume(_musicVolume);

    // Preload âm thanh button.mp3
    await preloadButtonSound();

    // Phát nhạc nền và thiết lập vòng lặp
    await playMusic();
    _musicPlayer.onPlayerComplete.listen((event) {
      logger.i('Music completed: ${_musicList[_currentMusicIndex]}');
      _currentMusicIndex = (_currentMusicIndex + 1) % _musicList.length;
      saveCurrentMusicIndex(_currentMusicIndex);
      playMusic();
    });
  }

  static Future<void> preloadButtonSound() async {
    try {
      await _buttonPlayer.setSource(AssetSource('audio/button.mp3'));
      logger.i('Button sound preloaded successfully');
    } catch (e) {
      logger.e('Error preloading button sound: $e');
      Get.snackbar('Lỗi', 'Không thể tải âm thanh nút: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> saveButtonVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    _buttonVolume = volume;
    await _buttonPlayer.setVolume(volume);
    await prefs.setDouble('button_volume', volume);
    logger.i('Saved button volume: $volume');
  }

  static Future<void> saveMusicVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
    await prefs.setDouble('music_volume', volume);
    logger.i('Saved music volume: $volume');
  }

  static Future<void> saveCurrentMusicIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _currentMusicIndex = index;
    await prefs.setInt('current_music_index', index);
    logger.i('Saved current music index: $index');
  }

  static double get buttonVolume => _buttonVolume;
  static double get musicVolume => _musicVolume;
  static int get currentMusicIndex => _currentMusicIndex;
  static List<String> get musicList => _musicList;

  static Future<void> playButtonSound() async {
    try {
      await _buttonPlayer.stop();
      await _buttonPlayer.play(AssetSource('audio/button.mp3'));
      logger.i('Button sound played');
    } catch (e) {
      logger.e('Error playing button sound: $e');
      Get.snackbar('Lỗi', 'Không thể phát âm thanh nút: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> playMusic() async {
    try {
      await _musicPlayer.stop();
      logger.i('Playing music: ${_musicList[_currentMusicIndex]} with volume: $_musicVolume');
      await _musicPlayer.play(
        AssetSource('audio/${_musicList[_currentMusicIndex]}'),
        volume: _musicVolume,
      );
    } catch (e) {
      logger.e('Error playing music: $e');
      Get.snackbar('Lỗi', 'Không thể phát nhạc nền: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      logger.i('Music stopped');
    } catch (e) {
      logger.e('Error stopping music: $e');
    }
  }
}