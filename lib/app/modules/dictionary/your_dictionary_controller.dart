import 'package:get/get.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_service.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_model.dart';
import 'package:logger/logger.dart';

class YourDictionaryController extends GetxController {
  final DictionaryApi _dictionaryApi = DictionaryApi();
  final Rx<Map<String, List<Dictionary>>?> _yourDictionaryWords = Rx<Map<String, List<Dictionary>>?>(null);
  final RxString _errorMessage = ''.obs;
  final RxBool _isLoading = true.obs;

  final Logger _logger = Logger();
  bool _isMounted = true;

  Map<String, List<Dictionary>>? get yourDictionaryWords => _yourDictionaryWords.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchYourDictionary();
  }

  @override
  void onClose() {
    _isMounted = false;
    _logger.i('YourDictionaryController disposed');
    super.onClose();
  }

  Future<void> fetchYourDictionary() async {
    _isLoading.value = true;
    try {
      final startTime = DateTime.now();
      _yourDictionaryWords.value = await _dictionaryApi.getYourDictionary().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.e('API call for your dictionary timed out after 10 seconds');
          throw Exception('Request timed out after 10 seconds');
        },
      );
      _errorMessage.value = '';
      _logger.i(
        'Your dictionary loaded: ${_yourDictionaryWords.value?.keys.toList() ?? 'null'}',
      );
      _logger.i(
        'API call completed in ${DateTime.now().difference(startTime).inMilliseconds}ms',
      );
    } catch (e) {
      _errorMessage.value = 'từ điển của bạn rỗng';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchYourDictionary();
  }
}