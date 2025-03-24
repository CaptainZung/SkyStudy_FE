import 'package:flutter/material.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Achievements')),
      body: Center(child: Text('Achievements Screen', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}
