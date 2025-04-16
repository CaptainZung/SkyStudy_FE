import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_controller.dart';
import 'package:skystudy/app/modules/dictionary/dictionary_model.dart';
import '../global_widgets/bottom_navbar.dart';
import 'WordDetailScreen.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  bool _showSearch = false;
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
    final DictionaryController controller = Get.put(DictionaryController());

    return Scaffold(
      backgroundColor: const Color(0xFFC8E5EB), // Màu nền C8E5EB
      appBar: AppBar(
        title: const Text(
          'TỪ ĐIỂN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Chữ màu trắng
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2277B4), // Màu AppBar 2277B4
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with smooth animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showSearch ? 70 : 0,
            padding: _showSearch 
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _showSearch
                ? TextField(
                    onChanged: controller.filterWords,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm từ vựng...',
                      prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    style: const TextStyle(fontSize: 16),
                  )
                : null,
          ),
          
          // Main content
          Expanded(
            child: Obx(() {
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
                            horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Thử lại', 
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              } else if (controller.filteredWords == null || 
                        controller.filteredWords!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 50, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Không tìm thấy từ vựng',
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
                        child: const Text('Làm mới', 
                            style: TextStyle(color: Colors.white)),
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
                  itemCount: controller.filteredWords!.keys.length,
                  itemBuilder: (context, index) {
                    String topic = controller.filteredWords!.keys.elementAt(index);
                    List<Dictionary> words = controller.filteredWords![topic]!;
                    
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
                            // Topic header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2277B4), // Màu header 2277B4
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
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
                            
                            // Words list
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: words.map((word) => _buildWordItem(word)).toList(),
                              ),
                            ),
                            
                            // View more button
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final words = await controller.fetchWordByTopic(topic);
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
                                        color: Color(0xFF2277B4), width: 1),
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
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
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

class SingleWordDetailScreen extends StatelessWidget {
  final Dictionary word;

  const SingleWordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8E5EB), // Màu nền C8E5EB
      appBar: AppBar(
        title: Text(
          word.word,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2277B4), // Màu AppBar 2277B4
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE47E24),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.ipa,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            // Details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('Loại từ', word.wordType),
                  const Divider(height: 24, thickness: 0.5),
                  _buildDetailItem('Nghĩa tiếng Việt', word.vietnamese),
                  const Divider(height: 24, thickness: 0.5),
                  _buildDetailItem('Ví dụ', word.examples),
                  const Divider(height: 24, thickness: 0.5),
                  _buildDetailItem('Ví dụ (Tiếng Việt)', word.examplesVietnamese),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE47E24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}