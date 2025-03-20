import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LottieController extends GetxController {
  late AnimationController ufoController;
  late AnimationController dinoController;

  LottieController();

  void initialize(TickerProvider vsync) {
    ufoController = AnimationController(vsync: vsync);
    dinoController = AnimationController(vsync: vsync);
  }

  void startAnimations(LottieComposition compositionUfo, LottieComposition compositionDino) {
    ufoController
      ..duration = compositionUfo.duration
      ..repeat();

    dinoController
      ..duration = compositionDino.duration
      ..repeat();
  }

  void stopAnimations() {
    ufoController.stop();
    dinoController.stop();
  }

  @override
  void onClose() {
    ufoController.dispose();
    dinoController.dispose();
    super.onClose();
  }
}