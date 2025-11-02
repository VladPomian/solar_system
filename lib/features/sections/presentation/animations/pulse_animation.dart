import 'package:flutter/material.dart';

class PulseAnimation {
  final AnimationController controller;
  late final Animation<double> animation;

  PulseAnimation({required TickerProvider vsync})
      : controller = AnimationController(
          duration: const Duration(milliseconds: 2400),
          vsync: vsync,
        ) {
    animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
  }

  void dispose() {
    controller.dispose();
  }
}