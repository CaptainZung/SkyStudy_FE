import 'package:flutter/material.dart';

PageRouteBuilder createSlideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      const beginOld = Offset.zero;
      const endOld = Offset(-1.0, 0.0);
      var tweenOld = Tween(begin: beginOld, end: endOld).chain(CurveTween(curve: curve));
      var offsetAnimationOld = secondaryAnimation.drive(tweenOld);

      return Stack(
        children: [
          SlideTransition(
            position: offsetAnimationOld,
            child: child,
          ),
          SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}