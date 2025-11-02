import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import '../animations/start_animations.dart';

class AnimatedBar extends StatefulWidget {
  final bool isDarkTheme;

  const AnimatedBar({super.key, required this.isDarkTheme});

  @override
  State<AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<AnimatedBar> with SingleTickerProviderStateMixin {
  late final StartAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = StartAnimations(vsync: this);
    _animations.controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animations.controller,
      builder: (context, child) {
        return Transform.scale(
          scaleY: _animations.scaleAnimation.value,
          child: Opacity(
            opacity: _animations.opacityAnimation.value,
            child: Container(
              width: ScreenUtil().screenWidth * 0.5,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context).withOpacity(0.8),
                borderRadius: BorderRadius.circular(2.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                    blurRadius: 8.r,
                    spreadRadius: 2.r,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}