import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/start/presentation/start_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return MaterialApp(
              title: 'Space App',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: settings.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
              home: StartPage(
                onThemeChanged: (isDark) => settings.setTheme(isDark),
                isDarkTheme: settings.isDarkTheme,
                onFontSizeChanged: (fontSize) => settings.setFontSize(fontSize),
                fontSize: settings.fontSize,
              ),
            );
          },
        );
      },
    );
  }
}