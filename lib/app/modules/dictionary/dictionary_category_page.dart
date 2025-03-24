import 'package:flutter/material.dart';
import 'package:skystudy/app/modules/global_widgets/bottom_navbar.dart';
class DictionaryCategoryPage extends StatelessWidget {
  const DictionaryCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dictionary Category')),
      body: Center(child: Text('Dictionary Category Screen', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
