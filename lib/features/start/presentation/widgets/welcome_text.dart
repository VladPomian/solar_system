import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class WelcomeText extends StatelessWidget {
  final bool isDarkTheme;

  const WelcomeText({super.key, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        'Исследуйте Солнечную систему',
        style: TextStyle(
          fontSize: 28.sp,
          color: AppTheme.getTextColor(context),
          fontFamily: 'zen',
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 4.r,
              offset: Offset(2.r, 2.r),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}