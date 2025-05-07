import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skystudy/app/controllers/lottie_controller.dart';

class LottieAnimationWidget extends StatefulWidget {
  const LottieAnimationWidget({super.key}); // Ensure the key is unique if passed

  @override
  LottieAnimationWidgetState createState() => LottieAnimationWidgetState();
}

class LottieAnimationWidgetState extends State<LottieAnimationWidget> with TickerProviderStateMixin {
  LottieComposition? _ufoComposition;
  LottieComposition? _dinoComposition;
  final LottieController lottieController = Get.find<LottieController>();

  @override
  void initState() {
    super.initState();
    lottieController.initialize(this);
  }

  @override
  void dispose() {
    lottieController.ufoController?.dispose(); // Dispose ufoController
    lottieController.dinoController?.dispose(); // Dispose dinoController
    lottieController.stopAnimations();
    lottieController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: UniqueKey(), // Ensure the widget tree is rebuilt properly
      children: [
        Positioned(
          top: MediaQuery.of(context).size.height * 0.67,
          left: MediaQuery.of(context).size.width * 0.45,
          child: Lottie.asset(
            'assets/lottie/ufo1.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
            controller: lottieController.ufoController,
            onLoaded: (composition) {
              _ufoComposition = composition;
              if (_dinoComposition != null) {
                lottieController.startMainAnimations(
                  _ufoComposition!,
                  _dinoComposition!,
                );
              }
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.62,
          left: MediaQuery.of(context).size.width * 0.55,
          child: Lottie.asset(
            'assets/lottie/khunglongdance.json',
            width: 170,
            height: 170,
            fit: BoxFit.contain,
            controller: lottieController.dinoController,
            onLoaded: (composition) {
              _dinoComposition = composition;
              if (_ufoComposition != null) {
                lottieController.startMainAnimations(
                  _ufoComposition!,
                  _dinoComposition!,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}