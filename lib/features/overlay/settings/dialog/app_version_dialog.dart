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
          Text('Версия: 0.9.0', style: TextStyle(color: theme['secondary'])),
          Text('Сборка: 13', style: TextStyle(color: theme['secondary'])),
          Text('Дата: 02.11.2025', style: TextStyle(color: theme['secondary'])),
          const SizedBox(height: 16),
          Text('Последние изменения:', style: TextStyle(color: theme['text'], fontWeight: FontWeight.bold)),
          Text(
            '• Добавлено "О приложении"\n• Добавлен функционал очистки кэша\n• Реализован экран Помощь',
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