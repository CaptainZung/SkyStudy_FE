import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class LottieController {
  final AnimationController ufoController;
  final AnimationController dinoController;

  LottieController({
    required TickerProvider vsync,
  })  : ufoController = AnimationController(vsync: vsync),
        dinoController = AnimationController(vsync: vsync);

  // Khởi động animations
  void startAnimations(LottieComposition compositionUfo, LottieComposition compositionDino) {
    ufoController
      ..duration = compositionUfo.duration
      ..repeat(); // Chạy lặp lại

    dinoController
      ..duration = compositionDino.duration
      ..repeat(); // Chạy lặp lại
  }

  // Dừng animations
  void stopAnimations() {
    ufoController.stop();
    dinoController.stop();
  }

  // Giải phóng tài nguyên
  void dispose() {
    ufoController.dispose();
    dinoController.dispose();
  }
}