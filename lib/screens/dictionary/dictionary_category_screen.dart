import 'package:flutter/material.dart';
import 'package:skystudy/widgets/widget.dart';
class DictionaryCategoryScreen extends StatelessWidget {
  const DictionaryCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dictionary Category')),
      body: Center(child: Text('Dictionary Category Screen', style: TextStyle(fontSize: 24))),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
