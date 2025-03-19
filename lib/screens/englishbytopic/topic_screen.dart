import 'package:flutter/material.dart';
import 'package:skystudy/widgets/widget.dart';
class TopicScreen extends StatelessWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Topics')),
      body: Center(child: Text('Topic Screen', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
