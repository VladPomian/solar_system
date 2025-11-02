import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import '../../../../core/constants/animation_constants.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import '../models/sections_model.dart';
import '../animations/pulse_animation.dart';

class SectionCard extends StatelessWidget {
  final Section section;
  final double position;
  final double left;
  final double height;
  final double scale;
  final double blur;
  final double opacity;
  final bool isActive;
  final PulseAnimation pulseAnimation;
  final VoidCallback onTap;
  final bool isDarkTheme;

  const SectionCard({
    super.key,
    required this.section,
    required this.position,
    required this.left,
    required this.height,
    required this.scale,
    required this.blur,
    required this.opacity,
    required this.isActive,
    required this.pulseAnimation,
    required this.onTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: AnimationConstants.animationDuration,
      curve: AnimationConstants.animationCurve,
      top: position,
      left: left,
      child: AnimatedBuilder(
        animation: pulseAnimation.controller,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? scale * pulseAnimation.animation.value : scale,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: 300.w,
            height: height,
            child: TweenAnimationBuilder<double>(
              duration: AnimationConstants.animationDuration,
              curve: AnimationConstants.animationCurve,
              tween: Tween<double>(end: blur),
              builder: (context, sigma, child) {
                return ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: child,
                  ),
                );
              },
              child: TweenAnimationBuilder<double>(
                duration: AnimationConstants.animationDuration,
                curve: AnimationConstants.animationCurve,
                tween: Tween<double>(end: opacity),
                builder: (context, opacity, child) {
                  return Opacity(
                    opacity: opacity,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context).withOpacity(0.1), 
                    border: Border.all(
                      color: isActive 
                          ? AppTheme.getPrimaryColor(context).withOpacity(0.6)
                          : AppTheme.getTextColor(context).withOpacity(0.4),
                      width: isActive ? 1.0 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12.r,
                              offset: Offset(4.r, 4.r),
                            ),
                            BoxShadow(
                              color: AppTheme.getTextColor(context).withOpacity(0.2),
                              blurRadius: 20.r,
                              spreadRadius: 2.r,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8.r,
                              offset: Offset(4.r, 4.r),
                            ),
                          ],
                    gradient: isActive
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.getPrimaryColor(context).withOpacity(0.3),
                              Colors.transparent,
                              Colors.transparent,
                              AppTheme.getPrimaryColor(context).withOpacity(0.3),
                            ],
                            stops: [0.0, AnimationConstants.overlapFraction, 1 - AnimationConstants.overlapFraction, 1.0],
                          )
                        : null,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isActive)
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                                  blurRadius: 12.r,
                                  spreadRadius: 4.r,
                                ),
                              ],
                            ),
                            child: Icon(
                              section.icon,
                              size: 60.sp,
                              color: AppTheme.getTextColor(context).withOpacity(0.9),
                            ),
                          )
                        else
                          Icon(
                            section.icon,
                            size: 40.sp,
                            color: AppTheme.getTextColor(context).withOpacity(0.9),
                          ),
                        SizedBox(height: 8.h),
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: AppTheme.getHeadlineFontSize(),
                            color: isActive 
                                ? AppTheme.getPrimaryColor(context).withOpacity(0.9)
                                : AppTheme.getTextColor(context).withOpacity(0.9),
                            fontFamily: 'zen',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isActive) ...[
                          SizedBox(height: 8.h),
                          TweenAnimationBuilder<double>(
                            duration: AnimationConstants.animationDuration,
                            curve: AnimationConstants.animationCurve,
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            builder: (context, opacity, child) {
                              return Opacity(
                                opacity: opacity,
                                child: child,
                              );
                            },
                            child: Column(
                              children: [
                                Text(
                                  section.description,
                                  style: TextStyle(
                                    fontSize: AppTheme.getSubtitleFontSize(),
                                    color: AppTheme.getTextColor(context).withOpacity(0.95),
                                    fontFamily: 'zen',
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 2.r,
                                        offset: Offset(1.r, 1.r),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  section.descriptionSecond,
                                  style: TextStyle(
                                    fontSize: AppTheme.getSubtitleFontSize(),
                                    color: AppTheme.getTextColor(context).withOpacity(0.95),
                                    fontFamily: 'zen',
                                    fontWeight: FontWeight.normal,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 2.r,
                                        offset: Offset(1.r, 1.r),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}