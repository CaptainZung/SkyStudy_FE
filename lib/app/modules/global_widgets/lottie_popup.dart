import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

Future<void> showLottiePopup({
  required BuildContext context,
  required String initialAnimationPath,
  String? message,
  required ValueNotifier<String> animationPathNotifier,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lắng nghe sự thay đổi animationPath
            ValueListenableBuilder<String>(
              valueListenable: animationPathNotifier,
              builder: (context, animationPath, _) {
                return Lottie.asset(
                  animationPath,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  repeat: true,
                );
              },
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}