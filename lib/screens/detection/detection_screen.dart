import 'package:flutter/material.dart';
import 'package:skystudy/widgets/widget.dart';
class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detection')),
      body: Center(child: Text('Detection Screen', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
