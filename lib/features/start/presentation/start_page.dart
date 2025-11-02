import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'widgets/background_widget.dart';
import 'widgets/welcome_text.dart';
import 'widgets/animated_bar.dart';
import 'navigation/custom_transition.dart';

class StartPage extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;
  final Function(FontSizeOption) onFontSizeChanged;
  final FontSizeOption fontSize;

  const StartPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkTheme,
    required this.onFontSizeChanged,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
            Navigator.push(
              context,
              createCustomRoute(
                onThemeChanged: settings.setTheme,
                isDarkTheme: settings.isDarkTheme,
                onFontSizeChanged: settings.setFontSize,
                fontSize: settings.fontSize,
              ),
            );
          }
        },
        onTap: () {
          Navigator.push(
            context,
            createCustomRoute(
              onThemeChanged: settings.setTheme,
              isDarkTheme: settings.isDarkTheme,
              onFontSizeChanged: settings.setFontSize,
              fontSize: settings.fontSize,
            ),
          );
        },
        child: Stack(
          children: [
            BackgroundWidget(isDarkTheme: settings.isDarkTheme),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h, left: 16.w, right: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WelcomeText(isDarkTheme: settings.isDarkTheme),
                    SizedBox(height: 16.h),
                    AnimatedBar(isDarkTheme: settings.isDarkTheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}