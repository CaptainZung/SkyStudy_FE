import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final VoidCallback? onBack; // <-- Thêm callback tùy chỉnh cho nút back

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = Colors.blue,
    this.showBackButton = true,
    this.bottom,
    this.titleStyle,
    this.actions,
    this.onBack, // <-- Gán callback
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: onBack ?? () => Get.back(), // <-- Ưu tiên callback
            )
          : null,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, const Color.fromARGB(255, 13, 199, 251)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 10));
}
