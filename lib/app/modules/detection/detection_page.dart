import 'package:flutter/material.dart';
import '../global_widgets/bottom_navbar.dart';

class DetectionPage extends StatelessWidget {
  const DetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection')),
      body: const Center(
        child: Text(
          'Detection Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}