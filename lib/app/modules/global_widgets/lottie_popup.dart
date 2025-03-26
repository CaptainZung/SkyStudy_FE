import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottiePopup extends StatefulWidget {
  final String initialAnimationPath;
  final String? message;
  final ValueNotifier<String> animationPathNotifier;
  final Duration? duration;

  const LottiePopup({
    super.key,
    required this.initialAnimationPath,
    this.message,
    required this.animationPathNotifier,
    this.duration,
  });

  @override
  State<LottiePopup> createState() => _LottiePopupState();
}

class _LottiePopupState extends State<LottiePopup> {
  @override
  void initState() {
    super.initState();
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: widget.animationPathNotifier,
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
            if (widget.message != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.message!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showLottiePopup({
  required BuildContext context,
  required String initialAnimationPath,
  String? message,
  required ValueNotifier<String> animationPathNotifier,
  Duration? duration,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => LottiePopup(
      initialAnimationPath: initialAnimationPath,
      message: message,
      animationPathNotifier: animationPathNotifier,
      duration: duration,
    ),
  );
}