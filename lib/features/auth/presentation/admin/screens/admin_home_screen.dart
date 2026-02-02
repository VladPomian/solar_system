import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/core/services/settings_provider.dart';
import 'package:flutter_ar/features/auth/presentation/auth_check_page.dart';
import 'package:provider/provider.dart';
import 'admin_tickets_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ панель'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AuthCheckPage(
                      onThemeChanged: context.read<SettingsProvider>().setTheme,
                      isDarkTheme: context.read<SettingsProvider>().isDarkTheme,
                      onFontSizeChanged: context.read<SettingsProvider>().setFontSize,
                      fontSize: context.read<SettingsProvider>().fontSize,
                    ),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminTicketsScreen()),
          ),
          child: const Text('Список сообщений'),
        ),
      ),
    );
  }
}