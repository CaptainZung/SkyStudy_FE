import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final TextStyle? titleStyle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.blue,
    this.showBackButton = true,
    this.bottom,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Colors.transparent, // Background set to transparent for gradient
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Image.asset(
                'assets/icons/back.png',
                width: 30, // Adjust icon size
                height: 30,
                color: Colors.white, // Icon color to white
              ),
              onPressed: () {
                Get.back();
              },
            )
          : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromARGB(255, 13, 199, 251)], // Gradient effect
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4), // Shadow offset
            ),
          ],
        ),
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
