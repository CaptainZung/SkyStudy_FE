import 'package:flutter/material.dart';
import 'package:get/get.dart';
 
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final TextStyle? titleStyle;
  final List<Widget>? actions; // Add actions parameter
 
  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.blue,
    this.showBackButton = true,
    this.bottom,
    this.titleStyle,
    this.actions, // Make actions optional
  });
 
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style:
            titleStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ), // Biểu tượng mặc định
                onPressed: () {
                  Get.back();
                },
              )
              : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromARGB(255, 13, 199, 251)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // borderRadius: const BorderRadius.only(
          //   bottomLeft: Radius.circular(20),
          //   bottomRight: Radius.circular(20),
          // ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      bottom: bottom,
      actions: actions, // Pass actions to AppBar
    );
  }
 
  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 10));
}