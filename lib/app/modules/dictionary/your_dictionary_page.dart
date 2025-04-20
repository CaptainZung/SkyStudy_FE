import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_controller.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_model.dart';
import './yourDictionary_controller.dart';
import 'WordDetailScreen.dart';
import 'dictionary_page.dart'; // Để tái sử dụng SingleWordDetailScreen

class YourDictionaryPage extends StatelessWidget {
  YourDictionaryPage({super.key});

  final topicDescriptions = {
    'Family': 'Gia đình',
    'Animal': 'Động vật',
    'Sport': 'Thể thao',
    'Fruit': 'Trái cây',
    'Food': 'Thức ăn',
    'School': 'Trường học',
    'Travel': 'Du lịch',
    'Clothes': 'Quần áo',
  };

  @override
  Widget build(BuildContext context) {
    final YourDictionaryController controller = Get.put(YourDictionaryController());
    final DictionaryController dictionaryController = Get.find<DictionaryController>();

    return Scaffold(
      backgroundColor: const Color(0xFFC8E5EB),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2277B4)),
            ),
          );
        } else if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${controller.errorMessage}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2277B4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Thử lại',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else if (controller.yourDictionaryWords == null ||
            controller.yourDictionaryWords!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 50, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Không có từ vựng trong từ điển của bạn',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2277B4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Làm mới',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: const Color(0xFF2277B4),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.yourDictionaryWords!.keys.length,
            itemBuilder: (context, index) {
              String topic = controller.yourDictionaryWords!.keys.elementAt(index);
              List<Dictionary> words = controller.yourDictionaryWords![topic]!;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2277B4),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '$topic: ${topicDescriptions[topic] ?? 'Chưa có mô tả'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: words.map((word) => _buildWordItem(word)).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                final words =
                                    await dictionaryController.fetchWordByTopic(topic);
                                Get.to(
                                  () => WordDetailScreen(
                                    topic: topic,
                                    words: words,
                                  ),
                                  transition: Transition.rightToLeft,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Lỗi',
                                  'Không thể tải từ vựng cho chủ đề $topic: $e',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  borderRadius: 10,
                                  margin: const EdgeInsets.all(10),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2277B4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Color(0xFF2277B4),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('XEM THÊM TỪ VỰNG'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildWordItem(Dictionary word) {
    return InkWell(
      onTap: () {
        Get.to(
          () => SingleWordDetailScreen(word: word),
          transition: Transition.cupertino,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE47E24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.vietnamese,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}