import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LottieController extends GetxController {
  AnimationController? ufoController;
  AnimationController? dinoController;

  // Truyền TickerProvider ngay trong constructor
  void initialize(TickerProvider vsync) {
    ufoController = AnimationController(vsync: vsync);
    dinoController = AnimationController(vsync: vsync);
  }

  // Kiểm tra null trước khi start animations
  void startAnimations(LottieComposition compositionUfo, LottieComposition compositionDino) {
    if (ufoController == null || dinoController == null) {
      throw Exception('LottieController must be initialized before starting animations');
    }

    ufoController!
      ..duration = compositionUfo.duration
      ..repeat();

    dinoController!
      ..duration = compositionDino.duration
      ..repeat();
  }

  // Kiểm tra null trước khi stop
  void stopAnimations() {
    ufoController?.stop();
    dinoController?.stop();
  }

  @override
  void onClose() {
    ufoController?.dispose();
    ufoController = null;
    dinoController?.dispose();
    dinoController = null;
    super.onClose();
  }
}