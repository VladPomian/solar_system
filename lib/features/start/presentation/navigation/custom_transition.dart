import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/presentation/auth_check_page.dart';

Route createCustomRoute({
  required Function(bool) onThemeChanged,
  required bool isDarkTheme,
  required Function(FontSizeOption) onFontSizeChanged,
  required FontSizeOption fontSize,
}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => AuthCheckPage(
      onThemeChanged: onThemeChanged,
      isDarkTheme: isDarkTheme,
      onFontSizeChanged: onFontSizeChanged,
      fontSize: fontSize,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      var secondaryTween = Tween(begin: Offset.zero, end: const Offset(0.0, -1.0))
          .chain(CurveTween(curve: curve));
      var secondaryOffsetAnimation = secondaryAnimation.drive(secondaryTween);

      return Stack(
        children: [
          SlideTransition(
            position: secondaryOffsetAnimation,
            child: Container(color: Colors.transparent),
          ),
          SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}