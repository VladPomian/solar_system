import 'package:flutter/material.dart';

class StartAnimations {
  final AnimationController controller;
  late final Animation<double> scaleAnimation;
  late final Animation<double> opacityAnimation;

  StartAnimations({required TickerProvider vsync})
      : controller = AnimationController(
          duration: const Duration(milliseconds: 1200),
          vsync: vsync,
        ) {
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
    opacityAnimation = Tween<double>(begin: 0.6, end: 0.9).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  void dispose() {
    controller.dispose();
  }
}