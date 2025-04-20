import 'package:get/get.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_service.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_model.dart';
import 'package:logger/logger.dart';

class DictionaryController extends GetxController {
  final DictionaryApi _dictionaryApi = DictionaryApi();
  final Rx<Map<String, List<Dictionary>>?> _allWords =
      Rx<Map<String, List<Dictionary>>?>(null);
  final Rx<Map<String, List<Dictionary>>?> _filteredWords =
      Rx<Map<String, List<Dictionary>>?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isLoading = true.obs;


  final Logger _logger = Logger();
  bool _isMounted = true; // Thêm kiểm tra mounted

  Map<String, List<Dictionary>>? get filteredWords => _filteredWords.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchData(); // Chuyển fetchData vào onInit thay vì constructor
  }

  @override
  void onClose() {
    _isMounted = false;
    _logger.i('DictionaryController disposed');
    super.onClose();
  }

  Future<void> fetchData() async {
    _isLoading.value = true;
    try {
      final startTime = DateTime.now();
      _allWords.value = await _dictionaryApi.getTopWordsByTopic().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out after 10 seconds');
        },
      );
      _logger.i(
        'API call completed in ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );
      _filteredWords.value = _allWords.value;
      _errorMessage.value = '';
    } catch (e, stackTrace) {
      _errorMessage.value = e.toString();
      _logger.e(
        'Error occurred while fetching data: $e',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchData(); // Tái sử dụng fetchData để làm mới
  }

  void filterWords(String query) {
    if (!_isMounted || _allWords.value == null) return;
    _logger.i('Filtering words with query: $query');

    // Thêm debounce để giảm tần suất lọc
    debounce(
      _filteredWords,
      (_) {
        if (query.isEmpty) {
          _filteredWords.value = _allWords.value;
          _logger.i('No query entered, showing all words');
        } else {
          Map<String, List<Dictionary>> filtered = {};
          _allWords.value!.forEach((topic, words) {
            final filteredWords =
                words
                    .where(
                      (word) =>
                          word.word.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ||
                          word.vietnamese.toLowerCase().contains(
                            query.toLowerCase(),
                          ),
                    )
                    .toList();
            if (filteredWords.isNotEmpty) {
              filtered[topic] = filteredWords;
            }
          });
          _filteredWords.value = filtered;
          _logger.i('Found ${filtered.length} topics matching the query');
        }
      },
      time: const Duration(milliseconds: 300), // Chờ 300ms trước khi lọc
    );
  }

  Future<List<Dictionary>> fetchWordByTopic(String topic) async {
    _logger.i('Fetching words for topic: $topic');
    try {
      final words = await _dictionaryApi
          .getWordByTopic(topic)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              _logger.e(
                'API call for topic "$topic" timed out after 10 seconds',
              );
              throw Exception('Request timed out after 10 seconds');
            },
          );
      _logger.i('Fetched ${words.length} words for topic "$topic"');
      return words;
    } catch (e) {
      _logger.e('Error fetching words for topic "$topic": $e');
      throw Exception('Error fetching words for topic "$topic": $e');
    }
  }

}