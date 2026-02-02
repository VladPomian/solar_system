import 'package:flutter/material.dart';
import 'package:flutter_ar/core/services/auth_provider.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/presentation/auth_screen.dart';
import 'package:flutter_ar/features/auth/presentation/admin/screens/admin_home_screen.dart';
import 'package:flutter_ar/features/sections/presentation/sections_page.dart';
import 'package:provider/provider.dart';

class AuthCheckPage extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkTheme;
  final Function(FontSizeOption) onFontSizeChanged;
  final FontSizeOption fontSize;

  const AuthCheckPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkTheme,
    required this.onFontSizeChanged,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isAuthenticated) {
          return const AuthScreen();
        }

        // Пользователь авторизован
        if (auth.isAdmin) {
          return AdminHomeScreen(); // ← админ-панель
        } else {
          return SectionsPage(
            onThemeChanged: onThemeChanged,
            isDarkTheme: isDarkTheme,
            onFontSizeChanged: onFontSizeChanged,
            fontSize: fontSize,
          );
        }
      },
    );
  }
}