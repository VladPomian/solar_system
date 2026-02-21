import 'package:flutter/material.dart';

void showAppVersionDialog(BuildContext context, Map<String, Color> theme, Color alertColor) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: alertColor,
      title: Text('Версия приложения', style: TextStyle(color: theme['text'])),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Версия: 1.0.0', style: TextStyle(color: theme['secondary'])),
          Text('Сборка: 20', style: TextStyle(color: theme['secondary'])),
          Text('Дата: 21.02.2026', style: TextStyle(color: theme['secondary'])),
          const SizedBox(height: 16),
          Text('Последние изменения:', style: TextStyle(color: theme['text'], fontWeight: FontWeight.bold)),
          Text(
            '• Добавлено "Разделение на роли"\n• Добавлен список сообщений пользователя\n• Реализована логика чата',
            style: TextStyle(color: theme['secondary']),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: theme['primary'])),
        ),
      ],
    ),
  );
}