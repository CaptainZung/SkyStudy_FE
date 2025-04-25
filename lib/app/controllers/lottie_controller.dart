import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LottieController extends GetxController {
  AnimationController? ufoController;
  AnimationController? dinoController;
  AnimationController? idleController;

  void initialize(TickerProvider vsync) {
    ufoController = AnimationController(vsync: vsync);
    dinoController = AnimationController(vsync: vsync);
    idleController = AnimationController(vsync: vsync);
  }

  void startMainAnimations(LottieComposition compositionUfo, LottieComposition compositionDino) {
    if (ufoController == null || dinoController == null) {
      throw Exception('ufoController and dinoController must be initialized before starting');
    }
    ufoController!
      ..duration = compositionUfo.duration
      ..repeat();
    dinoController!
      ..duration = compositionDino.duration
      ..repeat();
  }

  void startIdleAnimation(LottieComposition composition) {
    if (idleController == null) {
      throw Exception('idleController must be initialized before starting');
    }
    idleController!
      ..duration = composition.duration
      ..repeat();
  }

  void stopIdleAnimation() {
    idleController?.stop();
  }

  void stopAnimations() {
    ufoController?.stop();
    dinoController?.stop();
    idleController?.stop();
  }

  @override
  void onClose() {
    ufoController?.dispose();
    ufoController = null;
    dinoController?.dispose();
    dinoController = null;
    idleController?.dispose();
    idleController = null;
    super.onClose();
  }
}