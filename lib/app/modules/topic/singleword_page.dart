import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../global_widgets/appbar.dart';
import '../global_widgets/bottom_navbar.dart';
import 'package:skystudy/app/routes/app_pages.dart';

class SingleWordPage extends StatelessWidget {
  const SingleWordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> word = Get.arguments;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFD3EAF5),
      appBar: CustomAppBar(
        title: 'TỪ VỰNG',
        backgroundColor: Colors.blue,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Word
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blue[700],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word['word'] ?? 'Không có từ',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (word['ipa'] != null)
                      Row(
                        children: [
                          const Icon(Icons.volume_up, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            word['ipa'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Word Details
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.category, 'Loại từ:', word['word_type']),
                    const Divider(height: 20, thickness: 1),
                    _buildDetailRow(Icons.translate, 'Nghĩa:', word['vietnamese']),
                    if (word['topic'] != null) ...[
                      const Divider(height: 20, thickness: 1),
                      _buildDetailRow(Icons.label, 'Chủ đề:', word['topic']),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Examples Section
            if (word['examples'] != null || word['examples_vietnamese'] != null)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ví dụ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (word['examples'] != null)
                        Text(
                          word['examples'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (word['examples_vietnamese'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          word['examples_vietnamese'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Practice Button
            SizedBox(
              width: screenWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Get.toNamed(
                    Routes.pronunciationcheck, // Sử dụng Routes.pronunciationcheck để tránh lỗi chính tả
                    arguments: {'sampleSentence': word['word']}, // Truyền từ vựng qua arguments
                  );
                },
                child: const Text(
                  'LUYỆN TẬP TỪ NÀY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 5),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value ?? 'N/A',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}