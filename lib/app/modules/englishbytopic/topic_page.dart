import 'package:flutter/material.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
class TopicPage extends StatelessWidget {
  const TopicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Topics')),
      body: Center(child: Text('Topic Screen', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}
